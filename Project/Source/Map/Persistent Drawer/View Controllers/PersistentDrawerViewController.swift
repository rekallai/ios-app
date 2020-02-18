//
//  PersistentDrawerViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 20/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

@available(iOS 13.0, *)
protocol PersistentDrawerDelegate: class {
    func highlightAmenity(category: Amenity.Category?, sender: PersistentDrawerViewController)
    func highlightMapItem(mapItem: MKAnnotation, sender: PersistentDrawerViewController)
    func clearHighlight(sender: PersistentDrawerViewController)
    func navigateToAnnotation(annotation: AnnotationMetadata, sender: PersistentDrawerViewController)
    func occupantDetailsTapped(annotation: AnnotationMetadata, sender: PersistentDrawerViewController)
    func navigateToImplicitVenue(sender: PersistentDrawerViewController)
    func setNavigationAccessibilityTo(restricted: Bool, sender: PersistentDrawerViewController)
    func continueTappedInAccessibility(sender: PersistentDrawerViewController)
    func clearNavigation(sender: PersistentDrawerViewController)
}

@available(iOS 13.0, *)
class PersistentDrawerViewController: UIViewController {
    
    let HANDLE_VIEW_HEIGHT: CGFloat = 13.0
    var venue: MapVenue?
    var implicitDestination = false
    weak var delegate: PersistentDrawerDelegate?
    
    @IBOutlet var handleContainerView: UIView!
    @IBOutlet var handleView: UIView!
    @IBOutlet var contentView: UIView!
    private var maxVisibleHeight: CGFloat = 250.0
    private var minVisibleHeight: CGFloat = 100.0
        
    private(set) var collapsedTopPosition: CGFloat = 0.0    // Collapsed and expanded measured from top,
    private(set) var expandedTopPosition: CGFloat = 0.0     // collapsed > expanded
    private var drawerIsCollapsed = true

    private var topLayoutConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    private weak var amenitiesListVC: AnnotationsListViewController?
    private weak var annotationsDetailsVC: AnnotationDetailsViewController?
    private weak var accessibilityVC: AccessibilityViewController?
    private weak var directionsVC: DirectionsViewController?
    private weak var arrivalVC: ArrivalConfirmationViewController?

    private var currentRoute: Route?
    private var currentDirections: Directions?
    
    var currentLevelAmenities = [Amenity]() {
        didSet {
            if let section = amenitiesListVC?.section {
                amenitiesListVC?.listItems = getListOfItemsForSection(section: section)
            }
        }
    }
    
    // This didSet effect relies on currentLevelAmenities :\
    var currentLevelOccupantList = OccupantList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 12.0
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        handleContainerView.layer.cornerRadius = 12.0
        handleView.layer.cornerRadius = 2.5
        recalcCollapsedAndExpandedConstraintValues(animated: false)
        
