//
//  CGRect+Ext.swift
//  Shlist
//
//  Created by Pavel Lyskov on 28.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import UIKit

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let originPoint = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        self.init(origin: originPoint, size: size)
    }
    
    var bounds: CGRect {
        return CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
    
    var topLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.minY)
    }
    
    var bottomLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.maxY)
    }
    
    var bottomRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.maxY)
    }
    
    var topRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.minY)
    }
    
    static func with(edgeWidth: CGFloat) -> CGRect {
        return CGRect(origin: .zero, size: CGSize(width: edgeWidth, height: edgeWidth))
    }
    
    static func with(width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(origin: .zero, size: CGSize(width: width, height: height))
    }
    
    static func withCenter(width: CGFloat, height: CGFloat, center: CGPoint) -> CGRect {
        return CGRect(origin: CGPoint(x: center.x - width / 2, y: center.y - height / 2), size: CGSize(width: width, height: height))
    }
    
    func insetRect(procent: CGFloat) -> CGRect {
        return CGRect.withCenter(width: self.width * procent, height: self.height * procent, center: self.center)
    }
    
    func newWithoutWidth(_ width: CGFloat) -> CGRect {
        return CGRect(x: self.x, y: self.y, width: self.width - width, height: self.height)
    }
}
