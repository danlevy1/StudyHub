//
//  Department.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class Department {
    private var _name = String()
    private var _uid = String()
    private var _info = NSAttributedString()
    
    var name: String {
        return _name
    }
    var uid: String {
        return _uid
    }
    var info: NSAttributedString {
        return _info
    }
    
    init(data: [String : String]) {
        let attributedString = NSMutableAttributedString()
        if let name = data["name"] {
            self._name = name
            attributedString.append(newAttributedString(string: name, color: .black, stringAlignment: .center, fontSize: 30, fontWeight: UIFont.Weight.medium, paragraphSpacing: 0))
            
        }
        if let uid = data["uid"] {
            self._uid = uid
        }
        self._info = attributedString
    }
}

