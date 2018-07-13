//
//  Coursess.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation

class Coursess {
    private var _courseName = String()
    private var _courseID = String()
    private var _courseUID = String()
    
    var courseName: String {
        return _courseName
    }
    var courseID: String {
        return _courseID
    }
    var courseUID: String {
        return _courseUID
    }
    
    init(data: [String : String]) {
        if let courseName = data["courseName"] {
            self._courseName = courseName
        }
        if let courseID = data["courseID"] {
            self._courseID = courseID
        }
        if let courseUID = data["courseUID"] {
            self._courseUID = courseUID
        }
    }
}
