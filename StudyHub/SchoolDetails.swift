//
//  SchoolDetails.swift
//  StudyHub
//
//  Created by Dan Levy on 1/7/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

class SchoolDetails {
    private var _schoolName = String()
    private var _schoolLocation = String()
    
    var schoolName: String {
        return _schoolName
    }
    var schoolLocation: String {
        return _schoolLocation
    }
    
    init(data: [String : String]) {
        if let schoolName = data["schoolName"] {
            self._schoolName = schoolName
        }
        if let schoolLocation = data["schoolLocation"] {
            self._schoolLocation = schoolLocation
        }
    }
}
