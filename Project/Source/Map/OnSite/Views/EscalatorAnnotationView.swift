//
//  EscalatorAnnotationView.swift
//  Rekall
//
//  Created by Ray Hunter on 20/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

class EscalatorAnnotationView: MKAnnotationView {
    
    static let identifier = "EscalatorAnnotationView"

    let imageView = UIImageView()
    
    private let largeSize = CGSize(width: 60.0, height: 66.0)
    private let smallSize = CGSize(width: 29.0, height: 32.0)

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        guard let image = UIImage(named: "MapsIconEscalator") else {
            return
        }
        
        imageView.image = image
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y,
                            width: image.size.width, height: image.size.height)
        addSubview(imageView)
        imageView.frame = bounds
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setAs(elevator: Bool){
        guard let image = UIImage(named: elevator ? "MapsIconElevator" : "MapsIconEscalator") else {
            return
        }

        imageView.image = image
    }
}
