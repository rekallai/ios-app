//
//  FinishViewController.swift
//  Rekall
//
//  Created by Steve on 10/3/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class FinishViewController: UIViewController {
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        if let vc = UIStoryboard.auth() {
            vc.signUpFlow = true
            vc.onboardFlow = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func finishButtonTapped(_ sender: Any) {
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
