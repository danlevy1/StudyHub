//
//  Department2.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class Department2 {
    private var _uid: String?
    private var _name: String?
    private var _ref: DocumentReference?
    
    init(uid: String?, name: String?, ref: DocumentReference?) {
        self._uid = uid
        self._name = name
        self._ref = ref
    }
    
    func getUID() -> String? {
        return self._uid
    }
    func getName() -> String? {
        return self._name
    }
    func getRef() -> DocumentReference? {
        return self._ref
    }
    
    func setUID(uid: String) {
        self._uid = uid
    }
    func setName(name: String) {
        self._name = name
    }
    func setRef(ref: DocumentReference) {
        self._ref = ref
    }
}


