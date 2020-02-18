//
//  KeyboardAwareViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 25/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class KeyboardAwareViewController: UIViewController {
    
    var keyboardAwareScrollView: UIScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            keyboardAwareScrollView?.contentInset = insets
            keyboardAwareScrollView?.scrollIndicatorInsets = insets
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        keyboardAwareScrollView?.contentInset = .zero
        keyboardAwareScrollView?.scrollIndicatorInsets = .zero
    }
}
