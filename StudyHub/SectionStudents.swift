//
//  SectionStudents.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation

class SectionStudents {
    private var _studentUID = String()
    private var _studentUsername = String()
    private var _studentName = String()
    
    var studentUID: String {
        return _studentUID
    }
    var studentUsername: String {
        return _studentUsername
    }
    var studentName: String {
        return _studentName
    }
    
    init(data: [String : String]) {
        if let studentUID = data["studentUID"] {
            self._studentUID = studentUID
        }
        if let studentUsername = data["studentUsername"] {
            self._studentUsername = "@" + studentUsername
        }
        if let studentName = data["studentFullName"] {
            self._studentName = studentName
        }
    }
}
