//
//  CG+Hashable.swift
//  Pixel-iOS
//
//  Created by José Donor on 26/11/2018.
//

import UIKit

// MARK: CGPoint

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x.hashValue)
        hasher.combine(y.hashValue)
    }
}

// MARK: CGVector

extension CGVector: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dx.hashValue)
        hasher.combine(dy.hashValue)
    }
}

// MARK: CGSize

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width.hashValue)
        hasher.combine(height.hashValue)
    }
}

// MARK: CGRect

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.hashValue)
        hasher.combine(size.hashValue)
    }
}
