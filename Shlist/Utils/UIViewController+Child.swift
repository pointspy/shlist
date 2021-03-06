//
//  UIViewController+child.swift
//  Knot_Example
//
//  Created by Лысков Павел on 12.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIViewController {
    public func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    public func add(_ child: UIViewController, to customView: UIView) {
        addChild(child)
        customView.addSubview(child.view)
        child.didMove(toParent: self)
    }

    public func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
