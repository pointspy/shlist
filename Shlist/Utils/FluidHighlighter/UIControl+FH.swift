import UIKit

private var touchProxyContext: UInt8 = 0
private var normalColorContext: UInt8 = 0
private var highlightedColorContext: UInt8 = 0
private var selectedColorContext: UInt8 = 0
private var highlightedOptionsContext: UInt8 = 0
private var highlightedDelayContext: UInt8 = 0
private var highlightedDurationContext: UInt8 = 0
private var animatorContext: UInt8 = 0

extension FluidHighlighter where Base: UIControl {

    // MARK: - Properties

    private var touchProxy: TouchProxy? {
        get {
            return objc_getAssociatedObject(base, &touchProxyContext) as? TouchProxy
        }
        set {
            objc_setAssociatedObject(
                base, &touchProxyContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private(set) var normalColor: UIColor? {
        get {
            return objc_getAssociatedObject(base, &normalColorContext) as? UIColor
        }
        set {
            objc_setAssociatedObject(
                base, &normalColorContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private(set) var highlightedColor: UIColor? {
        get {
            return objc_getAssociatedObject(base, &highlightedColorContext) as? UIColor
        }
        set {
            objc_setAssociatedObject(
                base, &highlightedColorContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private(set) var selectedColor: UIColor? {
        get {
            return objc_getAssociatedObject(base, &selectedColorContext) as? UIColor
        }
        set {
            objc_setAssociatedObject(
                base, &selectedColorContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private(set) var highlightedOptions: UIView.AnimationOptions? {
        get {
            return objc_getAssociatedObject(base, &highlightedOptionsContext)
                as? UIView.AnimationOptions
        }
        set {
            objc_setAssociatedObject(
                base, &highlightedOptionsContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private(set) var highlightedDelay: TimeInterval {
        get {
            guard
                let delay = objc_getAssociatedObject(base, &highlightedDelayContext)
                    as? TimeInterval
            else { return 0.0 }
            return delay
        }
        set {
            objc_setAssociatedObject(
                base, &highlightedDelayContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private(set) var highlightedDuration: TimeInterval {
        get {
            guard
                let duration = objc_getAssociatedObject(base, &highlightedDurationContext)
                    as? TimeInterval
            else { return 0.0 }
            return duration
        }
        set {
            objc_setAssociatedObject(
                base, &highlightedDurationContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private(set) var animatorFluid: UIViewPropertyAnimator? {
        get {
            return objc_getAssociatedObject(base, &animatorContext)
                as? UIViewPropertyAnimator
        }
        set {
            objc_setAssociatedObject(
                base, &animatorContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Public methods

    public func controlEnable(
        normalColor: UIColor,
        highlightedColor: UIColor,
        selectedColor: UIColor? = nil,
        highlightedOptions: UIView.AnimationOptions? = nil,
        highlightedDelay: TimeInterval = 0.0,
        highlightedDuration: TimeInterval = 1.0
    ) {
        self.normalColor = normalColor
        self.highlightedColor = highlightedColor
        self.selectedColor = selectedColor

        self.highlightedOptions = highlightedOptions
        self.highlightedDelay = highlightedDelay
        self.highlightedDuration = highlightedDuration

        base.backgroundColor = base.isSelected ? selectedColor ?? normalColor : normalColor

        if touchProxy == nil {
            touchProxy = TouchProxy(control: base)
            touchProxy?.addTarget()
        }
    }

    public func controlDisable() {
        normalColor = nil
        highlightedColor = nil
        highlightedOptions = nil
        highlightedDelay = 0
        highlightedDuration = 0

        touchProxy?.removeTarget()
        touchProxy = nil
        self.animatorFluid = UIViewPropertyAnimator()
    }

    public func refreshBackgroundColor() {
        touchProxy?.refreshBackgroundColor()
    }

    // MARK: - Proxy

    fileprivate final class TouchProxy {

        // MARK: - Properties

        private let control: UIControl

        // MARK: - Constructor

        init(control: UIControl) {
            self.control = control
            self.control.fh.animatorFluid = UIViewPropertyAnimator()
        }

        // MARK: - Public methods

        public func addTarget() {
            control.addTarget(
                self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
            control.addTarget(
                self, action: #selector(touchUp),
                for: [.touchUpInside, .touchDragExit, .touchCancel])
        }

        public func removeTarget() {
            control.removeTarget(
                self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
            control.removeTarget(
                self, action: #selector(touchUp),
                for: [.touchUpInside, .touchDragExit, .touchCancel])
        }

        public func refreshBackgroundColor() {
            let timing = UISpringTimingParameters(damping: 1.0, response: CGFloat(control.fh.highlightedDuration))
            
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timing)
            animator.addAnimations {[weak self] in
                guard let self = self else {return}
                self.control.backgroundColor =
                self.control.isSelected
                ? self.control.fh.selectedColor ?? self.control.fh.normalColor
                : self.control.fh.normalColor
            }
            
            self.control.fh.animatorFluid = animator
            if control.fh.highlightedDelay == 0 {
                animator.startAnimation()
            } else {
                animator.startAnimation(afterDelay: control.fh.highlightedDelay)
            }
        }

        // MARK: - Private selector

        @objc private func touchDown() {
            guard let animator = self.control.fh.animatorFluid else { return }
            animator.stopAnimation(true)
            
            control.backgroundColor = control.fh.highlightedColor
        }

        @objc private func touchUp() {
            refreshBackgroundColor()
        }

    }

}
