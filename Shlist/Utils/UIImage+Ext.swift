//
//  UIImage+Ext.swift
//  Shlist
//
//  Created by Pavel Lyskov on 28.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import UIKit

extension UIImage {
    static func makeRoundedImage(radius: CGFloat, size: CGSize, borderWidth width: CGFloat, fillColor: UIColor, borderColor: UIColor) -> UIImage {
        
        let image = UIImage()
        // make a CGRect with the image's size
        let circleRect = CGRect(origin: .zero, size: size)
        
        // begin the image context since we're not in a drawRect:
        UIGraphicsBeginImageContextWithOptions(circleRect.size, false, 0)
        
        // create a UIBezierPath circle
        let circle = UIBezierPath(roundedRect: circleRect, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: radius, height: radius))
        
        // clip to the circle
        circle.addClip()
        
        fillColor.set()
        circle.fill()
        
        // draw the image in the circleRect *AFTER* the context is clipped
        image.draw(in: circleRect)
        
        // create a border (for white background pictures)
        if width > 0 {
            circle.lineWidth = width
            borderColor.set()
            circle.stroke()
        }
        
        // get an image from the image context
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the image context since we're not in a drawRect:
        UIGraphicsEndImageContext()
        
        return roundedImage ?? image
    }
    
    static func draw(size: CGSize, fillColor: UIColor, shapeClosure: () -> UIBezierPath) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        let path = shapeClosure()
        path.addClip()
        
        fillColor.setFill()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    final func rounded(withCornerRadius radius: CGFloat, corners: UIRectCorner, divideRadiusByImageScale: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let scaledRadius = divideRadiusByImageScale ? radius / scale : radius
        
        let clipPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), byRoundingCorners: corners, cornerRadii: CGSize(width: scaledRadius, height: scaledRadius))
        
        clipPath.addClip()
        
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
}

extension CGSize {
    /// Generates a new size that is this size scaled by a cerntain percentage
    ///
    /// - Parameter percentage: the percentage to scale to
    /// - Returns: a new CGSize instance by scaling self by the given percentage
    func scaled(by percentage: CGFloat) -> CGSize {
        return CGSize(width: width * percentage, height: height * percentage)
    }
}

extension CGRect {
    func scaled(by percentage: CGFloat) -> CGRect {
        return CGRect(center: self.center, size: self.bounds.size.scaled(by: percentage))
    }
}


//extension UIImage {
//
//    convenience init(view: UIView) {
//
//        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
//        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        self.init(cgImage: (image?.cgImage)!)
//
//    }
//}

extension UIImage {
    func applyOverlayWithColor(color: UIColor, blendMode: CGBlendMode) -> UIImage? {
        
        // Create a new CGContext
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let bounds = CGRect(origin: .zero, size: self.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Draw image into context, then fill using the proper color and blend mode
        draw(in: bounds, blendMode: .normal, alpha: 1.0)
        context.setBlendMode(blendMode)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        // Return the resulting image
        let overlayImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return overlayImage
    }
    
    func applyOverlayWithColor(color: UIColor, blendMode: CGBlendMode, alpha: CGFloat) -> UIImage? {
        return applyOverlayWithColor(color: color.withAlphaComponent(alpha), blendMode: blendMode)
    }
}

extension UIImage {
    public func tintWith(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
            return nil
        }
        
        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context.setBlendMode(CGBlendMode.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: cgImage)
        
        color.setFill()
        context.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
