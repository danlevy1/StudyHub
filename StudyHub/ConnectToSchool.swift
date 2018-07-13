//
//  ConnectToSchool.swift
//  StudyHub
//
//  Created by Dan Levy on 11/22/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation

class School {
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
    
    init(schoolData: [String : String]) {
        if let schoolUID = schoolData["schoolUID"] {
            self._schoolUID = schoolUID
        }
        if let schoolName = schoolData["schoolName"] {
            self._schoolName = schoolName
        }
        if let schoolLocation = schoolData["schoolLocation"] {
            self._schoolLocation = schoolLocation
        }
        // TODO: Need to add createdDate?
        
    }
}
