//
//  UIViewController+Ext.swift
//  Shlist
//
//  Created by Pavel Lyskov on 23.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import UIKit

extension UIViewController {

    public func showSimpleAlert(with title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let ok = UIAlertAction(title: "Ok", style: .default, handler: { _ in })

        alert.addAction(ok)

        self.present(alert, animated: true, completion: nil)

    }
    
    public func showOkCancel(message: String, okButtonTitle: String, successHandler: @escaping () -> Void) {

        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        let ok = UIAlertAction(title: okButtonTitle, style: .default, handler: {_ in
            successHandler()
        })

        alert.addAction(cancelAction)
        alert.addAction(ok)

        self.present(alert, animated: true, completion: nil)

    }


}

extension UIViewController {
    
    public var isDarkMode: Bool {
        return self.traitCollection.userInterfaceStyle == .dark
    }
    
    /// Get the view of current top UIViewController
    ///
    /// - Returns: The view of UIViewController
    public static func dl_topView() -> UIView? {
        return dl_topViewController()?.view
    }
    
     
    
    public static func dl_topViewController(rootViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        
        var topViewController = rootViewController
        var presentedViewController = rootViewController.presentedViewController
        while presentedViewController != nil {
            topViewController = presentedViewController!
            presentedViewController = topViewController.presentedViewController
        }
        
        if let navigationController = topViewController as? UINavigationController {
           
            return dl_topViewController(rootViewController: navigationController.topViewController)
        }
        
        if let tabBarController = topViewController as? UITabBarController {
            return dl_topViewController(rootViewController: tabBarController.selectedViewController)
        }
        
        if topViewController.children.count > 0 {
            return dl_topViewController(rootViewController:topViewController.children[0])
        }
        
        return topViewController
    }
    
    public static func dl_rootViewController() -> UIViewController? {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        
        return rootViewController
    }
    
    
    
    public func dl_hideNavigationBackTitle() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
