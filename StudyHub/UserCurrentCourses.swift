//
//  UserCurrentCourses.swift
//  StudyHub
//
//  Created by Dan Levy on 1/8/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

class UserCurrentCourses {
    private var _departmentCodeUID = String()
    private var _courseUID = String()
    private var _sectionUID = String()
    private var _courseID = String()
    private var _courseName = String()
    private var _crnNumber = String()
    private var _sectionNumber = String()
    private var _instructorName = String()
    
    var departmentCodeUID: String {
        return _departmentCodeUID
    }
    var courseUID: String {
        return _courseUID
    }
    var sectionUID: String {
        return _sectionUID
    }
    var courseID: String {
        return _courseID
    }
    var courseName: String {
        return _courseName
    }
    var crnNumber: String {
        return _crnNumber
    }
    var sectionNumber: String {
        return _sectionNumber
    }
    var instructorName: String {
        return _instructorName
    }
    
    init(data: [String : String]) {
        if let departmentCodeUID = data["departmentCodeUID"] {
            self._departmentCodeUID = departmentCodeUID
        }
        if let courseUID = data["courseUID"] {
            self._courseUID = courseUID
        }
        if let sectionUID = data["sectionUID"] {
            self._sectionUID = sectionUID
        }
        if let courseID = data["courseID"] {
            self._courseID = courseID
        }
        if let courseName = data["courseName"] {
            self._courseName = courseName
        }
        if let crnNumber = data["crnNumber"] {
            self._crnNumber = crnNumber
        }
        if let sectionNumber = data["sectionNumber"] {
            self._sectionNumber = sectionNumber
        }
        if let instructorName = data["instructorName"] {
            self._instructorName = instructorName
        }
    }
}
