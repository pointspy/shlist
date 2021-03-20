//
//  UIKit+Functional+Setters.swift
//  Shlist
//
//  Created by Pavel Lyskov on 13.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Overture
import UIKit

let roundedStyle = concat(
    mut(\UIView.clipsToBounds, true),
    mut(\.layer.cornerRadius, 6)
)

@discardableResult
func withMaskedTopCorners() -> (UIView) -> Void {
    return { (view: UIView) -> Void in
        view.layer.maskedCorners.insert([.layerMaxXMinYCorner, .layerMinXMinYCorner])
    }
}

@discardableResult
func withFluidBackground(normalColor: UIColor, highlightedColor: UIColor) -> (UIView) -> Void {
    return { (view: UIView) -> Void in
        view.fh.enable(normalColor: normalColor, highlightedColor: highlightedColor)
    }
}

@discardableResult
func withMaskedBottomCorners() -> (UIView) -> Void {
    return { (view: UIView) -> Void in
        view.layer.maskedCorners.insert([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
    }
}

@discardableResult
func withMaskedCorners() -> (UIView) -> Void {
    return concat(
        withMaskedTopCorners(),
        withMaskedBottomCorners()
    )
}

@discardableResult
func rounded(with radius: CGFloat) -> (UIView) -> Void {
    return concat(
        mut(\UIView.clipsToBounds, true),
        mut(\.layer.cornerRadius, radius)
    )
}

@discardableResult
func withBackground(color: UIColor) -> (UIView) -> Void {
    return concat(
        mut(\UIView.backgroundColor, color)
    )
}

@discardableResult
func borderStyle(color: UIColor, width: CGFloat) -> (UIView) -> Void {
    return concat(
        mut(\UIView.layer.borderColor, color.cgColor),
        mut(\.layer.borderWidth, width)
    )
}

@discardableResult
func add(to superView: UIView) -> (UIView) -> Void {
    return { view in
        superView.addSubview(view)
    }
}

@discardableResult
func layoutEdgesToSuperView(with insets: UIEdgeInsets = UIEdgeInsets.zero) -> (UIView) -> Void {
    { (view: UIView) -> Void in
        guard let superV = view.superview else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: superV.leadingAnchor, constant: insets.left),
            view.topAnchor.constraint(equalTo: superV.topAnchor, constant: insets.top),
            view.trailingAnchor.constraint(equalTo: superV.trailingAnchor, constant: -insets.right),
            view.bottomAnchor.constraint(equalTo: superV.bottomAnchor, constant: -insets.bottom),
        ])
    }
}

@discardableResult
func edgeTo(superView: UIView, with insets: UIEdgeInsets = UIEdgeInsets.zero) -> (UIView) -> Void {
    return concat(
        add(to: superView),
        layoutEdgesToSuperView(with: insets)
    )
}

@discardableResult
func buttonFont(_ font: UIFont) -> (UIButton) -> Void {
    return { $0.titleLabel?.font = font }
}

@discardableResult
func buttonTitle(_ title: String, for state: UIControl.State = .normal) -> (UIButton) -> Void {
    return { $0.setTitle(title, for: state) }
}

@discardableResult
func buttonTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> (UIButton) -> Void
{
    return { $0.setTitleColor(color, for: state) }
}

@discardableResult
func withTint(color: UIColor) -> (UITextField) -> Void {
    return { $0.tintColor = color }
}

@discardableResult
func withTextColor(color: UIColor) -> (UITextField) -> Void {
    return { $0.textColor = color }
}

@discardableResult
func withTextAligment(_ aligment: NSTextAlignment) -> (UITextField) -> Void {
    return concat(mver(\UITextField.textAlignment) { $0 = aligment })
}

@discardableResult
func withFont(_ font: UIFont) -> (UITextField) -> Void {
    return { $0.font = font }
}

@discardableResult
func withText(_ text: String?) -> (UITextField) -> Void {
    return { $0.text = text }
}

@discardableResult
func withoutRuble() -> (UITextField) -> Void {
    return {
        guard let text = $0.text else { return }

        let strNew = text.replacingOccurrences(of: "\(NSLocalizedString("common.currency", comment: ""))", with: "")
        $0.text = strNew
    }
}

@discardableResult
func withTextColor(color: UIColor) -> (UILabel) -> Void {
    return { $0.textColor = color }
}

@discardableResult
func withImage(_ image: UIImage?) -> (UIImageView) -> Void {
    return { $0.image = image }
}

public struct AsyncOperation<Value> {
    let queue: DispatchQueue = .main
    let closure: () -> Value

    func perform(then handler: @escaping (Value) -> Void) {
        queue.async {
            let value = self.closure()
            handler(value)
        }
    }
}
