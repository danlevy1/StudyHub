//
//  Courses.swift
//  StudyHub
//
//  Created by Dan Levy on 12/21/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class Courses {
    
    private var _uid = String()
    private var _id = String()
    private var _departmentUID = String()
    private var _sectionUID = String()
    private var _color = UIColor()
    private var _name = String()
    private var _info = NSAttributedString()
    
    var uid: String {
        return self._uid
    }
    var id: String {
        return self._id
    }
    var departmentUID: String {
        return self._departmentUID
    }
    var sectionUID: String {
        return self._sectionUID
    }
    var color: UIColor {
        return self._color
    }
    var name: String {
        return self._name
    }
    var info: NSAttributedString {
        return self._info
    }
    
    init(data: [String : String]) {
        if let uid = data["courseUID"] {
            self._uid = uid
        }
        if let id = data["courseID"] {
            self._id = id
        }
        if let departmentUID = data["departmentCodeUID"] {
            self._departmentUID = departmentUID
        }
        if let sectionUID = data["sectionUID"] {
            self._sectionUID = sectionUID
        }
        if let color = data["color"] {
            let rgbStringArray = color.split(separator: ",")
            var rgb = [CGFloat]()
            for i in 0...2 {
                rgb.append(CGFloat((rgbStringArray[i] as NSString).integerValue))
            }
            self._color = UIColor(red: rgb[0]/255, green: rgb[1]/255.0, blue: rgb[2]/255.0, alpha: 100)
        }
        let attributedText = NSMutableAttributedString()
        if let instructorName = data["instructorName"], let courseName = data["courseName"] {
            self._name = courseName
            attributedText.append(NSAttributedString(string: courseName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.white]))
            attributedText.append(NSAttributedString(string: "\n\(instructorName)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 23), NSForegroundColorAttributeName: UIColor.white]))
        } else if let courseName = data["courseName"] {
            attributedText.append(NSAttributedString(string: courseName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.white]))
        } else {
            attributedText.append(NSAttributedString(string: "Course not Found", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.white]))
        }
        self._info = attributedText
    }
}
