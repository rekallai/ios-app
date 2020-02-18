//
//  MapImageViewController.swift
//  Rekall
//
//  Created by Steve on 8/22/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

class MapImageViewController: UIViewController {
    
    var viewModel:OffsiteMapViewModel?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpOpenMaps()
        scrollView.delegate = self
        setZoomScales()
    }
    
    func setZoomScales() {
        scrollView.maximumZoomScale = 7.0
        if let img = imageView.image {
            let zoomScale = view.bounds.size.height / img.size.height
            self.scrollView.minimumZoomScale = zoomScale
            self.scrollView.zoomScale = zoomScale
        }
    }
    
    func setUpOpenMaps() {
        let button = UIBarButtonItem(title: "Open Maps", style: .plain, target: self, action: #selector(openMaps))
        navigationItem.rightBarButtonItems = [button]
    }
    
    @objc func openMaps() {
        if let mapItems = viewModel?.mapItems() {
            MKMapItem.openMaps(with: mapItems, launchOptions: [:])
        }
    }
    
    @IBAction func imgDoubleTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: imageView)
        let newScale = CGFloat(3.3)
        let newRect = zoom(scrollView: scrollView, scale: newScale, center: location)
        scrollView.zoom(to: newRect, animated: true)
    }
    
    func zoom(scrollView: UIScrollView,scale: CGFloat,center: CGPoint)->CGRect {
        var zoomRect = CGRect()
        
        zoomRect.size.height = scrollView.frame.size.height / scale
        zoomRect.size.width = scrollView.frame.size.width / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
}

extension MapImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

}
