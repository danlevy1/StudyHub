//
//  SectionStudentProfileImages.swift
//  StudyHub
//
//  Created by Dan Levy on 12/30/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation
import UIKit

class SectionStudentProfileImages {
    private var _studentProfileImage = UIImage()
    private var _noImage = String()
    
    var studentProfileImage: UIImage {
        return _studentProfileImage
    }
    var noImage: String {
        return _noImage
    }
    
    init(data: [String : AnyObject]) {
        if let studentProfileImage = data["studentProfileImage"] {
            self._studentProfileImage = studentProfileImage as! UIImage
        }
        if let noImage = data["noStudentProfileImage"] {
            self._noImage = noImage as! String
        }
    }
}
