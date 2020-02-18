//
//  MapOffsiteMallOverview.swift
//  Rekall
//
//  Created by Steve on 8/19/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

class MapOffsiteMallOverview: UITableViewHeaderFooterView, MKMapViewDelegate {
    
    static let identifier = "MapOffsiteMallOverview"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet var mapView: MKMapView?
    let centerOfMall = CLLocationCoordinate2D(latitude: 40.808588171873915, longitude: -74.06861610577003)
    var pointingNorth = true
    var animating = true
    var distanceToCenterPoint = 1000.0
    
    func setAnimating(on: Bool) {
        if on == animating { return }
        animating = on
        
        if animating {
            let camera = MKMapCamera(lookingAtCenter: centerOfMall,
                                     fromDistance: distanceToCenterPoint,
                                     pitch: 53.0,
                                     heading: 0.0)
            mapView?.camera = camera
            direction = Direction.north
            
            animate()
        }
    }

    var started = false
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIScreen.main.bounds.width < 370 {
            distanceToCenterPoint = 915.0
        }
        if mapView == nil { return }
        if !started {
            started = true
            startup()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func startup() {
        //self.isUserInteractionEnabled = false

        mapView?.delegate = self
        mapView?.showsCompass = false
        mapView?.showsPointsOfInterest = false
        mapView?.showsUserLocation = false
        mapView?.showsTraffic = false
        
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(didTapMapView(sender:)))
        self.addGestureRecognizer(tapGr)
        
        mapView?.isUserInteractionEnabled = false
        let camera = MKMapCamera(lookingAtCenter: centerOfMall,
                                 fromDistance: distanceToCenterPoint,
                                 pitch: 53.0,
                                 heading: 0.0)
        mapView?.camera = camera
    }
    
    // https://gspe21-ssl.ls.apple.com/html/attribution-144.html
    @objc func didTapMapView(sender: UITapGestureRecognizer){
        let location = sender.location(in: mapView)
        guard let mapView = mapView,
        location.x > mapView.frame.width - 60, location.y > mapView.frame.height - 30 else { return }
        
        UIApplication.shared.open(URL(string: "https://gspe21-ssl.ls.apple.com/html/attribution-144.html")!,
                                  options: [:],
                                  completionHandler: nil)
    }
    
    enum Direction {
        case north
        case east
        case south
        case west
    }
    
    var direction = Direction.west
    
    var inAnimation = false
    func animate() {
        if inAnimation {
            return
        }
        
        var nextDir = 0.0
        switch direction {
        case .north:
            nextDir = 270.0
        case .east:
            nextDir = 180.0
        case .south:
            nextDir = 90.0
        case .west:
            nextDir = 0.0
        }
        
        /*guard let heading = mapView?.camera.heading else { return }
        let degreesToGo = abs(nextDir - heading)
        let percentToGo = degreesToGo / 90.0
        let timeToGo = percentToGo * 10.0*/
        
        //print("Pointing: \(nextDir)")
        
        inAnimation = true
        MKMapView.animate(withDuration: 10.0,
                          delay: 0.0,
                          options: .curveLinear,
                          animations: { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let camera = MKMapCamera(lookingAtCenter: strongSelf.centerOfMall,
                                     fromDistance: strongSelf.distanceToCenterPoint,
                                     pitch: 53.0,
                                     heading: nextDir)
            strongSelf.mapView?.camera = camera
        }) { [weak self] finished in
            guard let strongSelf = self else { return }
            strongSelf.inAnimation = false
            
            if finished {
                switch strongSelf.direction {
                case .north:
                    strongSelf.direction = .east
                case .east:
                    strongSelf.direction = .south
                case .south:
                    strongSelf.direction = .west
                case .west:
                    strongSelf.direction = .north
                }
            }
            
            if strongSelf.animating {
                strongSelf.animate()
            }
        }
    }
    
    
    var haveFinishedLoading = false
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        //animate(advance: true)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        guard !haveFinishedLoading else { return }
        haveFinishedLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.animate()
        }
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        if #available(iOS 13.0, *) {
//print("Center: \(mapView.centerCoordinate), pitch: \(mapView.camera.pitch), dist: \(mapView.camera.centerCoordinateDistance)")
        }
    }
}
