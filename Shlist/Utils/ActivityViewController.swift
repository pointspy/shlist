//
//  ActivityViewController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 05.02.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import UIKit

struct ShareSheet {
    typealias Callback = (
        _ activityType: UIActivity.ActivityType?,
        _ completed: Bool,
        _ returnedItems: [Any]?,
        _ error: Error?) -> Void

    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    var excludedActivityTypes: [UIActivity.ActivityType]?
    var callback: Callback?

    func makeActivityController() -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
}
