//
//  LinkTextView.swift
//  Rekall
//
//  Created by Steve on 7/23/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

@IBDesignable class LinkTextView: UITextView {

    override func awakeFromNib() {
        super.awakeFromNib()
        isScrollEnabled = false
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }

}
