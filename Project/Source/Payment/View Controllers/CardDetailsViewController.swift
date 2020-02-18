//
//  CardDetailsViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 24/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class CardDetailsViewController: KeyboardAwareViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var viewModel: PaymentViewModel?
    private let userViewModel = UserViewModel.shared
    
    var showsReviewYourOrderButton = true
    private var saveCardDetails = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardAwareScrollView = tableView
        
        if ADApi.shared.store.isLoggedIn {
            updateUserDetails()
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let summary = segue.destination as? PaymentOverviewViewController {
            summary.viewModel = viewModel
            summary.useSavedCardDetails = (sender as? Bool) ?? false
        }
    }
 

    @IBAction func signInTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? UINavigationController,
              let preAuthVC = vc.viewControllers.first as? PreAuthViewController else {
                print("ERROR: failed in instantiate VC from SB")
                return
        }
        
        preAuthVC.delegate = self
        preAuthVC.authViewModel = viewModel?.authViewModel
        preAuthVC.signUpFlow = false
        preAuthVC.paymentFlow = true
        present(vc, animated: true)
    }
    
    
    @IBAction func saveCardSwitchChanged(_ sender: UISwitch) {
        saveCardDetails = sender.isOn
    }
    
    @IBAction func reviewYourOrderTapped(_ sender: UIButton) {
        if let errorString = viewModel?.errorMessageForPaymentDetails() {
            showError(error: errorString)
            return
        }
        
        viewModel?.saveCardDetails = saveCardDetails
        
        performSegue(withIdentifier: "PaymentOverview", sender: false)
    }
    
    func updateUserDetails() {
        userViewModel.onUpdateUserSuccess = { [weak self] in
            guard let strongSelf = self else { return }
            let user = strongSelf.userViewModel.user
            
            strongSelf.configCell(.firstName, text: user.firstName)
            strongSelf.configCell(.lastName, text: user.lastName)
            strongSelf.viewModel?.firstName = user.firstName
            strongSelf.viewModel?.lastName = user.lastName
            
            let emailIp = IndexPath(row: 0, section: Section.email.rawValue)
            if let cell = strongSelf.tableView?.cellForRow(at: emailIp) as? TextInputCell {
                cell.textField.text = user.email
            }
            
            strongSelf.viewModel?.email = user.email
        }
        
        userViewModel.onUpdateUserFailure = { [weak self] errorStr in
            self?.showError(error: errorStr)
        }
        
        userViewModel.loadUser()
    }
    
    func configCell(_ section: Section, text: String) {
        let ip = IndexPath(row: 0, section: section.rawValue)
        if let cell = tableView?.cellForRow(at: ip) as? TextInputCell {
            cell.textField.text = text
        }
    }
    
}


extension CardDetailsViewController: PreAuthDelegate {
    func authSuccessfulIn(sender: PreAuthViewController) {
        if UserViewModel.shared.haveSavedPaymentMethod() {
            performSegue(withIdentifier: "PaymentOverview", sender: true)
        } else {
            updateUserDetails()
            tableView.reloadData()
        }
    }
}


