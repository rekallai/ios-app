//
//  OrderVenueTicketsViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 26/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class OrderVenueTicketsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var updatable: CDUpdateMonitor<Venue>?
    var venue: Venue? {
        set {
            updatable = nil
            viewModel.venue = newValue
            
            if let strongNewVenue = newValue {
                updatable = CDUpdateMonitor(cdItem: strongNewVenue) { [weak self] in
                    self?.viewModel.venue = self?.updatable?.cdItem
                }
            }
        }
        get {
            return updatable?.cdItem
        }
    }
    
    var viewModel = PaymentViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    var showsCheckoutButtons = true

    private var groupsEmail = "groups@rekall.ai"
    private var maxWarningCount = 19
    private var maxTicketCount = 39
    private var datePickerVisible = false
    private var haveCompletedApiCall = false
    private var termsAccepted = Defaults.hasAcceptedTerms()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        tableView.register(PaymentTotalCell.nib, forCellReuseIdentifier: PaymentTotalCell.identifier)
        tableView.register(NeedHelpCell.nib, forCellReuseIdentifier: NeedHelpCell.identifier)

        viewModel.onTicketInventorySuccess = { [weak self] in
            self?.haveCompletedApiCall = true
            self?.hideProgress() {
                let changeableSections = IndexSet(Section.regularTicketStepper.rawValue...Section.needHelp.rawValue)
                self?.tableView?.reloadSections(changeableSections, with: .automatic)
            }
        }
        
        viewModel.onTicketInventoryFailure = { [weak self] error in
            self?.haveCompletedApiCall = true
            self?.hideProgress()
            let changeableSections = IndexSet(Section.regularTicketStepper.rawValue...Section.needHelp.rawValue)
            self?.tableView?.reloadSections(changeableSections, with: .automatic)
            self?.showError(error: error)
        }
        
        //
        //  Only load if we need to (i.e. not on editing screen)
        //
        if viewModel.regularTicketInventoryCount == 0 {
            showProgress()
            viewModel.loadTicketInventory()
        }
        checkTerms()
    }
    
    func checkTerms() {
        if let userAccepted = UserViewModel.shared.user.optIns?.termsAccepted {
            termsAccepted = userAccepted || termsAccepted
        }
    }
    
    func showGroup()->Bool {
        return viewModel.ticketOrderCount() > maxWarningCount
    }
    
    func overMaxTickets()->Bool {
        return viewModel.ticketOrderCount() > maxTicketCount
    }
    
    func shouldReloadGroup()->Bool {
        let count = viewModel.ticketOrderCount()
        let warningRange = maxWarningCount...(maxWarningCount + 1)
        let maxRange = (maxTicketCount - 1)...(maxTicketCount + 1)
        return warningRange.contains(count) || maxRange.contains(count)
    }
    
    // MARK: - Navigation
    
    func popToBeforePayment() {
        guard let nc = navigationController,
            let paymentStartIndex = nc.viewControllers.lastIndex(where: {
                $0 is OrderVenueTicketsViewController
            }) else {
                return
        }
        
        let targetIndex = nc.viewControllers.index(before: paymentStartIndex)
        let targetVC = nc.viewControllers[targetIndex]
        nc.popToViewController(targetVC, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cardDetailsVC = segue.destination as? CardDetailsViewController {
            cardDetailsVC.viewModel = viewModel
        }
        
        if let navVC = segue.destination as? UINavigationController,
           let confirmationVC = navVC.viewControllers.first as? PaymentConfirmationViewController  {
            confirmationVC.viewModel = viewModel
        }
        
        if let savedCardsVC = segue.destination as? SavedCardsViewController {
            savedCardsVC.viewModel = viewModel
            savedCardsVC.delegate = self
        }
    }
    
    func checkReadyToProceed() -> Bool {
        if let errMsg = viewModel.errorMessageForTicketQuantity() {
            showError(error: errMsg)
            return false
        }
        
        if !termsAccepted {
            showError(error: NSLocalizedString("Please accept the terms and conditions.",
                                               comment: "Error message"))
            return false
        }
        
        return true
    }
    
    @IBAction func checkoutTapped(_ sender: UIButton) {
        
        guard checkReadyToProceed() else { return }
        
        if UserViewModel.shared.haveSavedPaymentMethod() {
            performOneStepCheckout()
        } else {
            performSegue(withIdentifier: "CardDetails", sender: self)
        }
    }
    
    
    /// Saved card flow
    private func performOneStepCheckout() {
        viewModel.onOrderSuccess = { [weak self] in
            self?.hideProgress() {
                self?.performSegue(withIdentifier: "PaymentConfirmation", sender: self)
                
                // Don't have a segue completion handler.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    self?.popToBeforePayment()
                }
            }
        }
        
        viewModel.onOrderFailure = { [weak self] errorStr in
            self?.hideProgress()
            self?.showError(error: errorStr)
        }

        guard let stripeId = UserViewModel.shared.savedCardStripeId() else {
            showError(error: "Don't have the Stripe payment method ID")
            return
        }
        
        showProgress()
        viewModel.saveCardDetails = false
        viewModel.payWithSavedPaymentMethod(hostViewController: self, stripeMethodId: stripeId)
    }
    
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.ticketDate = sender.date
        
        if let dateCell = tableView.cellForRow(at: IndexPath(row: 0, section: Section.date.rawValue)) as? PaymentTextDisplayCell {
            dateCell.detailLabel.text = DateFormatter.shortDayMonthDateGmt.string(from: viewModel.ticketDate)
        }
        
        showProgress()
        viewModel.loadTicketInventory()
    }
}


