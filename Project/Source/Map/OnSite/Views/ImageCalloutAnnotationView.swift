//
//  ImageCalloutAnnotationView.swift
//  Rekall
//
//  Created by Ray Hunter on 05/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

@available(iOS 13.0, *)
class ImageCalloutAnnotationView: MKAnnotationView {
    
    static let identifier = "ImageCalloutAnnotationView"
    
    let imageView = UIImageView()
    let label = UILabel()
    
    private let largeSizeWithoutLabel = CGSize(width: 60.0, height: 66.0)
    private let largeSizeWithLabel = CGSize(width: 60.0, height: 80.0)
    private let smallSize = CGSize(width: 29.0, height: 32.0)
    private let labelOverhang: CGFloat = 20.0

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: largeSizeWithoutLabel.width,
                            height: largeSizeWithoutLabel.height)
        addSubview(imageView)
        imageView.frame = bounds
        imageView.backgroundColor = .clear
        backgroundColor = .clear
        imageView.image = UIImage(named: "MapsPinRestroom")
        setToLargeSize(large: false)
        
        addSubview(label)
        label.font = UIFont(name: "SFProDisplay-Semibold", size: 10.0, color: UIColor.black)
        label.frame = CGRect(x: -labelOverhang,
                             y: largeSizeWithoutLabel.height,
                             width: largeSizeWithLabel.width + (labelOverhang * 2),
                             height: largeSizeWithLabel.height - largeSizeWithoutLabel.height)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.minimumScaleFactor = 0.75
    }
    
    override open var annotation: MKAnnotation? {
        didSet{
            label.text = annotation?.title ?? nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setToLargeSize(large: Bool) {
        UIView.animate(withDuration: 0.3) {
            if large {
                self.transform = CGAffineTransform.identity
                self.centerOffset = CGPoint(x: 0, y: -(self.largeSizeWithoutLabel.height / 2.0))
                
                if self.annotation is Occupant {
                    self.label.alpha = 1.0
                }
            } else {
                self.transform = CGAffineTransform(scaleX: self.smallSize.width / self.largeSizeWithoutLabel.width,
                                                   y: self.smallSize.height / self.largeSizeWithoutLabel.height)
                self.centerOffset = CGPoint(x: 0, y: -(self.smallSize.height / 2.0))
                self.label.alpha = 0.0
            }
        }
    }
}
