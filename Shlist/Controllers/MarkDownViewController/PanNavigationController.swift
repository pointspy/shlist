//
//  PanNavigationController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 01.03.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//
import UIKit
import PanModal
import MarkdownView

final class PanNavigationController: UINavigationController, PanModalPresentable {


    init(contentVC: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = contentVC
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        panModalSetNeedsLayoutUpdate()
        return vc
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        panModalSetNeedsLayoutUpdate()
    }

    // MARK: - Pan Modal Presentable
    var panScrollable: UIScrollView? {
        
//        if let vc = topViewController as? MarkDownViewController {
//            return vc.mdView.webView?.scrollView
//        }
        
        return (topViewController as? PanModalPresentable)?.panScrollable
    }

    var longFormHeight: PanModalHeight {
        return .maxHeight
    }

    var shortFormHeight: PanModalHeight {
        return longFormHeight
    }
}

extension PanNavigationController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                Settings.Colors.themeService.switch(Settings.Colors.ThemeType.dark)
                
            } else {
                Settings.Colors.themeService.switch(Settings.Colors.ThemeType.light)
            }
            view.backgroundColor = .systemBackground
        }
    }
}
