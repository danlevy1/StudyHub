//
//  CourseSections.swift
//  StudyHub
//
//  Created by Dan Levy on 12/28/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation

class CourseSections {
    private var _sectionUID = String()
    private var _info = NSAttributedString()
    
    var sectionNumberAndInstructorName: String {
        return _sectionNumberAndInstructorName
    }
    var sectionSchedule: String {
        return _sectionSchedule
    }
    var sectionUID: String {
        return _sectionUID
    }
    var crnNumber: String {
        return _crnNumber
    }
    var instructorName: String {
        return _instructorName
    }
    
    init(data: [String : String]) {
        var sectionNumberAndInstructorName = String()
        if let sectionNumber = data["sectionNumber"] {
            sectionNumberAndInstructorName = "Section " + sectionNumber
        }
        if let instructorName = data["instructorName"] {
            self._instructorName = instructorName
            if (sectionNumberAndInstructorName.characters.count >= 1) {
                sectionNumberAndInstructorName = sectionNumberAndInstructorName + " with " + instructorName
            } else {
                sectionNumberAndInstructorName = instructorName + "(section number n/a)"
            }
        }
        self._sectionNumberAndInstructorName = sectionNumberAndInstructorName
        if let sectionUID = data["sectionUID"] {
            self._sectionUID = sectionUID
        }
        if let sectionSchedule = data["sectionSchedule"] {
            self._sectionSchedule = sectionSchedule
        }
        if let crnNumber = data["crnNumber"] {
            self._crnNumber = "CRN: " + crnNumber
        }
    }
}
