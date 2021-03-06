//
//  UIKit+Hashable.swift
//  Pixel-iOS
//
//  Created by José Donor on 26/11/2018.
//

import UIKit

// MARK: UIRectCorner

extension UIRectCorner: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.hashValue)
    }
}

// MARK: UIEdgeInsets

extension UIEdgeInsets: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(left.hashValue)
        hasher.combine(top.hashValue)
        hasher.combine(bottom.hashValue)
        hasher.combine(right.hashValue)
    }
}
