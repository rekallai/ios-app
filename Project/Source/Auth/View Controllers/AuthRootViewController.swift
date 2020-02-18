//
//  AuthRootViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 06/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol AuthDelegate: class {
    func authSuccessfulIn(sender: AuthRootViewController)
}

class AuthRootViewController: UIViewController, UITextFieldDelegate {
    weak var delegate: AuthDelegate?
    
    @IBOutlet var tableView: UITableView!
    
    var signUpFlow = true
    var paymentFlow = false
    var onboardFlow = false
    var prefilledEmailAddress: String?

    var viewModel = AuthViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    var purchasedOrdersViewModel = PurchasedOrdersViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    
    private var userUpdated = false
    private var ticketsUpdated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ButtonCell.nib, forCellReuseIdentifier: ButtonCell.identifier)
        
        if !signUpFlow {
            navigationItem.title = NSLocalizedString("Sign In",
                                                     comment: "Navigation Title")
        }
        
        if let prefilledEmailAddress = prefilledEmailAddress {
            viewModel.email = prefilledEmailAddress
        }
    }
    
    func signInTapped() {
        guard let userPassword = viewModel.password,
              userPassword.count >= 6 else {
                showError(error: NSLocalizedString("Please enter a password at least 6 characters long.",
                                                   comment: "Error message"))
                return
        }
        
        viewModel.onUpdateSuccess = { [weak self] in
            // We're 2 levels deep
            self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        viewModel.onUpdateFailure = { [weak self] errorStr in
            self?.showError(error: errorStr)
        }
        
        UserViewModel.shared.onUpdateUserSuccess = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.userUpdated = true
            strongSelf.checkLoginComplete()
        }
        
        UserViewModel.shared.onUpdateUserFailure = { [weak self] errorStr in
            self?.hideProgress()
            self?.showError(error: errorStr)
        }
        
        viewModel.onLoginSuccess = { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.userUpdated = false
            strongSelf.ticketsUpdated = false

            strongSelf.purchasedOrdersViewModel.reloadTicketsFromBackend()
            UserViewModel.shared.loadUser()
        }
        
        viewModel.onLoginFailure = { [weak self] errorStr in
            self?.hideProgress()
            self?.showError(error: errorStr)
        }
        
        viewModel.onRegisterSuccess = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.hideProgress() {
                if strongSelf.onboardFlow {
                    strongSelf.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                } else {
                    strongSelf.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        viewModel.onRegisterFailure = { [weak self] error in
            self?.hideProgress()
            self?.showError(error: error.localizedDescription)
        }

        purchasedOrdersViewModel.onUpdateSuccess = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.ticketsUpdated = true
            strongSelf.checkLoginComplete()
        }
        
        purchasedOrdersViewModel.onUpdateFailure = { [weak self] errorStr in
            self?.hideProgress()
            self?.showError(error: errorStr)
        }
        
        if signUpFlow {
            viewModel.password = userPassword
            
            //
            // Is we're signing up during the payment flow, the assumption is that the user has actually created
            // a passwordless account and we're just patching the account with a new password.
            //
            if paymentFlow {
                viewModel.updateUser()
            } else {
                viewModel.submitRegister()
                showProgress()
            }
        } else {
            guard viewModel.email.count >= 5 else {
                showError(error: NSLocalizedString("Please enter an email address.",
                                                   comment: "Error message"))
                return
            }
            
            viewModel.submitLogin(email: viewModel.email, password: userPassword)
            showProgress()
        }
    }
    
    func checkLoginComplete() {
        guard userUpdated, ticketsUpdated else {
            return
        }
        
        delegate?.authSuccessfulIn(sender: self)
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        let url = URL(string: Environment.shared.shareBaseUrl + "/forgot-password")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


extension AuthRootViewController: UITableViewDelegate, UITableViewDataSource {
    enum Section: Int, CaseIterable {
        case firstName
        case lastName
        case email
        case password
        case button
        case forgotPassword
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("FATALERROR: Unrecognized section")
        }
        
        switch section {
        case .firstName, .lastName:
            return signUpFlow ? 1 : 0
        case .forgotPassword:
            return signUpFlow ? 0 : 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("FATALERROR: Unrecognized section")
        }
        
        switch section {
        case .firstName:
            let cell = configTextCell(tv: tableView, ip: indexPath)
            cell.set(cellType: .firstName, textContent: viewModel.firstName)
            return cell
        case .lastName:
            let cell = configTextCell(tv: tableView, ip: indexPath)
            cell.set(cellType: .lastName, textContent: viewModel.lastName)
            return cell
        case .email:
            let cell = configTextCell(tv: tableView, ip: indexPath)
            cell.set(cellType: .email, textContent: viewModel.email)
            return cell
        case .password:
            let cell = configTextCell(tv: tableView, ip: indexPath)
            cell.set(cellType: .password, textContent: nil)
            return cell
        case .button:
            return configButton(tv: tableView, ip: indexPath)
        case .forgotPassword:
            return tableView.dequeueReusableCell(withIdentifier: "ForgotPassword", for: indexPath)
        }
    }
}

extension AuthRootViewController {
    
    func configTextCell(tv: UITableView, ip: IndexPath)->AuthTextInputCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "TextInput", for: ip) as! AuthTextInputCell
        cell.delegate = self
        return cell
    }
    
    func configButton(tv: UITableView, ip: IndexPath)->ButtonCell {
        let cell = tv.dequeueReusableCell(withIdentifier: ButtonCell.identifier, for: ip) as! ButtonCell
        let title = signUpFlow ? NSLocalizedString("Create Account", comment: "Title") : NSLocalizedString("Sign In", comment: "Title")
        cell.button.setTitle(title, for: .normal)
        cell.delegate = self
        return cell
    }
    
}

extension AuthRootViewController: ButtonCellDelegate {
    
    func buttonCellTapped(cell: ButtonCell) {
        signInTapped()
    }
    
}

extension AuthRootViewController: TextInputCellDelegate {
    func textFieldReturnTappedIn(sender: TextInputCell) {
        guard let senderCell = sender as? AuthTextInputCell,
              let cellType = senderCell.cellType else {
                return
        }
        
        switch cellType {
        case .firstName:
            setFirstResponder(section: .lastName)
        case .lastName:
            setFirstResponder(section: .email)
        case .email:
            setFirstResponder(section: .password)
        case .password:
            sender.textField.resignFirstResponder()
        }
    }
    
    func setFirstResponder(section: Section) {
        guard let nextCell = tableView?.cellForRow(at: IndexPath(row: 0, section: section.rawValue))
        as? AuthTextInputCell else {
            return
        }
        
        nextCell.textField?.becomeFirstResponder()
    }
    
    func textFieldContentChangedTo(text: String?, sender: TextInputCell) {
        guard let senderCell = sender as? AuthTextInputCell,
              let cellType = senderCell.cellType,
              let text = text else {
                return
        }

        switch cellType {
        case .firstName:
            viewModel.firstName = text
        case .lastName:
            viewModel.lastName = text
        case .email:
            viewModel.email = text
        case .password:
            viewModel.password = text
        }
    }
}
