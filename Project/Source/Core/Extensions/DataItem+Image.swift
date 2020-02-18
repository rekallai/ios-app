//
//  DataItem+Image.swift
//  Rekall
//
//  Created by Steve on 9/16/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import AlamofireImage

extension DataItem {
    
    func firstCachedImage()->UIImage? {
        let downloder = UIImageView.af_sharedImageDownloader
        let cache = downloder.imageCache
        guard let url = imageUrls?.first else { return nil }
        let req = URLRequest(url: url)
        if let img = cache?.image(for: req, withIdentifier: nil) {
            return img
        }
        return nil
    }
    
}
