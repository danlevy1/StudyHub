//
//  CustomBannerColors.swift
//  StudyHub
//
//  Created by Dan Levy on 6/15/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class CustomBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:   return UIColor.red
        case .info:     return studyHubBlue
        case .none:     return UIColor.white
        case .success:  return studyHubGreen
        case .warning:  return UIColor.orange
        }
    }
}
