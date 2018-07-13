//
//  Schools.swift
//  StudyHub
//
//  Created by Dan Levy on 1/1/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

class Schools {
    private var _schoolUID = String()
    private var _schoolName = String()
    private var _schoolLocation = String()
    
    var schoolUID: String {
        return _schoolUID
    }
    var schoolName: String {
        return _schoolName
    }
    var schoolLocation: String {
        return _schoolLocation
    }
    
    init(data: [String : String]) {
        if let schoolUID = data["schoolUID"] {
            self._schoolUID = schoolUID
        }
        if let schoolName = data["schoolName"] {
            self._schoolName = schoolName
        }
        if let schoolLocation = data["schoolLocation"] {
            self._schoolLocation = schoolLocation
        }
    }
}