extension CardDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case haveAnAccount
        case firstName
        case lastName
        case email
        case password
        
        case cardDetailsHeader
        case cardNumber
        case securityCode
        case month
        case year
        case zipCode
        
        case saveCardDetailsHeader
        case saveCardDetails
        case reviewYourOrder
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("Bad section")
        }

        switch section {
        case .haveAnAccount, .firstName, .lastName, .email, .password:
            return ADApi.shared.store.isLoggedIn ? 0 : 1
        case .reviewYourOrder:
            return showsReviewYourOrderButton ? 1 : 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Bad section")
        }
        
        switch section {
        case .haveAnAccount:
            return haveAccountCell(tableView: tableView, indexPath: indexPath)
        case .firstName:
            return textCellIn(tableView: tableView, at: indexPath, for: .firstName)
        case .lastName:
            return textCellIn(tableView: tableView, at: indexPath, for: .lastName)
        case .email:
            return textCellIn(tableView: tableView, at: indexPath, for: .email)
        case .password:
            return passwordCellIn(tableView: tableView, at: indexPath)
        case .cardDetailsHeader:
            return tableView.dequeueReusableCell(withIdentifier: "CardDetailsHeader", for: indexPath)
        case .cardNumber:
            return textCellIn(tableView: tableView, at: indexPath, for: .cardNumber)
        case .securityCode:
            return textCellIn(tableView: tableView, at: indexPath, for: .securityCode)
        case .month:
            return textCellIn(tableView: tableView, at: indexPath, for: .month)
        case .year:
            return textCellIn(tableView: tableView, at: indexPath, for: .year)
        case .zipCode:
            return textCellIn(tableView: tableView, at: indexPath, for: .zipCode)

        case .saveCardDetailsHeader:
            return tableView.dequeueReusableCell(withIdentifier: "BigSeparator", for: indexPath)
        case .saveCardDetails:
            return tableView.dequeueReusableCell(withIdentifier: "SaveCardDetails", for: indexPath)
        case .reviewYourOrder:
            return tableView.dequeueReusableCell(withIdentifier: "ReviewYourOrder", for: indexPath)
        }
    }
    
    func haveAccountCell(tableView: UITableView, indexPath: IndexPath)->UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HaveAnAccount", for: indexPath)
        if let button = cell.viewWithTag(10) as? UIButton, let attr = button.attributedTitle(for: .normal) {
            let mutable = NSMutableAttributedString(attributedString: attr)
            mutable.setTextBlackWhite()
            let linkColor = UIColor(named: "LinkColor")!
            mutable.set(color: linkColor, on: "Sign In")
            button.setAttributedTitle(mutable, for: .normal)
        }
        return cell
    }
    
    
    func textCellIn(tableView: UITableView,
                    at indexPath: IndexPath,
                    for item: PaymentTextInputCell.CellType) -> PaymentTextInputCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextInput",
                                                 for: indexPath) as! PaymentTextInputCell
        cell.delegate = self
        let userIsSignedIn = viewModel?.store.isLoggedIn ?? false
        cell.set(cellType: item,
                 textContent: currentModelTextForTextCell(item: item),
                 userIsSignedIn: userIsSignedIn)
        
        let isNameOrEmail = (item == .firstName || item == .lastName || item == .email)
        if (viewModel?.store.isLoggedIn ?? true) && isNameOrEmail {
            cell.setEditable(false)
        } else {
            cell.setEditable(true)
        }
        
        return cell
    }

    
    func passwordCellIn(tableView: UITableView,
                        at indexPath: IndexPath) -> PaymentTextInputCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordInput", for: indexPath) as! PaymentTextInputCell
        cell.delegate = self
        let userIsSignedIn = viewModel?.store.isLoggedIn ?? false
        cell.set(cellType: .password,
                 textContent: currentModelTextForTextCell(item: .password),
                 userIsSignedIn: userIsSignedIn)
        return cell
    }

    
    func currentModelTextForTextCell(item: PaymentTextInputCell.CellType) -> String? {
        switch item {
        case .firstName:
            return viewModel?.firstName
        case .lastName:
            return viewModel?.lastName
        case .email:
            return viewModel?.email
        case .password:
            return viewModel?.password
        case .cardNumber:
            return viewModel?.cardNumber
        case .securityCode:
            return viewModel?.securityCode
        case .month:
            return viewModel?.month
        case .year:
            return viewModel?.year
        case .zipCode:
            return viewModel?.zipCode
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Bad section")
        }
        
        setFirstResponder(section: section)
    }
}


extension CardDetailsViewController: TextInputCellDelegate {
    
    func textFieldContentChangedTo(text: String?, sender: TextInputCell) {
        guard let senderCell = sender as? PaymentTextInputCell,
              let senderCellType = senderCell.cellType else { return }

        switch senderCellType {
        case .firstName:
            viewModel?.firstName = text
        case .lastName:
            viewModel?.lastName = text
        case .email:
            viewModel?.email = text
        case .password:
            viewModel?.password = text
        case .cardNumber:
            viewModel?.cardNumber = text
        case .securityCode:
            viewModel?.securityCode = text
        case .month:
            viewModel?.month = text
        case .year:
            viewModel?.year = text
        case .zipCode:
            viewModel?.zipCode = text
        }
    }
    
    
    func textFieldReturnTappedIn(sender: TextInputCell) {
        guard let senderCell = sender as? PaymentTextInputCell,
              let senderCellType = senderCell.cellType else { return }

        switch senderCellType {
        case .firstName:
            setFirstResponder(section: .lastName)
        case .lastName:
            setFirstResponder(section: .email)
        case .email:
            setFirstResponder(section: .password)
        case .password:
            setFirstResponder(section: .cardNumber)
        case .cardNumber:
            setFirstResponder(section: .securityCode)
        case .securityCode:
            setFirstResponder(section: .month)
        case .month:
            setFirstResponder(section: .year)
        case .year:
            setFirstResponder(section: .zipCode)
        case .zipCode:
            sender.textField.resignFirstResponder()
        }
    }
    
    func textFieldInputComplete(sender: TextInputCell) {
        guard let senderCell = sender as? PaymentTextInputCell,
              let senderCellType = senderCell.cellType else { return }
        
        switch senderCellType {
        case .month:
            setFirstResponder(section: .year)
        case .year:
            setFirstResponder(section: .zipCode)
        default:
            break
        }
    }
    
    func setFirstResponder(section: Section) {
        let nextCell = tableView?.cellForRow(at: IndexPath(row: 0, section: section.rawValue)) as? PaymentTextInputCell
        nextCell?.textField?.becomeFirstResponder()
    }
}

