//
//  PaymentConfirmationViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 30/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import PassKit

class PaymentConfirmationViewController: UIViewController {
    
    @IBOutlet var confirmationDetailsLabel: UILabel!
    @IBOutlet var buttonStackView: UIStackView!
    @IBOutlet var completeAccountSetupButton: BorderButton!
    
    var viewModel: PaymentViewModel?
    var passkitViewModel = PassViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(doneButtonTapped(sender:)))
        
        confirmationDetailsLabel.text = NSLocalizedString("""
        We’ll send a confirmation to \(viewModel?.email ?? "")
        For quick access, add the tickets to your Apple Wallet.
        """, comment: "User text ")
        
        let showCompleteButton = (viewModel?.didCreatePasswordlessAccountDuringPurchase() ?? true)
        completeAccountSetupButton.isHidden = !showCompleteButton

        if PKAddPassesViewController.canAddPasses() {
            let passButton = PKAddPassButton(addPassButtonStyle: .black)
            passButton.addTarget(self,
                                 action: #selector(addPassButtonTapped(sender:)),
                                 for: .touchUpInside)
            buttonStackView.insertArrangedSubview(passButton, at: 0)
        }
        
        passkitViewModel.onSuccess = { [weak self] passes in
            guard let vc = PKAddPassesViewController(passes: passes) else {
                self?.showError(error: NSLocalizedString("Unable to create pass", comment: "Error"))
                return
            }
            
            self?.present(vc, animated: true, completion: nil)
        }
        
        
        passkitViewModel.onFailure = { [weak self] errorStr in
            self?.showError(error: errorStr)
        }
    }
    
    
    @objc func doneButtonTapped(sender: UIBarButtonItem){
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func addPassButtonTapped(sender: UIButton) {
        guard let idsAndAuthCodes = viewModel?.getPassesIdsAndAuthTokens() else {
            print("ERROR: No pass serial numbers available")
            return
        }

        passkitViewModel.loadPasses(idsAndAuthCodes: idsAndAuthCodes)
    }


    @IBAction func completeAccountSetupTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? UINavigationController,
            let preAuthVC = vc.viewControllers.first as? PreAuthViewController else {
                print("ERROR: failed in instantiate VC from SB")
                return
        }
        
        preAuthVC.authViewModel = viewModel?.authViewModel
        preAuthVC.paymentFlow = true
        present(vc, animated: true)
    }
}
