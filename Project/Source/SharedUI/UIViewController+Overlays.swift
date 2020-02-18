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
    
    func showiOS13Required() {
        let ac = UIAlertController(title: NSLocalizedString("Update Required", comment: "Error message alert title"),
                                   message: NSLocalizedString("The onsite map reqires iOS 13 or above",
                                                              comment: "Error message content"),
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Not Now", comment: "Button title"),
                                   style: .default,
                                   handler: nil))
        ac.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Button title"),
                                   style: .default,
                                   handler: { action in
            if let url = URL.init(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
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
