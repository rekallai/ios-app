//
//  UIViewController+Errors.swift
//  Rekall
//
//  Created by Ray Hunter on 26/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import JGProgressHUD

extension UIViewController {
    
    func showError(error: String) {
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: "Error message alert title"),
                                   message: error,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Button title"),
                                   style: .default,
                                   handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func showProgress() {
        _ = ADActivitySpinner(targetView: self.view)
    }
    
    func hideProgress(completion: (() -> ())? = nil) {
        for v in view.subviews {
            if let hud = v as? ADActivitySpinner {
                hud.dismiss(completion: completion)
            }
        }
    }
}
