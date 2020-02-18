//
//  ADActivitySpinner.swift
//  Rekall
//
//  Created by Ray Hunter on 12/11/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class ADActivitySpinner: UIView {

    private class CircleView: UIView, CAAnimationDelegate {
                
        var circleLayer: CAShapeLayer!
        var hasDismissed = false
        var innerAnimationHasFinished = false

        let radiusInset: CGFloat = 10
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                                          radius: (frame.size.width - radiusInset)/2,
                                          startAngle: 0.0,
                                          endAngle: CGFloat(.pi * 2.0),
                                          clockwise: true)

            circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = UIColor(named: "BlackWhite")?.cgColor
            circleLayer.lineWidth = 4.0 // We lose half of this, as the mask is the same size and this is split either side
            
            // Don't draw the circle initially
            circleLayer.strokeEnd = 0.0

            // Add the circleLayer to the view's layer's sublayers
            layer.addSublayer(circleLayer)

            let maskLayer = CAShapeLayer()
            maskLayer.path = circlePath.cgPath

            layer.mask = maskLayer
            
            backgroundColor = UIColor(named: "WhiteBlack")
        }
        
        var animateToVisible = false
        func animateCircle() {

            circleLayer.removeAllAnimations()
            animateToVisible = !animateToVisible
            
            let animation = animateToVisible ? CABasicAnimation(keyPath: "strokeEnd") : CABasicAnimation(keyPath: "strokeStart")

            animation.duration = 1.0
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.delegate = self

            // Set the end values for the stroke, as the animation won't set them for us
            if animateToVisible {
                circleLayer.strokeEnd = 1.0
            } else {
                circleLayer.strokeStart = 1.0
                circleLayer.strokeEnd = 1.0
            }

            circleLayer.add(animation, forKey: "animateCircle")
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            
            guard flag else {
                (superview?.superview as? ADActivitySpinner)?.animationInterrupted()
                return
            }
            
            // Keep going until we are dismissed, but stop in a fully visible state
            if !hasDismissed || !animateToVisible {
                if !animateToVisible {
                    // Reset start and end before this pump finishes.
                    circleLayer.strokeStart = 0.0
                    circleLayer.strokeEnd = 0.0
                }

                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.animateCircle()
                }
                return
            }
            
            innerAnimationHasFinished = true
            showFullADLogo()
        }
        
        func showFullADLogo() {
            transform = CGAffineTransform.identity
            layer.masksToBounds = true
            
            let logoColorView = UIView(frame: bounds)
            logoColorView.backgroundColor = UIColor(named: "BlackWhite")
            logoColorView.frame.origin.x = bounds.size.width
            addSubview(logoColorView)
            
            let letterAView = UIImageView(image: UIImage(named: "ActivityLetterA"))
            letterAView.contentMode = .scaleAspectFit
            let letterWidth = 36.0 / 92.0 * (bounds.size.height - radiusInset - radiusInset)     // According to the reference sizes
            letterAView.frame = CGRect(x: (bounds.size.height / 2.0) - letterWidth,
                                       y: 34.0 + radiusInset,
                                       width: letterWidth,
                                       height: 37.0 / 92.0 * (bounds.size.height - radiusInset - radiusInset))
            addSubview(letterAView)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: {
                logoColorView.frame.origin.x = self.bounds.size.width / 2.0
                letterAView.frame.origin.x = (self.bounds.size.height / 2.0) - 2.0
            }) { [weak self] finished in
                (self?.superview?.superview as? ADActivitySpinner)?.fullyFinished()
            }
        }
    }

    private var dismissCompletion: (() -> ())?
    private let circleView = CircleView(frame: CGRect(x: 25.0, y: 25.0, width: 100.0, height: 100.0))
    private let outerFrame = UIView(frame: CGRect(x: 0.0, y: 100.0, width: 150.0, height: 150.0))
    private var interrupted = false

    init(targetView: UIView) {
        super.init(frame: targetView.bounds)
        targetView.addSubview(self)
        addSubview(outerFrame)
        outerFrame.addSubview(circleView)
        circleView.animateCircle()
        
        outerFrame.center = center
        
        rotateCircleView()
        
        outerFrame.layer.cornerRadius = 8.0
    }
    
    //
    //  Outer rotation - rotate the inner sub-animation
    //
    var currentRotation: CGFloat = 0.0
    func rotateCircleView() {
        currentRotation += 90.0
        if currentRotation >= 359.0 { currentRotation = 0.0 }

        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveLinear,
                       animations: {
            self.circleView.transform = CGAffineTransform(rotationAngle: self.currentRotation * .pi / 180.0)
        }) { [weak self] finished in
            guard let strongSelf = self else { return }
            if !strongSelf.circleView.innerAnimationHasFinished {
                strongSelf.rotateCircleView()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Notify the spinner that the required activity has finished. Call the animation to a quickish and sexy close.
    /// Call the callback once this has been done.
    func dismiss(completion: (() -> ())?) {
        dismissCompletion = completion
        circleView.hasDismissed = true

        if interrupted {
            removeFromSuperview()
            dismissCompletion?()
        }
    }
    
    /// Abnormal termination - e.g. app backgrounded.
    fileprivate func animationInterrupted(){
        interrupted = true
                
        if circleView.hasDismissed {
            removeFromSuperview()
            dismissCompletion?()
        }
    }
    
    /// Normal termination
    fileprivate func fullyFinished() {
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.alpha = 0.0
        }) { [weak self] finished in
            self?.removeFromSuperview()
            self?.dismissCompletion?()
        }
    }
}
