//
//  PaymentOverviewViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 25/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class PaymentOverviewViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var viewModel: PaymentViewModel?
    var paymentItems = [(String, String)]()
    
    let cellSeparatorLeftInset: CGFloat = 15.0
    var useSavedCardDetails = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnTitle = NSLocalizedString("Cancel", comment: "Button title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: btnTitle,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelTapped(sender:)))
        
        tableView.register(PaymentTotalCell.nib, forCellReuseIdentifier: PaymentTotalCell.identifier)
        
        reloadPurchasedItems()
    }
    
    func reloadPurchasedItems(){
        if let pi = viewModel?.getPurchase()?.getUserSummery() {
            paymentItems = pi
        }
    }
    
    @objc func cancelTapped(sender: UIBarButtonItem) {
        popToBeforePayment()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController,
        let confirmationVC = navVC.viewControllers.first as? PaymentConfirmationViewController {
            confirmationVC.viewModel = viewModel
        }
    }
 

    private var editingCardDetails = false
    @IBAction func headerActionButtonTapped(_ sender: UIButton) {
        print("header button tapped")
        
        var vcToDisplay: UIViewController?
        
        switch sender.tag {
        case Section.orderSummaryHeader.rawValue:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "OrderVenueTicketsViewController")
                as? OrderVenueTicketsViewController,
               let viewModel = viewModel {
                    vc.viewModel = viewModel
                    vc.showsCheckoutButtons = false
                    vcToDisplay = vc
            }
            editingCardDetails = false
        case Section.paymentDetailsHeader.rawValue:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "CardDetailsViewController")
                as? CardDetailsViewController{
                vc.viewModel = viewModel
                vc.showsReviewYourOrderButton = false
                vcToDisplay = vc
            }
            editingCardDetails = true
        default:
            return
        }
        
        if let viewModel = viewModel {
            undoManager?.registerUndo(withTarget: viewModel) {
                [
                    cardNumber = viewModel.cardNumber,
                    firstName = viewModel.firstName,
                    lastName = viewModel.lastName,
                    email = viewModel.email,
                    securityCode = viewModel.securityCode,
                    month = viewModel.month,
                    year = viewModel.year,
                    zipCode = viewModel.zipCode,
                    ticketDate = viewModel.ticketDate,
                    ticketOptionCount = viewModel.getTicketQuantities()
                ] in
                $0.cardNumber = cardNumber
                $0.firstName = firstName
                $0.lastName = lastName
                $0.email = email
                $0.securityCode = securityCode
                $0.month = month
                $0.year = year
                $0.zipCode = zipCode
                $0.ticketDate = ticketDate
                
                for i in 0 ..< ticketOptionCount.count {
                    $0.setIndexedTicketQuantity(quantity: ticketOptionCount[i], for: i)
                }
            }
        }
        
        guard let rootVc = vcToDisplay else { return }
        rootVc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel",
                                                                                           comment: "Button"),
                                                                  style: .plain,
                                                                  target: self,
                                                                  action: #selector(editScreenCancelTapped(sender:)))
        rootVc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done",
                                                                                            comment: "Button"),
                                                                   style: .done,
                                                                   target: self,
                                                                   action: #selector(editScreenDoneTapped(sender:)))
        let navCon = UINavigationController(rootViewController: rootVc)
        present(navCon, animated: true, completion: nil)
    }
    
    
    @objc func editScreenCancelTapped(sender: UIBarButtonItem) {
        undoManager?.undo()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func editScreenDoneTapped(sender: UIBarButtonItem) {
        if let errMsg = viewModel?.errorMessageForTicketQuantity() {
            presentedViewController?.showError(error: errMsg)
            return
        }
        
        if let errorString = viewModel?.errorMessageForPaymentDetails() {
            presentedViewController?.showError(error: errorString)
            return
        }
        
        if editingCardDetails {
            // User has entered a new card
            useSavedCardDetails = false
        }

        undoManager?.removeAllActions()
        reloadPurchasedItems()
        tableView?.reloadData()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func purchaseTapped(_ sender: UIButton) {
        guard viewModel?.ticketOrderCount() ?? 0 > 0 else {
            showError(error: NSLocalizedString("Please select at least 1 ticket to proceed.",
                                               comment: "Error message"))
            return
        }

        viewModel?.onOrderSuccess = { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.hideProgress() {
                strongSelf.performSegue(withIdentifier: "PaymentConfirmation", sender: self)
                
                // Don't have a segue completion handler.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    self?.popToBeforePayment()
                }
            }
        }
        
        viewModel?.onOrderFailure = { [weak self] errorStr in
            self?.hideProgress()
            self?.showError(error: errorStr)
        }
        
        viewModel?.onOrderEmailAlreadyInUse = { [weak self] in
            self?.hideProgress()
            self?.showError(error: NSLocalizedString("You have used that email to buy tickets previously. Please sign in to purchase tickets.",
                                                     comment: "Error message"))
        }
        
        viewModel?.onOrderCancelled = { [weak self] in
            self?.hideProgress()
        }
        
        showProgress()
        
        if useSavedCardDetails {
            guard let stripeId = UserViewModel.shared.savedCardStripeId() else {
                showError(error: "Don't have the Stripe payment method ID")
                return
            }

            viewModel?.saveCardDetails = false
            viewModel?.payWithSavedPaymentMethod(hostViewController: self, stripeMethodId: stripeId)
        } else {
            viewModel?.payWithCreditCard(hostViewController: self)
        }
    }
    
    
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
}


