//
//  UITapGestureRecognizer+UILabelTaps.swift
//  Rekall
//
//  Created by Ray Hunter on 20/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension UITapGestureRecognizer {
    
    func didTap(subString: String, in label: UILabel) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        guard let labelText = label.text, let targetRange = labelText.range(of: subString) else {
            return false
        }
        
        let startIndex = labelText.distance(from: labelText.startIndex, to: targetRange.lowerBound)
        let endIndex = labelText.distance(from: labelText.startIndex, to: targetRange.upperBound)
        
        return startIndex <= indexOfCharacter && indexOfCharacter < endIndex
    }

}
