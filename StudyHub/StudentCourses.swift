//
//  StudentCourses.swift
//  StudyHub
//
//  Created by Dan Levy on 1/6/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

class StudentCourses {
    private var _courseUID = String()
    private var _departmentCodeUID = String()
    private var _courseIdAndName = String()
    private var _instructorName = String()
    
    var courseUID: String {
        return _courseUID
    }
    var departmentCodeUID: String {
        return _departmentCodeUID
    }
    var courseIdAndName: String {
        return _courseIdAndName
    }
    var instructorName: String {
        return _instructorName
    }
    
    init(data: [String : String]) {
        if let courseUID = data["courseUID"] {
            self._courseUID = courseUID
        }
        if let departmentCodeUID = data["departmentCodeUID"] {
            self._departmentCodeUID = departmentCodeUID
        }
        var courseIdAndName = String()
        if let id = data["courseID"] {
            courseIdAndName = id
        }
        if let courseName = data["courseName"] {
            if (courseName.characters.count >= 1) {
                if (courseIdAndName.characters.count >= 1) {
                    courseIdAndName += " - " + courseName
                } else {
                    courseIdAndName = courseName
                }
            }
        }
        if (courseIdAndName.characters.count >= 1) {
            self._courseIdAndName = courseIdAndName
        }
        if let instructorName = data["instructorName"] {
            self._instructorName = instructorName
        }
        
    }
}
