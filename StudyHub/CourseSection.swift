//
//  CourseSection.swift
//  StudyHub
//
//  Created by Dan Levy on 12/28/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class CourseSection {
    private var _uid = String()
    private var _info = NSAttributedString()
    
    var uid: String {
        return _uid
    }
    var info: NSAttributedString {
        return _info
    }
    
    init(data: [String : String]) {
        if let uid = data["sectionUID"] {
            self._uid = uid
        }
        let attributedText = NSMutableAttributedString()
        if let number = data["sectionNumber"] {
            attributedText.append(NSAttributedString(string: "Section " + number, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.white]))
        }
        if let instructorName = data["instructorName"] {
            attributedText.append(NSAttributedString(string: "\n" + instructorName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.white]))
        }
        if let crn = data["crnNumber"] {
            attributedText.append(NSAttributedString(string: "\nCRN: " + crn, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.white]))
        }
        if let schedule = data["sectionSchedule"] {
            attributedText.append(NSAttributedString(string: "\n" + schedule, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.white]))
        }
        self._info = attributedText
    }
}
