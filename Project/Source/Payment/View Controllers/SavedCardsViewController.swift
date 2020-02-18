//
//  SavedCardsViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 10/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol SavedCardsDelegate: class {
    func savedCardWasModified(sender: SavedCardsViewController)
}

class SavedCardsViewController: UIViewController {
    
    var viewModel: PaymentViewModel?
    weak var delegate: SavedCardsDelegate?

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cardDetailsVC = segue.destination as? CardDetailsViewController {
            cardDetailsVC.viewModel = viewModel
        }
    }
    
    @IBAction func removeButtonTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = NSLocalizedString("Remove", comment: "Button title")
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = NSLocalizedString("Done", comment: "Button title")
        }
    }
}

extension SavedCardsViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int, CaseIterable {
        case chooseCardHeader
        case savedCard
        case bigSeparator
        case enterNewCard
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("Invalid Section")
        }
        
        switch section {
        case .chooseCardHeader, .bigSeparator, .enterNewCard:
            return 1
        case .savedCard:
            return UserViewModel.shared.numberOfSavedPaymentMethods()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid Section")
        }

        switch section {
        case .chooseCardHeader:
            return tableView.dequeueReusableCell(withIdentifier: "ChoosePaymentCardHeader", for: indexPath)
        case .savedCard:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath)
                as! PaymentTextDisplayCell
            cell.titleLabel.text = UserViewModel.shared.savedPaymentSummaryDetailsAt(index: indexPath.row)
            cell.accessoryType = .none
            return cell
        case .bigSeparator:
            return tableView.dequeueReusableCell(withIdentifier: "BigSeparator", for: indexPath)
        case .enterNewCard:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath)
                as! PaymentTextDisplayCell
            cell.titleLabel.text = NSLocalizedString("Enter new card details", comment: "Credit card entry")
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid Section")
        }

        switch section {
        case .savedCard:
            UserViewModel.shared.setSelectedExistingPaymentCard(index: indexPath.row)
            delegate?.savedCardWasModified(sender: self)
            navigationController?.popViewController(animated: true)
            break
        case .enterNewCard:
            performSegue(withIdentifier: "NewCardDetails", sender: self)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        showProgress()
        UserViewModel.shared.onDeleteCardSuccess = { [weak self] in
            self?.hideProgress()
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if let strongSelf = self {
                strongSelf.delegate?.savedCardWasModified(sender: strongSelf)
            }
        }
        
        UserViewModel.shared.onDeleteCardFailure = { [weak self] errorStr in
            self?.hideProgress()
            self?.showError(error: errorStr)
        }
        
        UserViewModel.shared.deleteSavedPaymentMethodAt(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == Section.savedCard.rawValue
    }
    
}
