//
//  GlobalFunctions.swift
//  StudyHub
//
//  Created by Dan Levy on 7/19/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

// Custom NSAttributedString
func newAttributedString(string: String, color: UIColor, stringAlignment: NSTextAlignment, fontSize: CGFloat, fontWeight: UIFont.Weight, paragraphSpacing: CGFloat) -> NSAttributedString {
    let style = NSMutableParagraphStyle()
    style.alignment = stringAlignment
    style.paragraphSpacing = paragraphSpacing
    return NSAttributedString(string: string, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight), NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.paragraphStyle: style])
}