extension OrderVenueTicketsViewController: UITableViewDataSource, UITableViewDelegate {
    
    enum Section: Int, CaseIterable {
        case venueHeader
        case date
        case datePicker
        case regularTicketStepper
        case noTickets
        //case pricingAndAgeRequirements
        
        case ferryTicketsHeader
        case ferryTicketsInformation
        case ferryTicketsStepper
        
        case bigSeparator1
        case paymentCard
        case email
        case bigSeparator2
        
        case groupSales
        case total
        case termsAndPrivacy
        case groupWarning
        case purchase
        
        case needHelp
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("Bad section")
        }

        switch section {
        case .venueHeader:
            return 1
        case .date:
            return 1
        case .datePicker:
            return datePickerVisible ? 1 : 0
        case .regularTicketStepper:
            return viewModel.regularTicketInventoryCount
        case .noTickets:
            return haveCompletedApiCall && viewModel.regularTicketInventoryCount == 0 ? 1 : 0
        default:
            break
        }
        
        // If there are no tickets, don't show anything below the no ticket warning.
        if viewModel.regularTicketInventoryCount == 0 {
            return 0
        }
        
        switch section {
            case .ferryTicketsHeader, .ferryTicketsInformation:
                return viewModel.bundledTicketInventoryCount > 0 ? 1 : 0
            case .ferryTicketsStepper:
                return viewModel.bundledTicketInventoryCount

        case .bigSeparator1, .paymentCard, .email, .bigSeparator2:
            return UserViewModel.shared.haveSavedPaymentMethod() ? 1 : 0
            
        case .groupWarning:
            return showGroup() ? 1 : 0
        case .purchase:
            return showsCheckoutButtons ? 1 : 0
            
        case .needHelp:
            return UserViewModel.shared.haveSavedPaymentMethod() && showsCheckoutButtons ? 1 : 0
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Bad section")
        }

