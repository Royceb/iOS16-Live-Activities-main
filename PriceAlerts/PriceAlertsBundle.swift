//
//  PriceAlertsBundle.swift
//  PriceAlerts
//
//  Created by Royce Brooks on 1/13/24.
//

import WidgetKit
import SwiftUI

@main
struct PriceAlertsBundle: WidgetBundle {
    var body: some Widget {
        PriceAlerts()
        PriceAlertLiveActivityWidget()
    }
}
