//
//  Foundation+Ext.swift
//  Shlist
//
//  Created by Pavel Lyskov on 07.02.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import Foundation

public protocol IntTransformable {
    var asInt: Int { get }
}

public protocol DoubleTransformable {
    var asDouble: Double { get }
}

public extension Int {
    var asDouble: Double {
        return Double(self)
    }
}

public extension Double {
    var asInt: Int {
        return Int(self)
    }
    
    var asDouble: Double {
        return self
    }
}

public extension String {
    var asInt: Int {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        
        guard let number = formatter.number(from: self) else {
            return 0
        }
        
        return number.intValue
    }
    
    var asDouble: Double {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        
        guard let number = formatter.number(from: self) else {
            return 0
        }
        
        return number.doubleValue
    }
}

extension Double: IntTransformable {}
extension String: IntTransformable {}
extension Int: DoubleTransformable {}
extension String: DoubleTransformable {}
extension Double: DoubleTransformable {}

public extension String {
    func sizeFor(font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (self as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
        return bounds.size
    }
    
    func heightFor(font: UIFont) -> CGFloat {
        return self.sizeFor(font: font).height
    }
    
    func sizeFor(font: UIFont, width: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (self as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        
        return bounds.size
    }
    
    func heightFor(font: UIFont, width: CGFloat) -> CGFloat {
        return self.sizeFor(font: font, width: width).height
    }
    
    func sizeWith(font: UIFont) -> CGSize {
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

struct DoublePretty {
    let value: Double
}

extension DoublePretty: CustomStringConvertible {
    static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    var prettyValue: String {
        guard let textValue = DoublePretty.formatter.string(from: NSNumber(floatLiteral: self.value)) else {
            return "0"
        }
        
        if textValue.suffix(3) == ".00" {
            return String(textValue.dropLast(3))
        }
        
        return textValue
    }
    
    var description: String {
        return self.prettyValue
    }
}

extension Double {
    var asPretty: DoublePretty {
        return DoublePretty(value: self)
    }
}
