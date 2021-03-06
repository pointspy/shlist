//
//  NiceButton.swift
//  Shlist
//
//  Created by Pavel Lyskov on 12.02.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
     - parameter color: A color.
     - returns: A 1x1 UIImage of a solid color.
     */
    static func pixel(ofColor color: UIColor) -> UIImage {
        let lightModeImage = UIImage.generatePixel(ofColor: color, userInterfaceStyle: .light)
        let darkModeImage = UIImage.generatePixel(ofColor: color, userInterfaceStyle: .dark)
        lightModeImage.imageAsset?.register(darkModeImage, with: UITraitCollection(userInterfaceStyle: .dark))
        return lightModeImage
    }
    
    static private func generatePixel(ofColor color: UIColor, userInterfaceStyle: UIUserInterfaceStyle) -> UIImage {
        var image: UIImage!
        if #available(iOS 13.0, *) {
            UITraitCollection(userInterfaceStyle: userInterfaceStyle).performAsCurrent {
                image = .generatePixel(ofColor: color)
            }
        } else {
            image = .generatePixel(ofColor: color)
        }
        return image
    }
    
    static private func generatePixel(ofColor color: UIColor) -> UIImage {
        let pixel = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(pixel.size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        context.setFillColor(color.cgColor)
        context.fill(pixel)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

// enter here
// Based on Kickstarter-Prelude version
// https://github.com/kickstarter/Kickstarter-Prelude/blob/master/Prelude-UIKit/UIButton.swift
extension UIButton {
    /**
     Sets the background color of a button for a particular state.
     - parameter backgroundColor: The color to set.
     - parameter state:           The state for the color to take affect.
     */
    func setBackgroundColor(_ backgroundColor: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(.pixel(ofColor: backgroundColor), for: state)
    }
}

