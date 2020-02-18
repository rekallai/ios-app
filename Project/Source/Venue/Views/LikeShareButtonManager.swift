//
//  LikeShareButtonManager.swift
//  Rekall
//
//  Created by Steve on 7/3/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol LikeShareButtonManagerDelegate: class {
    func shareButtonTapped()
    func likeButtonTapped()
}

class LikeShareButtonManager {
    
    weak var delegate: LikeShareButtonManagerDelegate?
    var shareButton: UIBarButtonItem?
    var likeButton: UIBarButtonItem?
    
    init() {
        if Defines.venueSharingEnabled {
            setShareButton()
        }
        setLikeButton(isFavorited: false)
    }
    
    func buttons(isFavorited: Bool)->[UIBarButtonItem] {
        setLikeButton(isFavorited: isFavorited)
        var buttons = [UIBarButtonItem]()
        
        if let shareButton = shareButton { buttons.append(shareButton) }
        if let likeButton = likeButton { buttons.append(likeButton) }
        
        return buttons
    }
    
    func setLikeButton(isFavorited: Bool) {
        let favImg = isFavorited ? "HeartFilledIcon" : "HeartIcon"
        let image = UIImage(named: favImg)
        likeButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(likeTapped))
    }
    
    func setShareButton() {
        let image = UIImage(named: "ShareAction")
        shareButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(shareTapped))
    }
    
    @objc func shareTapped() {
        delegate?.shareButtonTapped()
    }
    
    @objc func likeTapped() {
        delegate?.likeButtonTapped()
    }
    
}
