//
//  ChromaColorPicker.swift
//  ChromaColorPicker
//
//  Created by Jon Cardasis on 3/10/19.
//  Copyright © 2019 Jonathan Cardasis. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public protocol ChromaColorPickerDelegate: class {
    /// When a handle's value has changed.
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor)
}

@IBDesignable
public class ChromaColorPicker: UIControl, ChromaControlStylable {
    public weak var delegate: ChromaColorPickerDelegate?
    
    public var mainColor: UIColor {
        get {
            guard let first = self.handles.first else {
                return .white
            }
            
            return first.color
        }
        
        set {
            guard let first = self.handles.first else {
                return
            }
            
            first.color = newValue
            
            if let slider = self.brightnessSlider {
                slider.trackColor = newValue
            }
            
            sendActions(for: .valueChanged)
            
            UIView.animate(withDuration: 0.217, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [.beginFromCurrentState], animations: {
                self.layoutSubviews()
            }, completion: nil)
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 6.0 {
        didSet { layoutNow() }
    }
    
    @IBInspectable public var borderColor: UIColor = .white {
        didSet { layoutNow() }
    }
    
    @IBInspectable public var showsShadow: Bool = true {
        didSet { layoutNow() }
    }
    
    /// A brightness slider attached via the `connect(_:)` method.
    public private(set) weak var brightnessSlider: ChromaBrightnessSlider? {
        didSet {
            oldValue?.removeTarget(self, action: nil, for: .valueChanged)
        }
    }
    
    /// The size handles should be displayed at.
    public var handleSize: CGSize = defaultHandleSize {
        didSet { setNeedsLayout() }
    }
    
    /// An extension to handles' hitboxes in the +Y direction.
    /// Allows for handles to be grabbed more easily.
    public var handleHitboxExtensionY: CGFloat = 10.0
    
    /// Handles added to the color picker.
    public var handles: [ChromaColorHandle] = []
    
    /// The last active handle.
    public var currentHandle: ChromaColorHandle?
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowIfNeeded()
        updateBorderIfNeeded()
        
        handles.forEach { handle in
            let location = colorWheelView.location(of: handle.color)
            handle.frame.size = handleSize
            positionHandle(handle, forColorLocation: location)
        }
    }
    
    // MARK: - Public
    
    @discardableResult
    public func addHandle(at color: UIColor? = nil) -> ChromaColorHandle {
        let handle = ChromaColorHandle()
        handle.color = color ?? defaultHandleColorPosition
        addHandle(handle)
        return handle
    }
    
    public func addHandle(_ handle: ChromaColorHandle) {
        handles.append(handle)
        colorWheelView.addSubview(handle)
        brightnessSlider?.trackColor = handle.color
    }
    
    public func connect(_ slider: ChromaBrightnessSlider) {
        slider.addTarget(self, action: #selector(brightnessSliderDidValueChange(_:)), for: .valueChanged)
        brightnessSlider = slider
    }
    
    // MARK: - Control
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: colorWheelView)
        
        for handle in handles {
            if extendedHitFrame(for: handle).contains(location) {
                colorWheelView.bringSubviewToFront(handle)
                animateHandleScale(handle, shouldGrow: true)
                
                if let slider = brightnessSlider {
                    slider.trackColor = handle.color.withBrightness(1)
                    slider.currentValue = slider.value(brightness: handle.color.brightness)
                }
                
                currentHandle = handle
                return true
            }
        }
        return false
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        var location = touch.location(in: colorWheelView)
        guard let handle = currentHandle else { return false }
        
        if !colorWheelView.pointIsInColorWheel(location) {
            // Touch is outside color wheel and should map to outermost edge.
            let center = colorWheelView.middlePoint
            let radius = colorWheelView.radius
            let angleToCenter = atan2(location.x - center.x, location.y - center.y)
            let positionOnColorWheelEdge = CGPoint(x: center.x + radius * sin(angleToCenter),
                                                   y: center.y + radius * cos(angleToCenter))
            location = positionOnColorWheelEdge
        }
        
        if let pixelColor = colorWheelView.pixelColor(at: location) {
            let previousBrightness = handle.color.brightness
            handle.color = pixelColor.withBrightness(previousBrightness)
            positionHandle(handle, forColorLocation: location)
            
            if let slider = brightnessSlider {
                slider.trackColor = pixelColor
                slider.currentValue = slider.value(brightness: previousBrightness)
            }
            
            informDelegateOfColorChange(on: handle)
            sendActions(for: .valueChanged)
        }
        
        return true
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let handle = currentHandle {
            animateHandleScale(handle, shouldGrow: false)
        }
        sendActions(for: .touchUpInside)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Self should handle all touch events, forwarding if needed.
        let touchableBounds = bounds.insetBy(dx: -handleSize.width, dy: -handleSize.height)
        return touchableBounds.contains(point) ? self : super.hitTest(point, with: event)
    }
    
