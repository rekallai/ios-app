//
//  DirectionsViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 13/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit


@available(iOS 13, *)
protocol DirectionsViewControllerDelegate: class {
    func destinationReached(sender: DirectionsViewController)
}


@available(iOS 13, *)
class DirectionsViewController: PersistentDrawerContentViewController {

    weak var delegate: DirectionsViewControllerDelegate?
    var directions: Directions? {
        didSet {
            updateDestinationTitle()
            tableView?.reloadData()
            drawDashedLine()
            directions?.delegate = self
        }
    }
    
    let waypointCellHeight = 39.0
    let walkCellHeight = 62.0
    let positionViewWidth = 21.0
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var subtitleLabel: UILabel?
    @IBOutlet var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.contentInsetAdjustmentBehavior = .never
        tableView?.automaticallyAdjustsScrollIndicatorInsets = false
        collapsedSize = 185.0
        expandedSize = 364.0
        drawDashedLine()
        updateDestinationTitle()
    }
    
    var currentDashedLayer: CAShapeLayer?
    func drawDashedLine() {
        
        currentDashedLayer?.removeFromSuperlayer()
        currentDashedLayer = nil
        
        guard let nrWaypoints = directions?.directions.count, nrWaypoints > 1 else {
            return
        }
        
        let nrSteps = Double(nrWaypoints - 1)
        let requiredLength = nrSteps * (waypointCellHeight + walkCellHeight)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(named: "ButtonBackground")?.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineDashPattern = [7,7]

        let path = CGMutablePath()
        let halfMarker = positionViewWidth / 2.0
        path.addLines(between: [CGPoint(x: halfMarker, y: halfMarker),
                                CGPoint(x: halfMarker, y: requiredLength)])
        shapeLayer.path = path
        shapeLayer.zPosition = -1
        tableView?.layer.addSublayer(shapeLayer)

        currentDashedLayer = shapeLayer
    }
    
    
    private func updateDestinationTitle() {
        guard let directions = directions else {
            titleLabel?.text = ""
            return
        }
        
        titleLabel?.text = NSLocalizedString("Walking directions to \(directions.destinationTitle)",
                                             comment: "Destination string")
        
        let walkTime = directions.totalWalkingTime()
        
        subtitleLabel?.text = NSLocalizedString("\(walkTime) min walk",
                              comment: "Route walking time")
    }
}


@available(iOS 13, *)
extension DirectionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let waypoints = directions?.directions.count, waypoints > 0 else { return 0 }
        
        return waypoints * 2 - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let directions = directions else { fatalError() }

        let routeSection = indexPath.row / 2
        let isWaypointCell = indexPath.row % 2 == 0
        let isFirstWaypoint = indexPath.row == 0
        let isLastWaypoint = routeSection == directions.directions.count

        let direction = directions.directions[routeSection]

        if isWaypointCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: DirectionsWaypointCell.identifier,
                                                     for: indexPath) as! DirectionsWaypointCell
            
            cell.positionIndicator.state = directions.stateForDirection(directionIndex: routeSection)

            if isFirstWaypoint {
                let floorForSection = direction.floor
                cell.setStartFloor(floor: floorForSection)
            } else if isLastWaypoint {
                let floorForSection = directions.directions.last?.floor ?? 0
                cell.setEnd(floor: floorForSection, venueName: directions.destinationTitle)
            } else {
                cell.setDirectionItem(direction: direction)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: DirectionsWalkCell.identifier,
                                                     for: indexPath) as! DirectionsWalkCell
            cell.walkTime = Int(direction.walkingTime())
            return cell
        }
    }
}


@available(iOS 13, *)
extension DirectionsViewController: DirectionsDelegate {
    func currentDirectionUpdated(sender: Directions) {
        tableView?.reloadData()
    }
    
    func destinationReachedIn(sender: Directions) {
        delegate?.destinationReached(sender: self)
    }
}
