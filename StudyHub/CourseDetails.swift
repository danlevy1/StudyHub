//
//  CourseDetails.swift
//  StudyHub
//
//  Created by Dan Levy on 12/27/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation

class CourseDetails {
    private var _crnNumber = String()
    private var _instructorName = String()
    private var _sectionNumber = String()
    
    var crnNumber: String {
        return _crnNumber
    }
    
    var instructorName: String {
        return _instructorName
    }
    
    var sectionNumber: String {
        return _sectionNumber
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
    }
}
