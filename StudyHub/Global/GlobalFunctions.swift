//
//  GlobalFunctions.swift
//  StudyHub
//
//  Created by Dan Levy on 7/19/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

// Custom NSAttributedString
func newAttributedString(string: String, color: UIColor, stringAlignment: NSTextAlignment, fontSize: CGFloat, fontWeight: UIFontWeight, paragraphSpacing: CGFloat) -> NSAttributedString {
    let style = NSMutableParagraphStyle()
    style.alignment = stringAlignment
    style.paragraphSpacing = paragraphSpacing
    return NSAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize, weight: fontWeight), NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: style])
}
