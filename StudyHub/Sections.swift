//
//  Sections.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation

class Sections {
    private var _sectionNumber = String()
    private var _crnNumber = String()
    private var _instructorName = String()
    private var _sectionUID = String()
    
    var sectionNumber: String {
        return _sectionNumber
    }
    var crnNumber: String {
        return _crnNumber
    }
    var instructorName: String {
        return _instructorName
    }
    var sectionUID: String {
        return _sectionUID
    }
    
    init(data: [String : String]) {
        if let crnNumber = data["crnNumber"] {
            self._crnNumber = crnNumber
        }
        if let instructorName = data["instructorName"] {
            self._instructorName = instructorName
        }
        if let sectionNumber = data["sectionNumber"] {
            self._sectionNumber = sectionNumber
        }
        if let sectionUID = data["sectionUID"] {
            self._sectionUID = sectionUID
        }
    }
}