extension PaymentOverviewViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case orderSummaryHeader
        case venueName
        case date
        case ticketsSummary
        case paymentDetailsHeader
        case paymentCardNumber
        case email
        case totalHeader
        case total
        case purchase
        //case needHelp
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("Bad section")
        }

        if section == .ticketsSummary {
            return paymentItems.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Bad section")
        }

        switch section {
        case .orderSummaryHeader:
            return headerForSection(section: section, for: indexPath)
        case .venueName:
            let venueTitle = tableView.dequeueReusableCell(withIdentifier: "PaymentVenueTitle", for: indexPath)
                as! PaymentVenueTitleCell
            venueTitle.venue = viewModel?.venue
            return venueTitle
        case .date:
            let textCell = tableView.dequeueReusableCell(withIdentifier: "TextWithDetail", for: indexPath) as! PaymentTextDisplayCell
            if let date = viewModel?.ticketDate {
                textCell.titleLabel.text = DateFormatter.longDayMonthDateGmt.string(from: date)
            } else {
                textCell.titleLabel.text = ""
            }
            textCell.detailLabel.text = ""
            textCell.separatorInset.left = cellSeparatorLeftInset
            return textCell
        case .ticketsSummary:
            return ticketSummaryForIndexPath(indexPath: indexPath)
        case .paymentDetailsHeader:
            return headerForSection(section: section, for: indexPath)
        case .paymentCardNumber:
            let textCell = tableView.dequeueReusableCell(withIdentifier: "TextWithDetail", for: indexPath) as! PaymentTextDisplayCell
            textCell.titleLabel.text = NSLocalizedString("Payment", comment: "Card Label")
            if useSavedCardDetails {
                textCell.detailLabel.text = UserViewModel.shared.savedCardPaymentSummaryDetails()
            } else {
                textCell.detailLabel.text = viewModel?.displayableCardNumber()
            }
            textCell.separatorInset.left = cellSeparatorLeftInset
            return textCell
        case .email:
            let textCell = tableView.dequeueReusableCell(withIdentifier: "TextWithDetail", for: indexPath) as! PaymentTextDisplayCell
            textCell.titleLabel.text = NSLocalizedString("Email", comment: "Email label")
            if useSavedCardDetails {
                textCell.detailLabel.text = UserViewModel.shared.user.email
            } else {
                textCell.detailLabel.text = viewModel?.email
            }
            textCell.separatorInset.left = 0
            return textCell
        case .totalHeader:
            return headerForSection(section: section, for: indexPath)
        case .total:
            let cell = tableView.dequeueReusableCell(withIdentifier: PaymentTotalCell.identifier, for: indexPath) as! PaymentTotalCell
            cell.priceCalulator = viewModel?.ticketPriceCalculator
            return cell
        case .purchase:
            return tableView.dequeueReusableCell(withIdentifier: "Purchase", for: indexPath)
        //case .needHelp:
        }
    }
    
    
    func ticketSummaryForIndexPath(indexPath: IndexPath) -> PaymentTextDisplayCell {
        let textCell = tableView.dequeueReusableCell(withIdentifier: "TextWithDetail", for: indexPath)
            as! PaymentTextDisplayCell
        textCell.titleLabel.text = paymentItems[indexPath.row].0
        textCell.detailLabel.text = paymentItems[indexPath.row].1
        
        textCell.separatorInset.left = indexPath.row == paymentItems.count - 1 ? 0 : cellSeparatorLeftInset
        
        return textCell
    }
    
    
    func headerForSection(section: Section, for indexPath: IndexPath) -> PaymentHeaderCell {
        let header = tableView.dequeueReusableCell(withIdentifier: "SectionHeader", for: indexPath) as! PaymentHeaderCell
                
        switch section{
        case .orderSummaryHeader:
            header.headerTitleLabel.text = NSLocalizedString("ORDER SUMMARY", comment: "Table section header")
            header.editButton.isHidden = false
        case .paymentDetailsHeader:
            header.headerTitleLabel.text = NSLocalizedString("PAYMENT DETAILS", comment: "Table section header")
            header.editButton.isHidden = false
        case .totalHeader:
            header.headerTitleLabel.text = NSLocalizedString("YOUR TOTAL", comment: "Table section header")
            header.editButton.isHidden = true
        default:
            print("ERROR: asked for a header not in a header section")
        }
        
        header.editButton.tag = section.rawValue
        
        return header
    }
}
