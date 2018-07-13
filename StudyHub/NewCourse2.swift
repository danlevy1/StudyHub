//
//  NewCourse2.swift
//  StudyHub
//
//  Created by Dan Levy on 6/22/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class NewCourse2 {
    private var _department: Department2?
    private var _instructor: Instructor2?
    private var _name = String()
    private var _uid = String()
    private var _id = String()
    private var _ref: DocumentReference?
    
    init() {
        self._department = nil
        self._instructor = nil
        self._ref = nil
    }
    
    func setDepartment(department: Department2) {
        self._department = department
    }
    func setInstructor(instructor: Instructor2) {
        self._instructor = instructor
    }
    func setName(name: String) {
        self._name = name
    }
    func setUID(uid: String) {
        self._uid = uid
    }
    func setID(id: String) {
        self._id = id
    }
    func setRef(ref: DocumentReference) {
        self._ref = ref
    }
    
    func getDepartment() -> Department2? {
        return self._department
    }
    func getInstructor() -> Instructor2? {
        return self._instructor
    }
    func getName() -> String {
        return self._name
    }
    func getUID() -> String {
        return self._uid
    }
    func getID() -> String {
        return self._id
    }
    func getRef() -> DocumentReference? {
        return self._ref
    }
}


