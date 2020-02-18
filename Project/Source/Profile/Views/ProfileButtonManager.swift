//
//  ProfileButtonManager.swift
//  Rekall
//
//  Created by Steve on 8/7/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol ProfileButtonDelegate: class {
    func profileButtonTapped()
}

class ProfileButtonManager: NSObject {
    struct Constant {
        static let rightMargin: CGFloat = 14.0
        static let heightLarge: CGFloat = 32.0
        static let heightSmall: CGFloat = 24.0
        static let bottomMarginLarge: CGFloat = 12.0
        static let bottomMarginSmall: CGFloat = 12.0
        static let navBarHeightSmall: CGFloat = 44.0
        static let navBarHeightLarge: CGFloat = 96.5
    }
    
    weak var delegate: ProfileButtonDelegate?
    var button = UIButton(type: .custom)
    var navBar: UINavigationBar?
    var image = UIImage(named: "ProfileIcon")
    
    init(navBar: UINavigationBar) {
        super.init()
        self.navBar = navBar
        navBar.addSubview(button)
        setUpButton()
    }
    
    public func shouldDisplay(_ display: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.button.alpha = display ? 1.0 : 0.0
            self.button.isEnabled = display
        }
    }
    
    public func moveResize() {
        guard let navBar = navBar else { return }
        let height = navBar.frame.height
        
        let coeff = calcCoeff(height: height)
        let factor = Constant.heightSmall / Constant.heightLarge
        let scale = calcScale(coeff: coeff, factor: factor)
        let sizeDiff = Constant.heightLarge * (1.0 - factor)
        let yTranslation = calcYTranslation(sizeDiff: sizeDiff, coeff: coeff)
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        button.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    private func setUpButton() {
        button.contentMode = .scaleAspectFill
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(
            self,
            action: #selector(profileButtonTapped),
            for: .touchUpInside
        )
        button.layer.cornerRadius = Constant.heightLarge/2
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        setButtonConstraints()
    }
    
    private func setButtonConstraints() {
        if let navBar = navBar {
            NSLayoutConstraint.activate([
                button.rightAnchor.constraint(equalTo: navBar.rightAnchor, constant: -Constant.rightMargin),
                button.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -Constant.bottomMarginLarge),
                button.heightAnchor.constraint(equalToConstant:Constant.heightLarge),
                button.widthAnchor.constraint(equalTo: button.heightAnchor)
            ])
        }
    }
    
    private func calcCoeff(height: CGFloat)->CGFloat {
        let delta = height - Constant.navBarHeightSmall
        let heightDiff = (Constant.navBarHeightLarge - Constant.navBarHeightSmall)
        return delta / heightDiff
    }
    
    private func calcScale(coeff: CGFloat, factor: CGFloat)->CGFloat {
        let sizeFactor = coeff * (1.0 - factor)
        return min(1.0, sizeFactor + factor)
    }
    
    private func calcYTranslation(sizeDiff: CGFloat, coeff: CGFloat)->CGFloat {
        let maxYTranslation = Constant.bottomMarginLarge - Constant.bottomMarginSmall + sizeDiff
        return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Constant.bottomMarginSmall + sizeDiff))))
    }
    
    @objc func profileButtonTapped() {
        delegate?.profileButtonTapped()
    }
    
}
