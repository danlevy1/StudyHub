//
//  SchoolDepartments.swift
//  StudyHub
//
//  Created by Dan Levy on 1/7/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

class SchoolDepartments {
    private var _departmentNameAndCode = String()
    private var _departmentUID = String()
    
    var departmentNameAndCode: String {
        return _departmentNameAndCode
    }
    var departmentUID: String {
        return _departmentUID
    }
    
    init(data: [String : String]) {
        var departmentNameAndCode = String()
        if let departmentName = data["departmentName"] {
            departmentNameAndCode = departmentName
        }
        if let departmentCode = data["departmentCode"] {
            if (departmentCode.characters.count >= 1) {
                if (departmentNameAndCode.characters.count >= 1) {
                    departmentNameAndCode += ": " + departmentCode
                } else {
                    departmentNameAndCode = departmentCode
                }
            }
        }
        if (departmentNameAndCode.characters.count >= 1) {
            self._departmentNameAndCode = departmentNameAndCode
        }
        if let departmentUID = data["departmentUID"] {
            self._departmentUID = departmentUID
        }
    }
}
