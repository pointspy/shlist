//
//  PriceField.swift
//  Shlist
//
//  Created by Pavel Lyskov on 10.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import UIKit

final class PriceField: UITextField {

    let textInsets: UIEdgeInsets = .init(top: 2, left: 8, bottom: 2, right: 8)

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

}
