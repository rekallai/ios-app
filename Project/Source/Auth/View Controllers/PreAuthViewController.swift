//
//  PreAuthViewController.swift
//  Rekall
//
//  Created by Steve on 7/12/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol PreAuthDelegate: class {
    func authSuccessfulIn(sender: PreAuthViewController)
}

class PreAuthViewController: UIViewController {

    weak var delegate: PreAuthDelegate?
    var showCancelButton = true
    var signUpFlow = true
    var paymentFlow = false
    let signInSegue = "SignInSegue"
    let signUpSegue = "SignUpSegue"
    var prefilledEmailAddress: String?
    
    var authViewModel: AuthViewModel?
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCancelButton ? addCancelButton() : nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AuthRootViewController {
            if segue.identifier == signInSegue {
                vc.signUpFlow = false
            } else if segue.identifier == signUpSegue {
                vc.signUpFlow = true
            }
            vc.delegate = self
            vc.paymentFlow = paymentFlow
            vc.prefilledEmailAddress = prefilledEmailAddress
            if let authViewModel = authViewModel {
                vc.viewModel = authViewModel
            }
        }
    }
    
    func addCancelButton() {
        let barButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.setLeftBarButton(barButton, animated: true)
    }
    
    @objc func cancelTapped() {
        if signUpFlow {
            presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension PreAuthViewController: AuthDelegate {

    func authSuccessfulIn(sender: AuthRootViewController) {
        dismiss(animated: true)
        delegate?.authSuccessfulIn(sender: self)
    }

}