        if Defines.navigationEnabled || !implicitDestination {
            performSegue(withIdentifier: implicitDestination ? "ShowNavigateButton" :"ShowWhatsNew",
                         sender: self)

        }
    }
    
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        heightConstraint = view.heightAnchor.constraint(equalToConstant: maxVisibleHeight)
        heightConstraint?.isActive = true
        
        // 10000 should be closer to collapsed than expanded
        topLayoutConstraint = view.topAnchor.constraint(equalTo: view.superview!.topAnchor,
                                                                       constant: 10000)
        topLayoutConstraint?.isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recalcCollapsedAndExpandedConstraintValues(animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PersistentDrawerContentViewController {
            destination.venue = venue
        }

        if let destination = segue.destination as? WhatsNearbyViewController {
            destination.delegate = self
        }
        
        if let destination = segue.destination as? AnnotationsListViewController {
            amenitiesListVC = destination
            destination.delegate = self
            
            guard let section = sender as? WhatsNearbyViewController.Section else {
                fatalError("Could not to list type for amenities list")
            }
            
            destination.section = section
            destination.listItems = getListOfItemsForSection(section: section)
        }
        
        if let destination = segue.destination as? AnnotationDetailsViewController {
            annotationsDetailsVC = destination
            destination.annotation = sender as? AnnotationMetadata
            destination.delegate = self
        }
        
        if let destination = segue.destination as? AccessibilityViewController {
            accessibilityVC = destination
            destination.route = currentRoute
            destination.delegate = self
        }
        
        if let destination = segue.destination as? NavigateButtonViewController {
            destination.delegate = self
        }
        
        if let destination = segue.destination as? DirectionsViewController {
            directionsVC = destination
            destination.delegate = self
            destination.directions = currentDirections
        }
        
        if let destination = segue.destination as? ArrivalConfirmationViewController {
            arrivalVC = destination
            destination.route = currentRoute
        }
    }
    
    
    func setDrawer(collapsedSize: CGFloat, expandedSize: CGFloat, animated: Bool) {
        minVisibleHeight = collapsedSize + HANDLE_VIEW_HEIGHT
        maxVisibleHeight = expandedSize + HANDLE_VIEW_HEIGHT
        heightConstraint?.constant = maxVisibleHeight
        
        recalcCollapsedAndExpandedConstraintValues(animated: animated)
    }
    
    
    private func recalcCollapsedAndExpandedConstraintValues(animated: Bool) {
        guard let sv = view.superview else { return }
        
        let tabBarHeight = (tabBarController?.tabBar.isHidden == true) ? 0 :
            (tabBarController?.tabBar.frame.height ?? 0)
        
        expandedTopPosition = sv.bounds.height - tabBarHeight - maxVisibleHeight
        collapsedTopPosition = sv.bounds.height - tabBarHeight - minVisibleHeight

        clampDrawerPosition(animated: animated)
    }
    
    
    private func clampDrawerPosition(animated: Bool) {
        guard var drawerPosition = topLayoutConstraint?.constant else { return }
        
        var didClamp = false
        
        if drawerPosition < expandedTopPosition { drawerPosition = expandedTopPosition; didClamp = true }
        if drawerPosition > collapsedTopPosition { drawerPosition = collapsedTopPosition; didClamp = true }
        
        if didClamp {
            topLayoutConstraint?.constant = drawerPosition
            
            if animated {
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    

    var dragYPosStart: CGFloat = 0.0
    var panGestureActiveButNotYetAFlick = false
    @IBAction func panGestureDetected(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            panGestureActiveButNotYetAFlick = true
            dragYPosStart = sender.location(in: self.view).y
        case .changed:
            if !panGestureActiveButNotYetAFlick { return }
            
            let velocity = sender.velocity(in: self.view)
            
            if velocity.y < -900 {
                panGestureActiveButNotYetAFlick = false
                animateDrawerTo(top: true)
                return
            }
            
            if velocity.y > 900 {
                panGestureActiveButNotYetAFlick = false
                animateDrawerTo(top: false)
                return
            }
            
            let yLocation = sender.location(in: self.view.superview).y - dragYPosStart
            topLayoutConstraint?.constant = yLocation
            clampDrawerPosition(animated: false)
        case .ended: fallthrough
        case .cancelled:
            if !panGestureActiveButNotYetAFlick { return }

            let yLocation = sender.location(in: self.view.superview).y
            let distToCollapsed = abs(collapsedTopPosition - yLocation)
            let distToExpanded = abs(expandedTopPosition - yLocation)
            
            let isClosestToCollapsed = distToCollapsed < distToExpanded
            animateDrawerTo(top: !isClosestToCollapsed)
        default:
            return
        }
    }
    
    
    func animateDrawerTo(top: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.topLayoutConstraint?.constant =
                top ? self.expandedTopPosition : self.collapsedTopPosition
            self.view.superview?.layoutIfNeeded()
        }
    }
    
    
    @IBAction func unwindToDrawerRoot(segue: UIStoryboardSegue) {
        delegate?.highlightAmenity(category: nil, sender: self)
        delegate?.clearNavigation(sender: self)
    }
    
    
    @IBAction func unwindTowardsDrawerRoot(segue: UIStoryboardSegue) {
        if segue.source == annotationsDetailsVC {
            delegate?.clearHighlight(sender: self)
        }

        if segue.source == accessibilityVC ||
           (segue.source == directionsVC && currentRoute?.spansMultipleFloors == false)  {
            delegate?.clearNavigation(sender: self)
        }
    }
    
    
    func isShowingAccessibilityOptions() -> Bool {
        return accessibilityVC != nil && directionsVC == nil
    }
    
    
    func selectAnnotation(annotation: AnnotationMetadata) {
        if let amenityDetailsVC = annotationsDetailsVC {
            amenityDetailsVC.annotation = annotation
            return
        }
        
        performSegue(withIdentifier: "ShowAmenityDetails", sender: annotation)
    }
    
    
    func configureFor(route: Route, directions: Directions?) {
        currentRoute = route
        currentDirections = directions
        
        if route.spansMultipleFloors {
            showAccessibilityOptions()
        } else {
            showDirections()
        }
    }
    
    
    private func showAccessibilityOptions() {
        guard accessibilityVC == nil else {
            accessibilityVC?.route = currentRoute
            return
        }
        
        performSegue(withIdentifier: "ShowAccessibilityOptions", sender: self)
    }
    
    
    private func showDirections() {
        guard directionsVC == nil else {
            directionsVC?.directions = currentDirections
            return
        }
        
        performSegue(withIdentifier: "ShowDirections", sender: self)
    }
    
    
    private func getListOfItemsForSection(section: WhatsNearbyViewController.Section)  -> [AnnotationsListViewController.ListItem] {
        switch section {
        case .restrooms:
            return getAmenitiesIn(category: .restroom)
        case .service:
            return getAmenitiesIn(category: .service)
        case .favorites:
            return getFavorites()
        }
    }
    
    
    private func getAmenitiesIn(category: Amenity.Category) -> [AnnotationsListViewController.ListItem] {
        var items = [AnnotationsListViewController.ListItem]()

        for amenity in currentLevelAmenities {
            if amenity.category == category {
                let distance = Distance.shared.distanceInMetersFromUserTo(location2d: amenity.coordinate)
                let title = amenity.category == .service ?
                    NSLocalizedString("Kiosk", comment: "Name of help point") :
                    amenity.title
                items.append(AnnotationsListViewController.ListItem(title: title,
                                                                  subTitle: amenity.subtitle,
                                                                  mapItem: amenity,
                                                                  distance: distance))
            }
        }
        
        items.sort { (a, b) -> Bool in
            return a.distance < b.distance
        }

        return items
    }
    
    
    private func getFavorites() -> [AnnotationsListViewController.ListItem] {
        var items = [AnnotationsListViewController.ListItem]()
        
        let venueViewModel = VenueViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
        venueViewModel.venueIds = UserViewModel.shared.user.favoriteVenueIds
        for i in 0..<venueViewModel.numberOfItems {
            guard let venue = venueViewModel.venue(at: i) else {
                continue
            }
            
            if venue.floorLevel != Int32(currentLevelOccupantList.currentLevel) {
                continue
            }

            let mapItem = currentLevelOccupantList.occupantFor(venue: venue)

            var distance: CLLocationDistance = 0
            if let userPosition = Distance.shared.userCoordinate,
                let venueDistance = venue.location?.distanceTo(coordinate: userPosition) {
                    distance = venueDistance
            }
            
            let listItem = AnnotationsListViewController.ListItem(title: venue.name,
                                                                subTitle: venue.locationDescription,
                                                                mapItem: mapItem,
                                                                distance: distance)
            items.append(listItem)
        }
        
        return items
    }
    
    
    func popToRoot() {
        if arrivalVC != nil {
            arrivalVC?.performSegue(withIdentifier: "UnwindToDrawerRoot", sender: self)
            return
        }

        if accessibilityVC != nil {
            accessibilityVC?.performSegue(withIdentifier: "UnwindTowardsDrawerRoot", sender: self)
            return
        }

        if directionsVC != nil {
            directionsVC?.performSegue(withIdentifier: "UnwindTowardsDrawerRoot", sender: self)
            return
        }
    }
}


