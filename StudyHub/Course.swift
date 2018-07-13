//
//  Course.swift
//  StudyHub
//
//  Created by Dan Levy on 12/21/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class Course: Equatable {
    
    var uid = String()
    var id = String()
    var departmentUID = String()
    var color = UIColor()
    var name = String()
    var instructorName = String()
    var instructorUID = String()
    
    init(data: [String : String]) {
        if let uid = data["uid"] {
            self.uid = uid
        }
        if let id = data["id"] {
            self.id = id
        }
        if let departmentUID = data["departmentUID"] {
            self.departmentUID = departmentUID
        }
        if let color = data["color"] {
            if (color.count > 4) {
                let rgbStringArray = color.split(separator: ",")
                var rgb = [CGFloat]()
                for i in 0...2 {
                    rgb.append(CGFloat((rgbStringArray[i] as NSString).integerValue))
                }
                self.color = UIColor(red: rgb[0]/255, green: rgb[1]/255.0, blue: rgb[2]/255.0, alpha: 100)
            } else {
                self.color = studyHubBlue
            }
            
        }
        if let instructorUID = data["instructorUID"] {
            self.instructorUID = instructorUID
        }
        if let name = data["name"] {
            self.name = name
        }
        if let instructorName = data["instructorName"] {
            self.instructorName = instructorName
        }
    }
}

func == (lhs: Course, rhs: Course) -> Bool {
    return lhs.uid == rhs.uid
}
