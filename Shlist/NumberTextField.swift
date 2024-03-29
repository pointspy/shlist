//
//  PriceField.swift
//  Shlist
//
//  Created by Pavel Lyskov on 10.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxBiBinding
import RxCocoa
import RxSwift
// import RxSwiftExt
import UIKit

//@IBDesignable
public final class NumberTextField: UITextField {
    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    public private(set) var disposedBag = DisposeBag()
    
    public struct Settings {
        let borderColor: UIColor
        let borderColorHighlighted: UIColor
        let cornerRadius: CGFloat
        
        let minValue: Double
        let maxValue: Double
        
        static let defaultSettings = Settings(borderColor: 0x767680.color.withAlphaComponent(0.24), borderColorHighlighted: 0x767680.color, cornerRadius: 12.0, minValue: 0, maxValue: Double.greatestFiniteMagnitude)
    }
    
    var settings = Settings.defaultSettings {
        didSet {
            layer.borderColor = settings.borderColor.cgColor
            layer.borderWidth = 1
            layer.cornerRadius = settings.cornerRadius
            layer.cornerCurve = .continuous
            
            minValue = settings.minValue
            maxValue = settings.maxValue
        }
    }
    
//    @IBInspectable
    public var minValue: Double = 0 {
        didSet {
            stepper.minimumValue = minValue
            doubleRelay.accept(minValue)
        }
    }

//    @IBInspectable
    public var maxValue = Double.greatestFiniteMagnitude {
        didSet {
            stepper.maximumValue = maxValue
        }
    }

    private lazy var textRelay: BehaviorRelay<String?> = .init(value: "\(self.minValue)")
    
    public lazy var doubleRelay: BehaviorRelay<Double> = .init(value: self.minValue)
    
    public var doubleDriver: Driver<Double> {
        return doubleRelay.asDriver()
    }
    
    public func hideStepper(hide: Bool) {
        stepper.isHidden = hide
    }
    
    public var numberValue: Double {
        get { return doubleRelay.value }
        set { doubleRelay.accept(newValue) }
    }
      
    private lazy var stepper = UIStepper()
    
    var stepperWidth: CGFloat {
        if stepper.isHidden {
            return 0
        } else {
            return NumberTextField.stepperBounds.width
        }
    }

    private var textInsets: UIEdgeInsets {
        let rightInset: CGFloat = 8 + stepperWidth + 8
        return .init(top: 2, left: 12, bottom: 2, right: rightInset)
    }
     
    static let stepperBounds = CGRect(x: 0, y: 0, width: 94, height: 32)

    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup(with: nil)
    }
//    
    public func setup(with settings: Settings?) {

        
        rightView = stepper
        rightViewMode = .always
        
        if let newSettings = settings {
            self.settings = newSettings
        } else {
            self.settings = Settings.defaultSettings
        }
        
//        keyboardType = .numberPad
    }
//    
    public override func awakeFromNib() {
        super.awakeFromNib()
        disposedBag = DisposeBag()
        setup(with: nil)
        
        (rx.text <-> textRelay).disposed(by: disposedBag)
        (stepper.rx.valueDouble <-> doubleRelay).disposed(by: disposedBag)

        (textRelay <~> doubleRelay).disposed(by: disposedBag)
        
        
    }
//    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)


    }
////
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return NumberTextField.getStepperFrame(for: bounds)
    }

    static func getStepperFrame(for textFieldBounds: CGRect) -> CGRect {
        let stepperX: CGFloat = textFieldBounds.width - 6 - stepperBounds.width
        let stepperY: CGFloat = (textFieldBounds.height - stepperBounds.height) / 2

        return CGRect(x: stepperX, y: stepperY, width: stepperBounds.width, height: stepperBounds.height)
    }
    
//    static func newWithBounds(_ width: CGFloat, settings: Settings = Settings.defaultSettings) -> NumberTextField {
//        let bounds = CGRect(x: 0, y: 0, width: width, height: 40)
//
//        let textField = NumberTextField(frame: bounds)
//
//        textField.setup(with: settings)
//
//        textField.settings = settings
//
//        return textField
//    }
}


public extension Reactive where Base: NumberTextField {
    var currentValue: ControlProperty<Double> {
        return value
    }

    var value: ControlProperty<Double> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { textField in
            textField.numberValue
        }, setter: { textField, value in
            textField.numberValue = value
        })
    }
}

public extension Reactive where Base: UIStepper {
    var currentValueInt: ControlProperty<Int> {
        return valueInt
    }

    var valueInt: ControlProperty<Int> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { stepper in
            stepper.value.asInt
        }, setter: { stepper, value in
            stepper.value = value.asDouble
        })
    }
    
    var currentValueDouble: ControlProperty<Double> {
        return valueDouble
    }

    var valueDouble: ControlProperty<Double> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { stepper in
            stepper.value
        }, setter: { stepper, value in
            stepper.value = value
        })
    }
}
