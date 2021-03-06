import UIKit

// swiftlint:disable all
private var normalColorContext: UInt8 = 0
private var highlightedColorContext: UInt8 = 0
private var highlightedOptionsContext: UInt8 = 0
private var highlightedDelayContext: UInt8 = 0
private var highlightedDurationContext: UInt8 = 0
private var animatorContext: UInt8 = 0
private var isEnabledScaleBehaviorContext: UInt8 = 0

extension FluidHighlighter where Base: UIView {
    // MARK: - Properties

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

    private(set) var isEnabledScaleBehavior: Bool {
        get {
            guard
                let isEnable = objc_getAssociatedObject(base, &isEnabledScaleBehaviorContext)
                as? Bool
            else { return false }
            return isEnable
        }
        set {
            objc_setAssociatedObject(
                base, &isEnabledScaleBehaviorContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Public methods

    public func setScaleBehavior(enabled: Bool) {
        isEnabledScaleBehavior = enabled
    }

    public func enable(
        normalColor: UIColor,
        highlightedColor: UIColor,
        highlightedOptions: UIView.AnimationOptions? = nil,
        highlightedDelay: TimeInterval = 0.0,
        highlightedDuration: TimeInterval = 1.0) {
        self.normalColor = normalColor
        self.highlightedColor = highlightedColor
        self.highlightedOptions = highlightedOptions
        self.highlightedDelay = highlightedDelay
        self.highlightedDuration = highlightedDuration

        base.backgroundColor = normalColor

        animatorFluid = UIViewPropertyAnimator()
    }

    public func disable() {
        normalColor = nil
        highlightedColor = nil
        highlightedOptions = nil
        highlightedDelay = 0
        highlightedDuration = 0
    }

    public func touchDown() {
        if isEnabledScaleBehavior {
            let timing = UISpringTimingParameters(damping: 1.0, response: 0.15)
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timing)
            animator.addAnimations { [unowned self] in
                self.base.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }
            animator.startAnimation()
        }

        guard let highlightedColor = highlightedColor, let animator = self.animatorFluid else { return }
        animator.stopAnimation(true)

        base.backgroundColor = highlightedColor
    }

    public func touchUp() {
        if isEnabledScaleBehavior {
            let timing = UISpringTimingParameters(damping: 0.7, response: 0.5)
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timing)
            animator.addAnimations { [unowned self] in
                self.base.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            animator.startAnimation()
        }

        guard let normalColor = normalColor else { return }
        let timing = UISpringTimingParameters(damping: 1.0, response: CGFloat(highlightedDuration))

        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timing)
        animator.addAnimations { [unowned self] in
            self.base.backgroundColor = normalColor
        }

        animatorFluid = animator
        if highlightedDelay == 0 {
            animator.startAnimation()
        } else {
            animator.startAnimation(afterDelay: highlightedDelay)
        }
    }
}

extension UIView {
    // MARK: - Overridden: UIView

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        fh.touchDown()
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        fh.touchUp()
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if let touch = touches.first {
            let position = touch.location(in: self)
            isInside(position: position) ? fh.touchDown() : fh.touchUp()
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        fh.touchUp()
    }

    // MARK: - Private methods

    private func isInside(position: CGPoint) -> Bool {
        let x = position.x
        let y = position.y
        let xIsInFrame = bounds.origin.x <= x && x <= bounds.origin.x + bounds.width * 1.5
        let yIsInFrame = bounds.origin.y <= y && y <= bounds.origin.y + bounds.height * 1.5
        return xIsInFrame && yIsInFrame
    }
}
