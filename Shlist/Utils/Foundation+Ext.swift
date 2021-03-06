//
//  Foundation+Ext.swift
//  Shlist
//
//  Created by Pavel Lyskov on 07.02.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import Foundation

public protocol IntTransformable {
    var asInt: Int {get}
}

extension Int {
    var asDouble: Double {
        return Double(self)
    }
}

extension Double {
    public var asInt: Int {
        return Int(self)
    }
}

extension String {
    public var asInt: Int {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        
        guard let number = formatter.number(from: self) else {
            return 0
        }
        
        return number.intValue
    }
}

extension Double: IntTransformable {}
extension String: IntTransformable {}

extension String {
    public func sizeFor(font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (self as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
        return bounds.size
    }
    
    public func heightFor(font: UIFont) -> CGFloat {
        return self.sizeFor(font: font).height
    }
    
    public func sizeFor(font: UIFont, width: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (self as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
        return bounds.size
    }
    
    public func heightFor(font: UIFont, width: CGFloat) -> CGFloat {
        return self.sizeFor(font: font, width: width).height
    }
    
    public func sizeWith(font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (self as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
        return bounds.size
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
