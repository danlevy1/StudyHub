//
//  Course2.swift
//  StudyHub
//
//  Created by Dan Levy on 12/25/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class Course2: Equatable {
    private var _uid: String?
    private var _id: String?
    private var _name: String?
    private var _instructor: Instructor2?
    private var _ref: DocumentReference?
    private var _department: Department2?
    
    init(uid: String?, id: String?, name: String?, instructor: Instructor2, ref: DocumentReference?, department: Department2?) {
        self._uid = uid
        self._id = id
        self._name = name
        self._instructor = instructor
        self._ref = ref
        self._department = department
    }
    
    func getUID() -> String? {
        return self._uid
    }
    func getID() -> String? {
        return self._id
    }
    func getName() -> String? {
        return self._name
    }
    func getInstructor() -> Instructor2? {
        return self._instructor
    }
    func getRef() -> DocumentReference? {
        return self._ref
    }
    func getDepartment() -> Department2? {
        return self._department
    }
    
    func setUID(uid: String) {
        self._uid = uid
    }
    func setID(id: String) {
        self._id = id
    }
    func setName(name: String) {
        self._name = name
    }
    func setInstructor(instructor: Instructor2) {
        self._instructor = instructor
    }
    func setRef(ref: DocumentReference) {
        self._ref = ref
    }
    func setDepartment(department: Department2) {
        self._department = department
    }
}

func == (lhs: Course2, rhs: Course2) -> Bool {
    return lhs.getUID() == rhs.getUID()
}



