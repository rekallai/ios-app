//
//  QRGenerator.swift
//  Rekall
//
//  Created by Steve on 7/16/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreImage

class QRGenerator {
    let qrCode:String
    var image:UIImage?
    
    init(qr:String) {
        qrCode = qr
        process()
    }
    
    private func process() {
        if let qrData = qrCode.data(using: String.Encoding.ascii) {
            guard let qrImage = filteredImage(qrData: qrData) else { return }
            let scaledImage = scaleImage(qrImage)
            image = outputImage(scaledImage)
        }
    }
    
    private func filteredImage(qrData:Data)->CIImage? {
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(qrData, forKey: "inputMessage")
            guard let qrImage = filter.outputImage else { return nil }
            return qrImage
        } else { return nil }
    }
    
    private func scaleImage(_ image:CIImage)->CIImage {
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        return image.transformed(by: transform)
    }
    
    private func outputImage(_ image:CIImage)->UIImage? {
        let context = CIContext()
        guard let cgImage = context.createCGImage(
            image, from: image.extent
        ) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
}
