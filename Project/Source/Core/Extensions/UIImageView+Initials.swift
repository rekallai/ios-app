//
//  UIImageView+Initials.swift
//  Rekall
//
//  Created by Steve on 9/10/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setInitials(name: String) {
        if let image = createInitialsImage(name: name.initials()) {
            self.image = image
        }
    }
    
    private func createInitialsImage(name: String)->UIImage? {
        let fillColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        let scale = UIScreen.main.scale
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        let path = CGPath(ellipseIn: bounds, transform: nil)
        context?.addPath(path)
        context?.clip()
        context?.setFillColor(fillColor.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let font = UIFont.systemFont(ofSize: 36.0, weight: .semibold)
        let attrs = [NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: font]
        
        let textSize = name.size(withAttributes: attrs)
        let x = bounds.size.width/2 - textSize.width/2
        let y = bounds.size.height/2 - textSize.height/2
        let rect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
        name.draw(in: rect, withAttributes: attrs)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