@available(iOS 13, *)
extension PersistentDrawerViewController: WhatsNearbyDelegate {
    
    func whatsNearbyDidSelectSection(section: WhatsNearbyViewController.Section) {
        print("Did select section: \(section)")
        performSegue(withIdentifier: "ShowAmenitiesList", sender: section)
        
        if section == .restrooms {
            delegate?.highlightAmenity(category: Amenity.Category.restroom, sender: self)
        }
        if section == .service {
            delegate?.highlightAmenity(category: Amenity.Category.service, sender: self)
        }
    }
}


@available(iOS 13, *)
extension PersistentDrawerViewController: AnnotationsListDelegate {
    
    func mapItemSelected(mapItem: MKAnnotation, sender: AnnotationsListViewController) {
        delegate?.highlightMapItem(mapItem: mapItem, sender: self)
    }
    
}


@available(iOS 13, *)
extension PersistentDrawerViewController: AmenityDetailsDelegate {
    func navigateTappedIn(sender: AnnotationDetailsViewController) {
        guard let destinationAnnotation = sender.annotation else {
            return
        }
        
        delegate?.navigateToAnnotation(annotation: destinationAnnotation, sender: self)
    }
    
    func occupantTappedIn(sender: AnnotationDetailsViewController) {
        guard let destinationAnnotation = sender.annotation else {
            return
        }
        
        delegate?.occupantDetailsTapped(annotation: destinationAnnotation, sender: self)
    }
}


@available(iOS 13, *)
extension PersistentDrawerViewController: AccessibilityDelegate {
    func userSwitchedTo(accessibilityCategory: AccessibilityCategory, sender: AccessibilityViewController) {
        delegate?.setNavigationAccessibilityTo(restricted: accessibilityCategory == .elevator,
                                               sender: self)
    }
    
    func continueTappedIn(sender: AccessibilityViewController) {
        guard currentRoute != nil else {
            print("Can't show directions - currentRoute is nil")
            return
        }
        
        delegate?.continueTappedInAccessibility(sender: self)
        
        showDirections()
    }
}


@available(iOS 13, *)
extension PersistentDrawerViewController: NavigateButtonDelegate {
    func navigateButtonTappedIn(sender: NavigateButtonViewController) {
        delegate?.navigateToImplicitVenue(sender: self)
    }
}


@available(iOS 13.0, *)
extension PersistentDrawerViewController: DirectionsViewControllerDelegate {
    func destinationReached(sender: DirectionsViewController) {
        performSegue(withIdentifier: "ShowArrivalConfirmation", sender: self)
    }
}
