//
//  UIView+Ext.swift
//  Shlist
//
//  Created by Pavel Lyskov on 28.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//
import UIKit
import QuickLayout
// MARK: gradient

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint: CGPoint {
        return self.points.startPoint
    }
    
    var endPoint: CGPoint {
        return self.points.endPoint
    }
    
    var points: GradientPoints {
        switch self {
        case .topRightBottomLeft:
            return (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0))
        case .topLeftBottomRight:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1, y: 1))
        case .horizontal:
            return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .vertical:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
        }
    }
}

extension UIView {
    func applyGradient(withColours colours: [UIColor], locations: [NSNumber]? = nil) {
        if let subs = self.layer.sublayers {
            subs.forEach {layer in
                if let layer = layer as? CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) {
        
        if let subs = self.layer.sublayers {
            subs.forEach {layer in
                if let layer = layer as? CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIView {
    
    public var asImage: UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        
        return renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}

extension UIView {

    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(type(of: self).className, owner: self, options: nil)?.first as? T else {
            return nil
        }
        addSubview(contentView)
        contentView.fillSuperview()
        return contentView
    }
    
//    func fillSuperview() {
//        if let superV = self.superview {
//            self.frame = superV.bounds
//        }
//    }
}

