//
//  NewCourse.swift
//  StudyHub
//
//  Created by Dan Levy on 6/22/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class NewCourse {
    var courseIsNew = Bool()
    var departmentIsNew = Bool()
    var departmentName = String()
    var departmentUID = String()
    var name = String()
    var uid = String()
    var id = String()
    var instructorName = String()
    var instructorUID = String()
    var color = String()
    var courseRef: DocumentReference?
    
    init() {
        courseRef = nil
    }
    
    func setCourseIsNew(courseIsNew: Bool) {
        self.courseIsNew = courseIsNew
    }
    func setDepartmentIsNew(departmentIsNew: Bool) {
        self.departmentIsNew = departmentIsNew
    }
    func setDepartmentName(departmentName: String) {
        self.departmentName = departmentName
    }
    func setDepartmentUID(uid: String) {
        self.departmentUID = uid
    }
    func setName(name: String) {
        self.name = name
    }
    func setUID(uid: String) {
        self.uid = uid
    }
    func setID(id: String) {
        self.id = id
    }
    func setInstructorName(instructorName: String) {
        self.instructorName = instructorName
    }
    func setInstructorUID(instructorUID: String) {
        self.instructorUID = instructorUID
    }
    func setColor(color: String) {
        self.color = color
    }
    func setCourseRef(courseRef: DocumentReference) {
        self.courseRef = courseRef
    }
}

