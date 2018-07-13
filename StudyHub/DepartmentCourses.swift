//
//  DepartmentCourses.swift
//  StudyHub
//
//  Created by Dan Levy on 1/7/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

class DepartmentCourses {
    private var _courseUID = String()
    private var _courseID = String()
    private var _courseName = String()
    
    var courseUID: String {
        return _courseUID
    }
    var courseID: String {
        return _courseID
    }
    var courseName: String {
        return _courseName
    }
    
    init(data: [String : String]) {
        if let courseUID = data["courseUID"] {
            self._courseUID = courseUID
        }
        if let courseID = data["courseID"] {
            self._courseID = courseID
        }
        if let courseName = data["courseName"] {
            self._courseName = courseName
        }
    }
}