    // MARK: - Private
    
    internal let colorWheelView = ColorWheelView()
    internal var colorWheelViewWidthConstraint: NSLayoutConstraint!
    
    internal func commonInit() {
        backgroundColor = UIColor.clear
        setupColorWheelView()
    }
    
    internal func setupColorWheelView() {
        colorWheelView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorWheelView)
        colorWheelViewWidthConstraint = colorWheelView.widthAnchor.constraint(equalTo: widthAnchor)
        
        NSLayoutConstraint.activate([
            colorWheelView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            colorWheelView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            colorWheelViewWidthConstraint,
            colorWheelView.heightAnchor.constraint(equalTo: colorWheelView.widthAnchor),
        ])
    }
    
    func updateShadowIfNeeded() {
        if showsShadow {
            applyDropShadow(shadowProperties(forHeight: bounds.height))
        } else {
            removeDropShadow()
        }
    }
    
    internal func updateBorderIfNeeded() {
        // Use view's background as a border so colorWheel subviews (handles)
        // may appear above the border.
        backgroundColor = borderWidth > 0 ? borderColor : .clear
        layer.cornerRadius = bounds.height / 2.0
        layer.masksToBounds = false
        colorWheelViewWidthConstraint.constant = -borderWidth * 2.0
    }
    
    // MARK: Actions
    
    @objc
    internal func brightnessSliderDidValueChange(_ slider: ChromaBrightnessSlider) {
        mainColor = slider.currentColor
        
        guard let currentHandle = currentHandle else { return }
        
        informDelegateOfColorChange(on: currentHandle)
    }
    
    internal func informDelegateOfColorChange(on handle: ChromaColorHandle) { // TEMP:
        delegate?.colorPickerHandleDidChange(self, handle: handle, to: handle.color)
    }
    
    // MARK: - Helpers
    
    internal func extendedHitFrame(for handle: ChromaColorHandle) -> CGRect {
        var frame = handle.frame
        frame.size.height += handleHitboxExtensionY
        return frame
    }
    
    internal func positionHandle(_ handle: ChromaColorHandle, forColorLocation location: CGPoint) {
        handle.center = location.applying(CGAffineTransform.identity.translatedBy(x: 0, y: -handle.bounds.height / 2))
    }
    
    internal func animateHandleScale(_ handle: ChromaColorHandle, shouldGrow: Bool) {
        if shouldGrow, handle.transform.d > 1 { return } // Already grown
        let scalar: CGFloat = 1.25
        
        var transform: CGAffineTransform = .identity
        if shouldGrow {
            let translateY = -handle.bounds.height * (scalar - 1) / 2
            transform = CGAffineTransform(scaleX: scalar, y: scalar).translatedBy(x: 0, y: translateY)
        }
        
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
            handle.transform = transform
        }, completion: nil)
    }
}

internal let defaultHandleColorPosition: UIColor = .white
internal let defaultHandleSize: CGSize = CGSize(width: 42, height: 52)

extension Reactive where Base: ChromaColorPicker {
    /// Reactive wrapper for `date` property.
    public var color: ControlProperty<UIColor> {
        return value
    }
    
    /// Reactive wrapper for `value` property.
    public var value: ControlProperty<UIColor> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: {
            $0.mainColor
        }, setter: { picker, color in
            picker.mainColor = color
        })
    }
}
