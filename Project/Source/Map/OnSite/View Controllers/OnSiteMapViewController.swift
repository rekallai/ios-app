//
//  OnSiteMapViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 16/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

@available(iOS 13.0, *)
class OnSiteMapViewController: UIViewController {
    
    var updatable: CDUpdateMonitor<Venue>?
    var destinationVenue: Venue? {      // For single venue interaction
        set {
            updatable = nil
            if let venue = newValue {
                updatable = CDUpdateMonitor(cdItem: venue)
            }
        }
        get {
            return updatable?.cdItem
        }
    }
    
    var debugOnsitePolygon: MKPolygon? {
        didSet {
            if let previous = oldValue {
                mapView.removeOverlay(previous)
            }
            if let debugOnsitePolygon = debugOnsitePolygon {
                mapView.addOverlay(debugOnsitePolygon)
            }
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var levelPicker: LevelPickerView!
    
    var mapDbgFloorLabel: UILabel?
    private var TAP_UPDATES_USER_LOCATION = false
    
    private let DEFAULT_FLOOR_ORDINAL = 1
    private var venue: MapVenue?
    private var currentDisplayLevelOrdinal = 0
    private var levels: [Level] = []
    private var currentLevelFeatures = [StylableFeature]()
    private var currentLevelOverlays = [MKOverlay]()
    private var currentLevelOccupantList = OccupantList()
    private var currentLevelAmentities = [Amenity]()
    
    private var persistentDrawerVC: PersistentDrawerViewController?
    private var currentHighlightedCategory: Amenity.Category?
    private var destinationVenueOccupant: Occupant?
    
    private let routing = JibestreamRouting()
    private var lastRoutingDestination: AnnotationMetadata?
    private var currentRoute: Route?
    private var currentDirections: Directions?
    private var currentRoutingLines = [MKPolyline]()
    private var highlightedRouteEscalatorOverlay: MKOverlay?
    private var highlightedRouteElevatorOverlay: MKOverlay?
    private var highlightedRouteEscalatorAnnotation: MKAnnotation?
    private var highlightedRouteElevatorAnnotation: MKAnnotation?
    
    private var hidesNavigationBarOnViewDidAppear = false
    private var headingImageView: UIImageView?
    private var locationManager: CLLocationManager?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        let centerOfMall = CLLocationCoordinate2D(latitude: 40.8075639, longitude: -74.0679438)
        let mallRegion = MKCoordinateRegion(center: centerOfMall, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: mallRegion)
        mapView.cameraBoundary = cameraBoundary
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.setRegion(mallRegion, animated: false)
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 10000.0)
        
        mapView.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: PointAnnotationView.identifier)
        mapView.register(LabelAnnotationView.self, forAnnotationViewWithReuseIdentifier: LabelAnnotationView.identifier)
        mapView.register(ImageCalloutAnnotationView.self, forAnnotationViewWithReuseIdentifier: ImageCalloutAnnotationView.identifier)
        mapView.register(EscalatorAnnotationView.self, forAnnotationViewWithReuseIdentifier: EscalatorAnnotationView.identifier)
        
        setupImdf()
        
        if Defines.navigationEnabled || !hasImplicitVenue() {
            performSegue(withIdentifier: "ShowPersistentDrawer", sender: self)
        }
        