        switch section {
        case .venueHeader:
            let title = tableView.dequeueReusableCell(withIdentifier: "PaymentVenueTitle", for: indexPath)
                as! PaymentVenueTitleCell
            title.venue = venue
            return title
        case .date:
            let dateCell = tableView.dequeueReusableCell(withIdentifier: "Date", for: indexPath)
                as! PaymentTextDisplayCell
            dateCell.detailLabel.text = DateFormatter.shortDayMonthDateGmt.string(from: viewModel.ticketDate)
            return dateCell
        case .datePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePicker", for: indexPath) as! PaymentDatePickerCell
            cell.datePicker.date = viewModel.ticketDate
            return cell
        case .regularTicketStepper:
            return ticketStepperForIndexPath(indexPath: indexPath)
        case .noTickets:
            return tableView.dequeueReusableCell(withIdentifier: "NoTickets", for: indexPath)
        /*case .pricingAndAgeRequirements:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Information", for: indexPath) as! PaymentTicketInformationCell
            cell.ticketInformationLabel.text =
                NSLocalizedString("This is a place for the description of pricing and age requirements.",
                                  comment: "Ticket Information")
            cell.ticketInformationLabel.textColor = UIColor(named: "DarkGrayText")
            return cell*/
        case .ferryTicketsHeader:
            return tableView.dequeueReusableCell(withIdentifier: "FerryTicketsHeader", for: indexPath)
        case .ferryTicketsInformation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Information", for: indexPath) as! PaymentTicketInformationCell
            cell.ticketInformationLabel.text =
                NSLocalizedString("You can buy 2x the number of non-ferry tickets you are purchasing.",
                                  comment: "Ticket Information")
            cell.ticketInformationLabel.textColor = viewModel.isBundledTicketQuantityValid() ?
                UIColor(named: "DarkGrayText") : UIColor.red
            return cell
        case .ferryTicketsStepper:
            return ticketStepperForIndexPath(indexPath: indexPath)
        case .paymentCard:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextWithDetail", for: indexPath) as! PaymentTextDisplayCell
            cell.titleLabel.text = NSLocalizedString("Payment", comment: "Row title")
            cell.detailLabel.text = UserViewModel.shared.savedCardPaymentSummaryDetails()
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextWithDetail", for: indexPath) as! PaymentTextDisplayCell
            cell.titleLabel.text = NSLocalizedString("Email", comment: "Row title")
            cell.detailLabel.text = UserViewModel.shared.user.email
            return cell
        case .groupSales:
            return groupSalesCellIn(tableView: tableView, at: indexPath)
        case .total:
            let cell = tableView.dequeueReusableCell(withIdentifier: PaymentTotalCell.identifier, for: indexPath) as! PaymentTotalCell
            cell.priceCalulator = viewModel.ticketPriceCalculator
            return cell
        case .termsAndPrivacy:
            return termsOfServiceCellIn(tableView: tableView, at: indexPath)
        case .groupWarning:
            return groupWarningCellIn(tableView: tableView, at: indexPath)
        case .purchase:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseButtons", for: indexPath) as! PurchaseButtonsCell
            cell.configureAs(initialCheckout: !UserViewModel.shared.haveSavedPaymentMethod())
            cell.setStateEnabled(!overMaxTickets())
            cell.payButtonDelegate = self
            return cell
        case .bigSeparator1: fallthrough
        case .bigSeparator2:
            return tableView.dequeueReusableCell(withIdentifier: "BigSeparator", for: indexPath)
        case .needHelp:
            let cell = tableView.dequeueReusableCell(withIdentifier: NeedHelpCell.identifier, for: indexPath) as! NeedHelpCell
            cell.delegate = self
            return cell
        }
    }
    
    func ticketStepperForIndexPath(indexPath: IndexPath) -> TicketStepperCell {
        let stepper = tableView.dequeueReusableCell(withIdentifier: "TicketStepper", for: indexPath) as! TicketStepperCell

        if indexPath.section == Section.regularTicketStepper.rawValue {
            stepper.ticketInventoryItem = viewModel.regularTicketInventoryItem(at: indexPath.row)
        } else if indexPath.section == Section.ferryTicketsStepper.rawValue {
            stepper.ticketInventoryItem = viewModel.bundledTicketInventoryItem(at: indexPath.row)
        }
        
        stepper.delegate = self
        
        return stepper
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Bad section")
        }

        switch section {
        case .date:
            datePickerVisible = !datePickerVisible
            tableView.reloadSections(IndexSet(integer: Section.datePicker.rawValue), with: .automatic)
            break
        case .paymentCard, .email:
            if !checkReadyToProceed() {
                return
            }
            
            performSegue(withIdentifier: "SavedCards", sender: self)
        default:
            break
        }
    }
    
    func termsOfServiceCellIn(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TermsPrivacyCell.identifier, for: indexPath) as! TermsPrivacyCell
        cell.acceptSwitch.isOn = termsAccepted
        cell.acceptSwitch.isEnabled = !termsAccepted
        cell.acceptSwitch.alpha = termsAccepted ? 0.5 : 1.0
        cell.setLinkColor()
        let label = cell.viewWithTag(10)
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(didTapTermsAndPrivacyLabel(sender:)))
        label?.addGestureRecognizer(tapGr)
        return cell
    }
    
    func groupWarningCellIn(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupWarning", for: indexPath) as! GroupWarningCell
        
        let count = viewModel.ticketOrderCount()
        if count > maxWarningCount && count <= maxTicketCount {
            cell.bodyLabel.text = NSLocalizedString("For orders over 20 tickets, a valid ID and the credit card used on this order will be required when you arrive.", comment: "Label")
        } else if count > maxTicketCount {
            cell.bodyLabel.text = NSLocalizedString("Please contact group sales for large purchases.", comment: "Label")
        }
        
        return cell
    }
    
    func groupSalesCellIn(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupSales", for: indexPath) as! GroupSalesCell
         
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapGroupSales(sender:)))
        cell.bodyLabel.addGestureRecognizer(tap)
        cell.setLinkColor(text: groupsEmail)
        return  cell
    }
    
    @objc func didTapGroupSales(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        if sender.didTap(subString: "\(groupsEmail).", in: label) {
            UIApplication.mail(address: groupsEmail)
        }
    }
    
    @objc func didTapTermsAndPrivacyLabel(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        if sender.didTap(subString: "Terms of Service", in: label) {
            print("ToS tapped")
            showWebViewWithUrl(url: URL(string: Environment.shared.termsUrl)!)
        }

        if sender.didTap(subString: "Privacy Policy", in: label) {
            print("Privacy tapped")
            showWebViewWithUrl(url: URL(string: Environment.shared.privacyUrl)!)
        }
    }

    private func showWebViewWithUrl(url: URL) {
        guard let webView = UIStoryboard.webView() else { return }
        webView.initialUrl = url
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    @IBAction func paymentSwitchToggled(_ sender: UISwitch) {
        Defaults.setTermsAccepted()
        termsAccepted = sender.isOn
        UserViewModel.shared.updateTermsAccepted()
        let section = Section.termsAndPrivacy.rawValue
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}


extension OrderVenueTicketsViewController: TicketStepperCellDelegate {
    
    func ticketStepperChanged(value: Int, cell: TicketStepperCell) {
        guard let ip = tableView?.indexPath(for: cell) else {
            return
        }
        
        //reload groupWarning section
        if shouldReloadGroup() {
            let groupSet = IndexSet(integer: Section.groupWarning.rawValue)
            self.tableView.reloadSections(groupSet, with: .automatic)
        }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Section.purchase.rawValue)) as? PurchaseButtonsCell {
            cell.setStateEnabled(!overMaxTickets())
        }

        if ip.section == Section.regularTicketStepper.rawValue {
            viewModel.setRegularTicketQuantity(quantity: value, for: ip.row)
        } else if ip.section == Section.ferryTicketsStepper.rawValue {
            viewModel.setBundledTicketQuantity(quantity: value, for: ip.row)
        }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Section.ferryTicketsInformation.rawValue)) as? PaymentTicketInformationCell {
            cell.ticketInformationLabel.textColor = viewModel.isBundledTicketQuantityValid() ?
                UIColor(named: "DarkGrayText") : UIColor.red
        }
        
        if let cell = tableView?.cellForRow(at: IndexPath(row: 0, section: Section.total.rawValue)) as? PaymentTotalCell {
            cell.updateLabels()
        }
    }
}


