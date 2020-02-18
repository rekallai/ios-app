//
//  EditDetailsViewController.swift
//  Rekall
//
//  Created by Steve on 9/10/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

enum EditDetailCells: Int, CaseIterable {
    case firstName
    case lastName
    case email
}

class EditDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let userViewModel = UserViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProfileEditHeaderView.nib, forHeaderFooterViewReuseIdentifier: ProfileEditHeaderView.identifier)
        
        userViewModel.onUpdateUserSuccess = { [weak self] in
            self?.hideProgress() {
                self?.performSegue(withIdentifier: "UnwindEditDetailSegue", sender: self)
            }
        }
        userViewModel.onUpdateUserFailure = { [weak self] error in
            self?.hideProgress()
            self?.showError(error: error)
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let firstName = getText(.firstName), let lastName = getText(.lastName), let email = getText(.email) {
            if email.count >= 5 && email.isValidEmailAddress() {
                showProgress()
                userViewModel.updateDetails(firstName: firstName, lastName: lastName, email: email)
            } else {
                showError(error: NSLocalizedString("Please enter a valid email address.",
                comment: "Error message"))
            }
        }
    }
    
    func getText(_ cellType: EditDetailCells)->String? {
        let ip = IndexPath(row: cellType.rawValue, section: 0)
        if let cell = tableView.cellForRow(at: ip) as? ProfileEditCell {
            return cell.textField.text
        } else { return nil }
    }
    
}

extension EditDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditDetailCells.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let row = EditDetailCells(rawValue: indexPath.row) else {
            fatalError("No EditDetailCell row")
        }
        
        switch row {
        case .firstName:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEditCell.identifier, for: indexPath) as! ProfileEditCell
            cell.titleLabel.text = NSLocalizedString("First Name", comment: "Label")
            cell.textField.text = userViewModel.user.firstName
            return cell
        case .lastName:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEditCell.identifier, for: indexPath) as! ProfileEditCell
            cell.titleLabel.text = NSLocalizedString("Last Name", comment: "Label")
            cell.textField.text = userViewModel.user.lastName
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEditCell.identifier, for: indexPath) as! ProfileEditCell
            cell.titleLabel.text = NSLocalizedString("Email", comment: "Label")
            cell.textField.text = userViewModel.user.email
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == EditDetailCells.firstName.rawValue {
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProfileEditHeaderView")
        } else { return nil }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}