        if TAP_UPDATES_USER_LOCATION {
            let tapGr = UITapGestureRecognizer(target: self, action: #selector(tapDetected(_:)))
            mapView.addGestureRecognizer(tapGr)

        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingHeading()
    }
    
    @objc func tapDetected(_ tapGr: UITapGestureRecognizer) {
        let tapLocation = tapGr.location(in: mapView)
        let coordinate = mapView.convert(tapLocation, toCoordinateFrom: mapView)
        
        print("Tapped location: \(coordinate.longitude), \(coordinate.latitude)")
        
        updateUsersPositionTo(newCoordinate: coordinate, floorLevel: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hidesNavigationBarOnViewDidAppear {
            navigationController?.setNavigationBarHidden(true, animated: true)
            hidesNavigationBarOnViewDidAppear = false
        }
    }
    
    private func setupImdf(){
        // Decode the IMDF data. In this case, IMDF data is stored locally in the current bundle.
        let imdfDirectory = Bundle.main.resourceURL!.appendingPathComponent("IMDFData")
        do {
            let imdfDecoder = IMDFDecoder()
            venue = try imdfDecoder.decode(imdfDirectory)
        } catch let error {
            print(error)
        }
        
        // You might have multiple levels per ordinal. A selected level picker item displays all levels with the same ordinal.
        if let levelsByOrdinal = self.venue?.levelsByOrdinal {
            let levels = levelsByOrdinal.mapValues { (levels: [Level]) -> [Level] in
                // Choose indoor level over outdoor level
                if let level = levels.first(where: { $0.properties.outdoor == false }) {
                    return [level]
                } else {
                    return [levels.first!]
                }
            }.flatMap({ $0.value })
            
            // Sort levels by their ordinal numbers
            self.levels = levels.sorted(by: { $0.properties.ordinal < $1.properties.ordinal })
            currentLevelOccupantList.allLevels = self.levels
        }
        
        // Set the map view's region to enclose the venue
        if let venue = venue, let venueOverlay = venue.geometry[0] as? MKOverlay {
            self.mapView.setVisibleMapRect(venueOverlay.boundingMapRect, edgePadding:
                UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        }

        // Setup the level picker with the shortName of each level
        setupLevelPicker()

        if let destinationVenue = destinationVenue,
           destinationVenue.floorLevel >= 0 {
            showFeaturesForOrdinal(Int(destinationVenue.floorLevel))
            levelPicker.showButtonForSelectedIndex(selectedIndex: Int(destinationVenue.floorLevel),
                                                   animated: false)
            if let occupant = currentLevelOccupantList.occupantFor(venue: destinationVenue) {
                destinationVenueOccupant = occupant
                mapView.selectAnnotation(occupant, animated: true)
                mapView.region = MKCoordinateRegion(center: occupant.coordinate,
                                                    latitudinalMeters: 300,
                                                    longitudinalMeters: 300)
            }
        } else {
            showFeaturesForOrdinal(DEFAULT_FLOOR_ORDINAL)
            levelPicker.showButtonForSelectedIndex(selectedIndex: DEFAULT_FLOOR_ORDINAL, animated: false)
        }
    }
    
    
    private func showFeaturesForOrdinal(_ ordinal: Int) {
        guard let venue = self.venue else {
            return
        }
        
        currentDisplayLevelOrdinal = ordinal
        currentLevelOccupantList.currentLevel = ordinal

        // Clear out the previously-displayed level's geometry
        currentLevelFeatures.removeAll()
        mapView.removeOverlays(currentLevelOverlays)
        mapView.removeAnnotations(currentLevelAmentities)
        mapView.removeAnnotations(currentLevelOccupantList.occupants)
        currentLevelOccupantList.occupants.removeAll()
        currentLevelAmentities.removeAll()
        currentLevelOverlays.removeAll()
        
        highlightedRouteEscalatorOverlay = nil
        highlightedRouteElevatorOverlay = nil
        highlightedRouteEscalatorAnnotation = nil
        highlightedRouteElevatorAnnotation = nil
        
        currentLevelFeatures.append(venue)
        
        // Display the level's footprint, unit footprints, opening geometry, and occupant annotations
        guard ordinal < levels.count else {
            print("ERROR: Asked to display map data for ordinal \(ordinal), max is \(levels.count - 1)")
            return
        }
        
        let level = levels[ordinal]
        currentLevelFeatures.append(level)

        currentLevelFeatures += level.firstPassUnits
        currentLevelFeatures += level.fixtures
        //currentLevelFeatures += level.openings
        currentLevelFeatures += level.secondPassUnits
        currentLevelFeatures += level.kiosks

        // ToDo - decide when to use sections - neighbourhoods?
        //self.currentLevelFeatures += level.sections

        currentLevelOccupantList.occupants += level.firstPassUnits.flatMap{ $0.occupants }
        currentLevelOccupantList.occupants += level.secondPassUnits.flatMap{ $0.occupants }
        currentLevelAmentities += level.firstPassUnits.flatMap{ $0.amenities }
        currentLevelAmentities += level.secondPassUnits.flatMap{ $0.amenities }

        let currentLevelGeometry = currentLevelFeatures.flatMap({ $0.geometry })
        currentLevelOverlays = currentLevelGeometry.compactMap({ $0 as? MKOverlay })

        // Add the current level's geometry to the map
        mapView.addOverlays(currentLevelOverlays)
        mapView.addAnnotations(currentLevelOccupantList.occupants)
        mapView.addOverlays(currentRoutingLines)
        
        if let debugOnsitePolygon = debugOnsitePolygon {
            mapView.addOverlay(debugOnsitePolygon)
        }

        persistentDrawerVC?.currentLevelAmenities = currentLevelAmentities
        persistentDrawerVC?.currentLevelOccupantList = currentLevelOccupantList
    }
    
    private func setupLevelPicker() {
        // Use the level's short name for a level picker item display name
        levelPicker.levelNames = levels.map {
            if let shortName = $0.properties.shortName.bestLocalizedValue {
                return shortName
            } else {
                return "\($0.properties.ordinal)"
            }
        }
        
        // Begin by displaying the level-specific information for Ordinal 0 (which is not necessarily the first level in the list).
        if let baseLevel = levels.first(where: { $0.properties.ordinal == 0 }) {
            levelPicker.selectedIndex = levels.firstIndex(of: baseLevel)!
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PersistentDrawerViewController {
            persistentDrawerVC = dest
            dest.implicitDestination = destinationVenue != nil
            dest.venue = venue
            dest.currentLevelAmenities = currentLevelAmentities
            dest.delegate = self
            dest.currentLevelOccupantList = currentLevelOccupantList
        }
    }
    
    
    // MARK: - Internal
    
    
    ///  Return true if this we are focussing on a single venue, rather than general maps
    private func hasImplicitVenue() -> Bool {
        return destinationVenue != nil
    }
}


@available(iOS 13.0, *)
extension OnSiteMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        guard let stylableFeature = annotation as? StylableFeature else {
            return nil
        }
        
        if let stylableFeature = stylableFeature as? Occupant, stylableFeature == destinationVenueOccupant {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ImageCalloutAnnotationView.identifier,
                                                                       for: annotation) as! ImageCalloutAnnotationView
            annotationView.imageView.image = UIImage(named: "MapsPinSelectedVenue")
            return annotationView
        } else if let amenity = stylableFeature as? Amenity,
          currentHighlightedCategory != nil, amenity.category == currentHighlightedCategory {
            let annotationView =
                mapView.dequeueReusableAnnotationView(withIdentifier: ImageCalloutAnnotationView.identifier,
                                                      for: annotation) as! ImageCalloutAnnotationView
            stylableFeature.configure(annotationView: annotationView)
            annotationView.setToLargeSize(large: false)

            return annotationView
        } else if let amenity = stylableFeature as? Amenity, amenity === highlightedRouteEscalatorAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EscalatorAnnotationView.identifier,
                                                                       for: annotation) as! EscalatorAnnotationView
            annotationView.setAs(elevator: false)
            return annotationView
        } else if let amenity = stylableFeature as? Amenity, amenity === highlightedRouteElevatorAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EscalatorAnnotationView.identifier,
                                                                       for: annotation) as! EscalatorAnnotationView
            annotationView.setAs(elevator: true)
            return annotationView
        } else {
            let annotationView =
                mapView.dequeueReusableAnnotationView(withIdentifier: PointAnnotationView.identifier,
                                                      for: annotation)
            stylableFeature.configure(annotationView: annotationView)
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        /*if let lat = view.annotation?.coordinate.latitude,
           let lon = view.annotation?.coordinate.longitude {
            print("Selected annotation at: \(lat), \(lon)")
        }*/
        
        if let av = view as? ImageCalloutAnnotationView {
            av.setToLargeSize(large: true)
        }
        
        clearCurrentRoute()
        persistentDrawerVC?.popToRoot()
        
        if let amenity = view.annotation as? Amenity {
            let metadata = AnnotationMetadata(amenity: amenity, floor: currentDisplayLevelOrdinal)
            persistentDrawerVC?.selectAnnotation(annotation: metadata)
            
            if let av = view as? PointAnnotationView {
                av.showsPin = true
            }
        } else if let occupant = view.annotation as? Occupant {
            if let metadata = AnnotationMetadata(occupant: occupant, floor: currentDisplayLevelOrdinal) {
                persistentDrawerVC?.selectAnnotation(annotation: metadata)
            
                if let av = view as? PointAnnotationView {
                    av.showsPin = true
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let av = view as? ImageCalloutAnnotationView {
            av.setToLargeSize(large: false)
        }
        
        if let av = view as? PointAnnotationView {
            av.showsPin = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let loc = userLocation.location else {
            return
        }
        
        updateUsersPositionTo(newCoordinate: loc.coordinate, floorLevel: loc.floor?.level)
    }
    
    func updateUsersPositionTo(newCoordinate: CLLocationCoordinate2D, floorLevel: Int?) {
        Distance.shared.userCoordinate = newCoordinate

        mapDbgFloorLabel?.text = floorLevel == nil ? "nil" : String(floorLevel!)
        
        // If the device knows which level the user is physically on, automatically switch to that level.
        if let ordinal = floorLevel, ordinal != Distance.shared.userFloorLevel {
            Distance.shared.userFloorLevel = ordinal
            showFeaturesForOrdinal(ordinal)
            levelPicker.userMovedToSelectedIndex(selectedIndex: ordinal)

            if let currentRoute = currentRoute, currentRoute.floorChangedTo(floorLevel: ordinal) {
                showRouteOnMap(route: currentRoute)
            }
        }
        
        currentRoute?.locationChangedTo(coordinate: newCoordinate)
        currentDirections?.locationUpdatedTo(coordinate: newCoordinate, floor: floorLevel)
    }
    
    func debugSetLocation(newCoordinate: CLLocationCoordinate2D?, level: Int) {
        guard let location = newCoordinate ?? mapView.userLocation.location?.coordinate else {
            return
        }

        updateUsersPositionTo(newCoordinate: location, floorLevel: level)
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay === highlightedRouteEscalatorOverlay || overlay === highlightedRouteElevatorOverlay {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor(named: "HighlightEscalatorFill")
            renderer.strokeColor = UIColor(named: "HighlightEscalatorStroke")
            renderer.lineWidth = 3
            return renderer
        }
        
        
        if let shape = overlay as? (MKShape & MKGeoJSONObject),
           let feature = currentLevelFeatures.first( where: { $0.geometry.contains( where: { $0 == shape }) }) {
            return geoJsonRendererFor(overlay: overlay, for: feature)
        }
        
        if let polyline = overlay as? MKPolyline {
            let routeRenderer = MKPolylineRenderer(polyline: polyline)
            //routeRenderer.strokeColor = UIColor.random
            routeRenderer.strokeColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            routeRenderer.lineWidth = 3.0
            routeRenderer.lineDashPattern = [7, 7]
            return routeRenderer
        }
        
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(overlay: polygon)
            renderer.fillColor = UIColor.blue
            renderer.alpha = 0.5
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    private func geoJsonRendererFor(overlay: MKOverlay, for feature: StylableFeature) -> MKOverlayRenderer {

        let renderer: MKOverlayPathRenderer
        switch overlay {
        case is MKMultiPolygon:
            renderer = MKMultiPolygonRenderer(overlay: overlay)
        case is MKPolygon:
            renderer = MKPolygonRenderer(overlay: overlay)
        case is MKMultiPolyline:
            renderer = MKMultiPolylineRenderer(overlay: overlay)
        case is MKPolyline:
            renderer = MKPolylineRenderer(overlay: overlay)
        default:
            return MKOverlayRenderer(overlay: overlay)
        }

        // Configure the overlay renderer's display properties in feature-specific ways.
        feature.configure(overlayRenderer: renderer)

        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if views.last?.annotation is MKUserLocation {
            addHeadingView(toAnnotationView: views.last!)
        }
    }
    
    func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
        if headingImageView == nil,
        let image = UIImage(named: "MapDirectionPointer"){
            headingImageView = UIImageView(image: image)
            headingImageView?.frame = CGRect(x: (annotationView.frame.size.width - 26) / 2,
                                             y: (annotationView.frame.size.height - 26) / 2,
                                             width: 26,
                                             height: 26)
            headingImageView?.contentMode = .top
            annotationView.addSubview(headingImageView!)
            headingImageView?.isHidden = true
         }
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}

@available(iOS 13.0, *)
extension OnSiteMapViewController: LevelPickerDelegate {
    func selectedLevelDidChange(selectedIndex: Int) {
        precondition(selectedIndex >= 0 && selectedIndex < self.levels.count)
        let selectedLevel = self.levels[selectedIndex]
        showFeaturesForOrdinal(selectedLevel.properties.ordinal)
    }
}


@available(iOS 13.0, *)
extension OnSiteMapViewController: PersistentDrawerDelegate {
    func occupantDetailsTapped(annotation: AnnotationMetadata, sender: PersistentDrawerViewController) {
        guard let venue = Venue.venueOnFloor(floor: annotation.floor, coordinate: annotation.coordinate) else {
            return
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        hidesNavigationBarOnViewDidAppear = true
        
        guard let vvc = UIStoryboard.venueDetail() else { return }
        vvc.venue = venue
        self.navigationController?.pushViewController(vvc, animated: true)
    }
    
    func clearHighlight(sender: PersistentDrawerViewController) {
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    func clearNavigation(sender: PersistentDrawerViewController) {
        clearCurrentRoute()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func navigateToImplicitVenue(sender: PersistentDrawerViewController) {
        navigateToImplicitVenue(accessibilityRestricted: false)
    }
    
    
    func navigateToAnnotation(annotation: AnnotationMetadata, sender: PersistentDrawerViewController) {
        lastRoutingDestination = annotation
        performRouting(to: annotation, accessibilityRestricted: false)
    }
    
    
    private func navigateToImplicitVenue(accessibilityRestricted: Bool) {
        if let occupant = currentLevelOccupantList.occupantFor(venue: destinationVenue!),
        let floorLevel = destinationVenue?.floorLevel,
        let metaData = AnnotationMetadata(occupant: occupant, floor: Int(floorLevel)) {
            performRouting(to: metaData, accessibilityRestricted: accessibilityRestricted)
            lastRoutingDestination = metaData
        }
    }
    
    
    private func performRouting(to annotation: AnnotationMetadata, accessibilityRestricted: Bool) {
        guard let userCoordinate = Distance.shared.userCoordinate else {
            return
        }
        
        let userFloor = Distance.shared.userFloorLevel ?? currentDisplayLevelOrdinal
        
        guard let route = routing.routeToLocation(userCoordinate: userCoordinate,
                                                  userFloor: userFloor,
                                                  targetLocation: annotation.coordinate,
                                                  targetFloor: annotation.floor,
                                                  accessibilityRestricted: accessibilityRestricted) else {
            print("ERROR: Routing failed - returned nil")
            return
        }
        
        let directions = Directions(route: route)
        directions.applyOccupantsToDirections(occupantList: currentLevelOccupantList)
        
        route.destinationTitle = annotation.title

        self.tabBarController?.tabBar.isHidden = true
        persistentDrawerVC?.configureFor(route: route, directions: directions)
        showRouteOnMap(route: route)
        currentRoute = route
        currentDirections = directions
    }
    
    
    private func showRouteOnMap(route: Route) {
        let haveFloorInfo = Distance.shared.userFloorLevel != nil
        
        //
        // If we don't have floor information we can't do floor by floor
        //
        if haveFloorInfo {
            showCurrentRouteSectionOnMap(route: route)
        } else {
            showEntireRouteOnMap(routeCoordsArray: route.waypointsArray())
        }
    }
    
    
    private func showEntireRouteOnMap(routeCoordsArray: [[MKMapPoint]]) {
        clearCurrentRoute()
        
        var boundingRect: MKMapRect?
        
        for routeCoords in routeCoordsArray {
            guard routeCoords.count > 1 else { continue }

            let polyline = MKPolyline(points: routeCoords, count: routeCoords.count)
            currentRoutingLines.append(polyline)
            mapView.addOverlay(polyline)
            
            if let br = boundingRect {
                boundingRect = br.union(polyline.boundingMapRect)
            } else {
                boundingRect = polyline.boundingMapRect
            }
        }
        
        if let br = boundingRect {
            showVisibleMapRect(targetRect: br)
        }
    }
    
    
    private func showCurrentRouteSectionOnMap(route: Route) {
        mapView.removeOverlays(currentRoutingLines)
        currentRoutingLines.removeAll()

        let routeCoords = route.waypointsForCurrentSection()
        
        guard routeCoords.count > 1, let lastCoord = routeCoords.last else {
            return
        }
        
        let sectionFloor = route.floorForCurrentSection()
        if currentDisplayLevelOrdinal != sectionFloor {
            showFeaturesForOrdinal(sectionFloor)
            levelPicker.userMovedToSelectedIndex(selectedIndex: sectionFloor)
        }

        let polyline = MKPolyline(points: routeCoords, count: routeCoords.count)
        currentRoutingLines.append(polyline)
        mapView.addOverlay(polyline)
        mapView.centerCoordinate = routeCoords[0].coordinate
        
        showVisibleMapRect(targetRect: polyline.boundingMapRect)
        
        clearCurrentEscalatorHighlights()
        
        guard persistentDrawerVC?.isShowingAccessibilityOptions() ?? false else {
            return
        }
        
        let (elevatorAmenity, elevatorGeometry) = highlightFloorTransitNear(point: lastCoord, category: .elevator)
        let (escalatorAmenity, escalatorGeometry) = highlightFloorTransitNear(point: lastCoord, category: .escalator)

        highlightedRouteElevatorAnnotation = elevatorAmenity
        highlightedRouteElevatorOverlay = elevatorGeometry
        highlightedRouteEscalatorAnnotation = escalatorAmenity
        highlightedRouteEscalatorOverlay = escalatorGeometry
        
        if let elevatorAmenity = elevatorAmenity {
            mapView.removeAnnotation(elevatorAmenity)
            mapView.addAnnotation(elevatorAmenity)
        }
        
        if let escalatorAmenity = escalatorAmenity {
            mapView.removeAnnotation(escalatorAmenity)
            mapView.addAnnotation(escalatorAmenity)
        }

        if let elevatorGeometry = elevatorGeometry {
            mapView.removeOverlay(elevatorGeometry)
            mapView.addOverlay(elevatorGeometry)
        }
        if let escalatorGeometry = escalatorGeometry {
            mapView.removeOverlay(escalatorGeometry)
            mapView.addOverlay(escalatorGeometry)
        }
    }
    
    
    func clearCurrentEscalatorHighlights() {
        if let a = highlightedRouteElevatorAnnotation {
            mapView.removeAnnotation(a)
            self.highlightedRouteElevatorAnnotation = nil
            mapView.addAnnotation(a)
        }

        if let a = highlightedRouteEscalatorAnnotation {
            mapView.removeAnnotation(a)
            self.highlightedRouteEscalatorAnnotation = nil
            mapView.addAnnotation(a)
        }
        
        if let o = highlightedRouteElevatorOverlay {
            mapView.removeOverlay(o)
            highlightedRouteElevatorOverlay = nil
            mapView.addOverlay(o)
        }
        
        if let o = highlightedRouteEscalatorOverlay {
            mapView.removeOverlay(o)
            highlightedRouteEscalatorOverlay = nil
            mapView.addOverlay(o)
        }
    }
    
    
    func highlightFloorTransitNear(point: MKMapPoint, category: Amenity.Category) -> (Amenity?, MKOverlay?) {
        var bestDistance = CLLocationDistance.greatestFiniteMagnitude
        var bestAmenity: Amenity?
        
        for amenity in currentLevelAmentities {
            if amenity.category != category {
                continue
            }
            
            let distance = point.distance(to: MKMapPoint(amenity.coordinate))
            if distance < bestDistance {
                bestDistance = distance
                bestAmenity = amenity
            }
        }
        
        guard let amenity = bestAmenity else { return (nil, nil) }
        
        var amenityGeometry: MKOverlay?
                
        if let levels = venue?.levelsByOrdinal[currentDisplayLevelOrdinal] {
            outerLoop: for level in levels {
                for unit in level.firstPassUnits {
                    if unit.amenities.contains(amenity){
                        let geometry = unit.geometry[0]
                        if let overlayGeometry = geometry as? MKOverlay {
                            amenityGeometry = overlayGeometry
                            break outerLoop
                        }
                    }
                }

                for unit in level.secondPassUnits {
                    if unit.amenities.contains(amenity){
                        let geometry = unit.geometry[0]
                        if let overlayGeometry = geometry as? MKOverlay {
                            amenityGeometry = overlayGeometry
                            break outerLoop
                        }
                    }
                }
            }
        }
        
        return (amenity, amenityGeometry)
    }
    
    
    private func showVisibleMapRect(targetRect: MKMapRect) {
        guard let drawerY = persistentDrawerVC?.view.frame.origin.y else {
            let insets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
            let insetTargetRect = mapView.mapRectThatFits(targetRect, edgePadding: insets)
            mapView.visibleMapRect = insetTargetRect
            return
        }
        
        //
        // Make sure everything appears above the persistent drawer
        //
        let heightObscuredByDrawer = self.view.frame.height - drawerY
        let drawerInsets = UIEdgeInsets(top: 25, left: 25, bottom: heightObscuredByDrawer + 25, right: 25)
        let drawerInsetTargetRect = mapView.mapRectThatFits(targetRect, edgePadding: drawerInsets)
        mapView.visibleMapRect = drawerInsetTargetRect
    }
    
    
    private func clearCurrentRoute() {
        mapView.removeOverlays(currentRoutingLines)
        currentRoutingLines.removeAll()
        currentRoute = nil
        currentDirections = nil
        clearCurrentEscalatorHighlights()
    }
    
    
    func setNavigationAccessibilityTo(restricted: Bool, sender: PersistentDrawerViewController) {
        guard let amenity = lastRoutingDestination else {
            print("ERROR: Tried to change accessibility routing option but no destination set")
            return
        }
        
        performRouting(to: amenity, accessibilityRestricted: restricted)
    }
    
    
    func continueTappedInAccessibility(sender: PersistentDrawerViewController) {
        clearCurrentEscalatorHighlights()
    }
    
    
    func highlightMapItem(mapItem: MKAnnotation, sender: PersistentDrawerViewController) {
        mapView.selectAnnotation(mapItem, animated: true)
    }
    
        
    func highlightAmenity(category: Amenity.Category?, sender: PersistentDrawerViewController) {
        guard currentHighlightedCategory != category else {
            return
        }
        
        let oldAmenities = currentHighlightedCategory != nil ?
            getAmenitiesFromCurrentLevel(category: currentHighlightedCategory!) : []
        let newAmenities = category != nil ? getAmenitiesFromCurrentLevel(category: category!) : []

        currentHighlightedCategory = category

        //
        //  Remove and add required to redraw
        //
        mapView.removeAnnotations(oldAmenities)
        mapView.addAnnotations(newAmenities)
    }
    
    func getAmenitiesFromCurrentLevel(category: Amenity.Category) -> [Amenity] {
        
        var amenities = [Amenity]()
        
        for annotation in currentLevelAmentities {
            if annotation.category == category {
                amenities.append(annotation)
            }
        }
        
        return amenities
    }
}

@available(iOS 13.0, *)
extension OnSiteMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        
        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        guard let headingImageView = headingImageView else { return }
        
        headingImageView.isHidden = false
        
        let rotation = CGFloat(heading / 180.0 * .pi)
        headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
    }
}
