//
//  ProxyImageView.swift
//  Rekall
//
//  Created by Ray Hunter on 26/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class ProxyImageView: UIImageView {

    var laidOut = false
    var targetUrl: URL?

    func setProxyImage(url: URL){
        if laidOut {
            setImageForCurrentSize(url: url)
        } else {
            targetUrl = url
        }
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        laidOut = true
        if let url = targetUrl {
            setImageForCurrentSize(url: url)
            targetUrl = nil
        }
    }

    private func setImageForCurrentSize(url: URL){
        let size = bounds.size
        let scale = UIScreen.main.scale
        let width = Int(size.width * scale)
        let height = Int(size.height * scale)
        //print("Setting image at size \(width) x \(height)")
        
        // Docker needs to access its host
        let targetUrlStr = url.absoluteString.replacingOccurrences(of: "0.0.0.0", with: "host.docker.internal")
        let resizeUrl = Environment.shared.imageResizeProxyUrl
        let urlStr = "\(resizeUrl)/fill/\(width)/\(height)/ce/1/plain/\(targetUrlStr)"
        //print("Requesting image: \(urlStr)")
        if let proxyUrl = URL(string: urlStr) {
            af_setImage(withURL: proxyUrl)
        } else {
            print("ERROR: Failed to create URL for image: \(urlStr)")
        }
    }
    
}