/// Apple pay flow
extension OrderVenueTicketsViewController: PayButtonDelegate {
    func payButtonTapped() {
        guard checkReadyToProceed() else { return }

        viewModel.onOrderSuccess = { [weak self] in
            self?.hideProgress() {
                self?.performSegue(withIdentifier: "PaymentConfirmation", sender: self)
                
                // Don't have a segue completion handler.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    self?.popToBeforePayment()
                }
            }
        }
        
        viewModel.onOrderFailure = { [weak self] errorStr in
            print("order failure")
            self?.hideProgress()
            self?.showError(error: errorStr)
        }
        
        viewModel.onOrderEmailAlreadyInUse = { [weak self] in
            print("Email already in use!!!")
            self?.hideProgress()
            
            let title = NSLocalizedString("Email already used", comment: "Error title")
            let message = NSLocalizedString( "You have used that email to buy tickets previously. Please sign in to purchase tickets.", comment: "Error message")
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Button"),
                                       style: .cancel,
                                       handler: nil))
            ac.addAction(UIAlertAction(title: NSLocalizedString("Sign in", comment: "Button"),
                                       style: .default) { [weak self] action in
                self?.signIn()
            })
            
            self?.present(ac, animated: true, completion: nil)
        }

        viewModel.onOrderCancelled = { [weak self] in
            print("order cancelled")
            self?.hideProgress()
        }
        
        viewModel.applePayCompleted = { [weak self] in
            self?.showProgress()
        }

        viewModel.payWithApplePay(hostViewController: self)
    }
}


extension OrderVenueTicketsViewController: PreAuthDelegate {
    func authSuccessfulIn(sender: PreAuthViewController) {
        tableView?.reloadData()
    }
    
    private func signIn() {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? UINavigationController,
              let preAuthVC = vc.viewControllers.first as? PreAuthViewController else {
                print("ERROR: failed in instantiate VC from SB")
                return
        }
        
        preAuthVC.delegate = self
        preAuthVC.signUpFlow = false
        preAuthVC.paymentFlow = true
        preAuthVC.prefilledEmailAddress = viewModel.applePayEmail
        present(vc, animated: true)
    }
}


extension OrderVenueTicketsViewController: NeedHelpCellDelegate {
    func needHelpChatTappedIn(sender: NeedHelpCell) {
        IntercomManager.shared.launchMessenger()
    }
    
    func needHelpCallTappedIn(sender: NeedHelpCell) {
        print("Need help call tapped")
    }
}

extension OrderVenueTicketsViewController: SavedCardsDelegate {
    func savedCardWasModified(sender: SavedCardsViewController) {
        tableView.reloadData()
    }
}
