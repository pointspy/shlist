//
//  UIBezierPath+RoundedRect.swift
//  Pixel-iOS
//
//  Created by José Donor on 28/11/2018.
//

import UIKit

extension CGFloat {
    /// Absolute value
    public var abs: CGFloat {
        return Swift.abs(self)
    }

    /// Restricts to a maximum value.
    public func max(_ maximum: CGFloat) -> CGFloat {
        return Swift.min(self, maximum)
    }

    /// Restricts to a minimum value.
    public func min(_ minimum: CGFloat) -> CGFloat {
        return Swift.max(self, minimum)
    }

    /// Restricts value to a given range.
    public func `in`(_ a: CGFloat,
                     _ b: CGFloat) -> CGFloat {
        return a < b
            ? self.min(a).max(b)
            : self.min(b).max(a)
    }

    /// Rounds down to nearest integer.
    public var floor: CGFloat {
        return Foundation.floor(self)
    }

    /// Rounds up to nearest integer.
    public var ceil: CGFloat {
        return Foundation.ceil(self)
    }
}

extension UIBezierPath {
    public convenience init(roundedRectIn bounds: CGRect,
                            cornerRadii: [UIRectCorner: CGFloat]) {
        let width = bounds.width
        let height = bounds.height

        let length = min(width, height)

        guard !(cornerRadii[.allCorners] == length / 2
            && bounds.width == bounds.height) else {
            self.init(ovalIn: bounds)
            return
        }

        self.init()

        let cornerRadii = cornerRadii.mapValues { $0.abs }

        let radius = cornerRadii[.allCorners]

        var tlRadius = radius ?? cornerRadii[.topLeft] ?? 0
        var trRadius = radius ?? cornerRadii[.topRight] ?? 0
        var brRadius = radius ?? cornerRadii[.bottomRight] ?? 0
        var blRadius = radius ?? cornerRadii[.bottomLeft] ?? 0

        // Ensures that radius don't overflow
        if tlRadius + trRadius > width {
            tlRadius = tlRadius.max(width)
            trRadius = width - tlRadius
        }
        if trRadius + brRadius > height {
            trRadius = trRadius.max(height)
            brRadius = height - trRadius
        }
        if brRadius + blRadius > width {
            brRadius = brRadius.max(width)
            blRadius = width - brRadius
        }
        if blRadius + tlRadius > height {
            blRadius = blRadius.max(height)
            tlRadius = width - blRadius
        }

        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY

        move(to: bounds.center)

        var center = CGPoint(x: minX + tlRadius, y: minY + tlRadius)

        if tlRadius == 0 {
            move(to: center)
        }
        else {
            move(to: CGPoint(x: minX, y: minY + tlRadius))
            addArc(withCenter: center, radius: tlRadius, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
        }

        center = CGPoint(x: maxX - trRadius, y: minY + trRadius)

        if trRadius == 0 {
            addLine(to: center)
        }
        else {
            addLine(to: CGPoint(x: maxX - trRadius, y: minY))
            addArc(withCenter: center, radius: trRadius, startAngle: .pi * 1.5, endAngle: 0, clockwise: true)
        }

        center = CGPoint(x: maxX - brRadius, y: maxY - brRadius)

        if brRadius == 0 {
            addLine(to: center)
        }
        else {
            addLine(to: CGPoint(x: maxX, y: maxY - brRadius))
            addArc(withCenter: center, radius: brRadius, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
        }

        center = CGPoint(x: minX + blRadius, y: maxY - blRadius)

        if blRadius == 0 {
            addLine(to: center)
        }
        else {
            addLine(to: CGPoint(x: minX + blRadius, y: maxY))
            addArc(withCenter: center, radius: blRadius, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
        }

        close()
    }
}

public extension CGRect {
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self = CGRect(x: newValue, y: self.y, width: self.width, height: self.height)
        }
    }

    var y: CGFloat {
        get {
            return self.origin.y
        }
        set {
            self = CGRect(x: self.x, y: newValue, width: self.width, height: self.height)
        }
    }

    var width: CGFloat {
        get {
            return self.size.width
        }
        set {
            self = CGRect(x: self.x, y: self.y, width: newValue, height: self.height)
        }
    }

    var height: CGFloat {
        get {
            return self.size.height
        }
        set {
            self = CGRect(x: self.x, y: self.y, width: self.width, height: newValue)
        }
    }

    var top: CGFloat {
        get {
            return self.origin.y
        }
        set {
            self.y = newValue
        }
    }

    var bottom: CGFloat {
        get {
            return self.origin.y + self.size.height
        }
        set {
            self = CGRect(x: self.x, y: newValue - self.height, width: self.width, height: self.height)
        }
    }

    var left: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.x = newValue
        }
    }

    var right: CGFloat {
        get {
            return self.x + self.width
        }
        set {
            self = CGRect(x: newValue - self.width, y: self.y, width: self.width, height: self.height)
        }
    }

    var midX: CGFloat {
        get {
            return self.x + self.width / 2
        }
        set {
            self = CGRect(x: newValue - self.width / 2, y: self.y, width: self.width, height: self.height)
        }
    }

    var midY: CGFloat {
        get {
            return self.y + self.height / 2
        }
        set {
            self = CGRect(x: self.x, y: newValue - self.height / 2, width: self.width, height: self.height)
        }
    }

    var center: CGPoint {
        get {
            return CGPoint(x: self.midX, y: self.midY)
        }
        set {
            self = CGRect(x: newValue.x - self.width / 2, y: newValue.y - self.height / 2, width: self.width, height: self.height)
        }
    }
}
