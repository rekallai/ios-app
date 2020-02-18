/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This MKAnnotationView subclass displays points of interest within a venue.
*/

import MapKit

@available(iOS 13.0, *)
class PointAnnotationView: MKAnnotationView {
    
    static let identifier = "PointAnnotationView"
    
    enum Category {
        case other
        case restroom
        case service
        case information
        case parking
        case shopping
        case restaurant
    }
    
    var category: Category = .other {
        didSet {
            switch category {
            case .restroom:
                point.backgroundColor = UIColor(named: "RestroomFill")
            case .service:
                point.backgroundColor = UIColor(named: "ServiceFill")
            case .information:
                point.backgroundColor = UIColor(named: "InformationFill")
            case .parking:
                point.backgroundColor = UIColor(named: "ParkingFill")
            case .shopping:
                point.backgroundColor = UIColor(named: "ShoppingFill")
            case .restaurant:
                point.backgroundColor = UIColor(named: "RestaurantFill")
            case .other:
                break
            }
        }
    }
    
    private let point = UIView()
    private let label = UILabel()
    var pinImageView: UIImageView?
    
    private let pointSize = CGSize(width: 10.0, height: 10.0)
    private let labelSize = CGSize(width: 80.0, height: 39.0)
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        self.frame = CGRect(x: 0,
                            y: 0,
                            width: pointSize.width,
                            height: pointSize.height)

        addSubview(point)
        
        point.frame = CGRect(x: -pointSize.width / 2.0,
                             y: -pointSize.height / 2.0,
                             width: pointSize.width,
                             height: pointSize.height)
        
        //backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
        
        point.layer.cornerRadius = 5
        point.layer.borderWidth = 1.0
        point.layer.borderColor = UIColor(named: "AnnotationBorder")?.cgColor
        self.canShowCallout = false
        
        addSubview(label)
        label.font = UIFont(name: "SFProDisplay-Semibold", size: 10.0, color: UIColor.black)
        label.frame = CGRect(x: 0,
                             y: pointSize.height,
                             width: labelSize.width,
                             height: labelSize.height)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.minimumScaleFactor = 0.75
    }
    
    override open var annotation: MKAnnotation? {
        didSet{
            if annotation is Occupant, let titleOpt = annotation?.title, let title = titleOpt{
                //print("TITLE: \(title)")
                label.text = title
                let (numberOfLines, size) = calculateMaxLines(text: title)
                label.numberOfLines = numberOfLines
                label.frame.size = size
                
                self.frame = CGRect(x: 0,
                                    y: 0,
                                    width: size.width,
                                    height: size.height + pointSize.height)
                
                point.frame = CGRect(x: (size.width / 2.0) - (pointSize.width / 2.0),
                                     y: 0,
                                     width: pointSize.width,
                                     height: pointSize.height)
                
                self.centerOffset = CGPoint(x: 0,
                                            y: (frame.size.height / 2.0) - (pointSize.height / 2.0) )
            } else {
                label.text = ""
                
                self.frame = CGRect(x: 0,
                                    y: 0,
                                    width: pointSize.width,
                                    height: pointSize.height)
                
                point.frame = CGRect(x: 0,
                                     y: 0,
                                     width: pointSize.width,
                                     height: pointSize.height)
                
                self.centerOffset = CGPoint(x: 0, y: 0)
            }
        }
    }
    
    var showsPin = false {
        didSet {
            guard showsPin else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.pinImageView?.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                }) { [weak self] completed in
                    self?.pinImageView?.removeFromSuperview()
                    self?.pinImageView = nil
                }
                return
            }
            
            if pinImageView == nil {
                let image: UIImage? = {
                    switch category {
                    case .restroom:
                        return UIImage(named: "MapsPinRestroom")
                    case .service:
                        return UIImage(named: "MapsPinService")
                    default:
                        return UIImage(named: "MapsYellowPin")
                    }
                }()
                pinImageView = UIImageView(image: image)
                addSubview(pinImageView!)
                let imageFrame = pinImageView!.frame
                pinImageView!.frame = CGRect(x: (self.frame.size.width / 2.0) - (imageFrame.width / 2.0),
                                             y: -imageFrame.height + 5.0, // Gap of 2, shadow space is 7
                                             width: imageFrame.width,
                                             height: imageFrame.width)
                
                pinImageView!.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.pinImageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func calculateMaxLines(text: String) -> (Int, CGSize) {
        let charSize = label.font.lineHeight
        let text = (text) as NSString
        let textSize = text.boundingRect(with: labelSize,
                                         options: .usesLineFragmentOrigin,
                                         attributes: [NSAttributedString.Key.font: label.font!],
                                         context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return (linesRoundedUp, textSize.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self.point {
            print("View hit")
            return view
        }
        
        return nil
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let pointViewPoint = self.convert(point, to: self.point)
        if self.point.point(inside: pointViewPoint, with: event) {
            return true
        }
        
        let labelPoint = self.convert(point, to: label)
        return label.point(inside: labelPoint, with: event)
        //return false
        //return super.point(inside: point, with: event)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }*/
}
