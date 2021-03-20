//
//  ToastView.swift
//  Shlist
//
//  Created by Pavel Lyskov on 06.03.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import UIKit
import SwiftEntryKit
import Lottie

final class ToastView: UIView {
    
    @IBOutlet weak var lottieView: AnimationView!
    
    @IBOutlet weak var messageLabel: UILabel!
    var message: NSAttributedString = NSAttributedString(string: "")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    init(attrMessage: NSAttributedString) {
        super.init(frame: .zero)
        self.message = attrMessage
        setup()
    }
    
    private func setup() {
        fromNib()
        clipsToBounds = true
        layer.cornerRadius = 5
        self.messageLabel.attributedText = message
        self.lottieView.loopMode = .playOnce
        self.lottieView.backgroundColor = .clear
        self.lottieView.contentMode = .scaleAspectFit
        self.lottieView.animationSpeed = 1.5
//        self.imageView.image = UIImage(systemName: "plus.circle.fill")?.with(color: Settings.Colors.blue)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.bounds.height / 2
    }
    
    public func play() {
        self.lottieView.play()
    }
}

extension ToastView {
    
    static func bottomFloatAttributes(keyboardHeight: CGFloat) -> EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .init(1.5)
        attributes.entryBackground = .clear
        attributes.screenBackground = .clear
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 36
            )
        )
        attributes.screenInteraction = .forward
        attributes.entryInteraction = .dismiss
        attributes.scroll = .enabled(
            swipeable: true,
            pullbackAnimation: .jolt
        )
        attributes.roundCorners = .all(radius: 15)
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.35,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            scale: .init(
                from: 1.05,
                to: 1,
                duration: 0.217,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.15)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        )
        attributes.positionConstraints.verticalOffset = keyboardHeight + 24
        attributes.positionConstraints.size = .init(
            width: .intrinsic,
            height: .intrinsic
        )
        attributes.positionConstraints.safeArea = .overridden
        attributes.positionConstraints.maxSize = .init(
            width: .offset(value: 20),
            height: .constant(value: 350)
        )
        
        
//        attributes.statusBar = .dark

        return attributes
    }
    
}
