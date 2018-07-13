//
//  CourseSection.swift
//  StudyHub
//
//  Created by Dan Levy on 12/28/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class Section {
    private var _uid = String()
    private var _number = String()
    private var _instructorName = String()
    private var _crn = String()
    private var _schedule = String()
    private var _info = NSAttributedString()
    
 var uid: String {
        return _uid
    }
    var number: String {
        return _number
    }
    var instructorName: String {
        return _instructorName
    }
    var schedule: String {
        return _schedule
    }
    var info: NSAttributedString {
        return _info
    }
    
    init(data: [String : String]) {
        if let uid = data["sectionUID"] {
            self._uid = uid
        }
        let attributedString = NSMutableAttributedString()
        if let number = data["sectionNumber"] {
            self._number = number
            attributedString.append(attributedString.newAttributedString(string: "Section " + number, color: .white, stringAlignment: .left, fontSize: 25, fontWeight: UIFontWeightBold, paragraphSpacing: 5))
        }
        if let instructorName = data["instructorName"] {
            self._instructorName = instructorName
            attributedString.append(attributedString.newAttributedString(string: "\n" + instructorName, color: .white, stringAlignment: .left, fontSize: 23, fontWeight: UIFontWeightRegular, paragraphSpacing: 5))
        }
        if let crn = data["crnNumber"] {
            self._crn = crn
            attributedString.append(attributedString.newAttributedString(string: "\nCRN: " + crn, color: .white, stringAlignment: .left, fontSize: 21, fontWeight: UIFontWeightLight, paragraphSpacing: 5))
        }
        if let schedule = data["sectionSchedule"] {
            self._schedule = schedule
            attributedString.append(attributedString.newAttributedString(string: "\n" + schedule, color: .white, stringAlignment: .left, fontSize: 19, fontWeight: UIFontWeightThin, paragraphSpacing: 5))
        }
        self._info = attributedString
    }
}
