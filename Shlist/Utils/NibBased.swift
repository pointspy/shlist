//
//  NibBased.swift
//  CollectionViewPagingLayout
//
//  Created by Amir Khorsandi on 12/23/19.
//  Copyright © 2019 Amir Khorsandi. All rights reserved.
//

import Foundation
import UIKit

protocol NibBased {

    // MARK: Static parameters

    static var nibName: String { get }

}


extension NibBased {

    // MARK: Static parameters

    static var nibName: String {
        String(describing: self)
    }

}

extension NibBased where Self: UIView {

    // MARK: Static functions

    static func instantiate(owner: Any? = nil) -> Self {
        let nib = UINib(nibName: nibName, bundle: nil)
        let items = nib.instantiate(withOwner: owner, options: nil)
        return (items.first! as? Self)!
    }

}


extension NibBased where Self: UIViewController {

    // MARK: Static functions

    static func instantiate() -> Self {
        Self.init(nibName: self.nibName, bundle: Bundle(for: self))
    }

}


extension NibBased where Self: UICollectionViewCell {

    // MARK: Static properties

    static var nib: UINib {
        UINib(nibName: String(describing: self), bundle: nil)
    }

}


extension NibBased where Self: UITableViewCell {

    // MARK: Static properties

    static var nib: UINib {
        UINib(nibName: String(describing: self), bundle: nil)
    }

}


extension UICollectionView {

    // MARK: Public functions

    func register<T: UICollectionViewCell & NibBased>(_ cellType: T.Type, nibName: String? = nil) {
        let nib = nibName.let { UINib(nibName: $0, bundle: nil) } ?? T.nib
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell & NibBased>(for indexPath: IndexPath) -> T {
        (dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T)!
    }

}

extension UITableView {

    // MARK: Public functions

    func register<T: UITableViewCell & NibBased>(_ cellType: T.Type, nibName: String? = nil) {
        let nib = nibName.let { UINib(nibName: $0, bundle: nil) } ?? T.nib
        register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell & NibBased>(for indexPath: IndexPath) -> T {
        (dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T)!
    }

}

extension Optional {
    func `let`<T>(_ transform: (Wrapped) -> T?) -> T? {
        if case .some(let value) = self {
            return transform(value)
        }
        return nil
    }
}

extension UITableView {

    // MARK: Public functions

    func registerClass<T: UITableViewCell>(_ cellType: T.Type, reuseIdentifier: String = T.reuseIdentifier) {
        register(cellType, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func dequeueReusableCellClass<T: UITableViewCell>(for indexPath: IndexPath, type: T.Type? = nil, reuseIdentifier: String = T.reuseIdentifier) -> T {
        (dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? T)!
    }

}


extension UITableViewCell {

    static var reuseIdentifier: String {
        String(describing: self)
    }

}

extension UICollectionView {

    // MARK: Public functions

    func registerClass<T: UICollectionViewCell>(_ cellType: T.Type, reuseIdentifier: String = T.reuseIdentifier) {
        register(cellType, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func dequeueReusableCellClass<T: UICollectionViewCell>(for indexPath: IndexPath, type: T.Type? = nil, reuseIdentifier: String = T.reuseIdentifier) -> T {
        (dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T)!
    }

}


extension UICollectionViewCell {

    static var reuseIdentifier: String {
        String(describing: self)
    }

}
