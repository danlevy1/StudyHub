//
//  Instructor.swift
//  StudyHub
//
//  Created by Dan Levy on 6/22/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class Instructor {
    var uid = String()
    var name = String()
    var schoolName = String()
    var departmentName = String()
    
    init(data: [String: String]) {
        if let uid = data["uid"] {
            self.uid = uid
        }
        if let name = data["name"] {
            self.name = name
        }
        if let schoolName = data["schoolName"] {
            self.schoolName = schoolName
        }
        if let departmentName = data["departmentName"] {
            self.departmentName = departmentName
        }
    }
}
