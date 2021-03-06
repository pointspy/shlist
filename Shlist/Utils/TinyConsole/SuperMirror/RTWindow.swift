//
//  RTWindow.swift
//  OnLime
//
//  Created by Лысков Павел on 13.03.2020.
//  Copyright © 2020 Dart-IT. All rights reserved.
//

import UIKit

public final class RTWindow: UIWindow {
    var isAbleToReceiveTouches = false

    init(with rootVC: UIViewController) {
        if #available(iOS 13.0, *) {
            // TODO: Patched to support SwiftUI out of the box but should require attendance
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                super.init(windowScene: scene)
            } else {
                super.init(frame: UIScreen.main.bounds)
            }
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        backgroundColor = .clear
        rootViewController = rootVC
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        if let vc = TinyConsole.shared.consoleController.getConsoleVC() as? TinyConsoleViewController {
            if vc.view.frame.contains(point) == true {
                return true
            }
        }

        return false
    }
}
