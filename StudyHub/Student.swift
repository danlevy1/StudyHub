//
//  Student.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class Student: Equatable {
    var uid = String()
    var fullName = String()
    var username = String()
    var schoolName = String()
    var bio = String()
    var headerImage = UIImage()
    var profileImage = #imageLiteral(resourceName: "Profile Image Placeholder")
    var facebookLink = String()
    var twitterLink = String()
    var instagramLink = String()
    var snapchatLink = String()
    var vscoLink = String()
    
    func setHeaderImage(image: UIImage) {
        self.headerImage = image
    }
    
    func setProfileImage(image: UIImage) {
        self.profileImage = image
    }
    
    init(data: [String : String]) {
        if let uid = data["uid"] {
            self.uid = uid
        }
        if let fullName = data["fullName"] {
            self.fullName = fullName
        }
        if let username = data["username"] {
            self.username = username
        }
        if let schoolName = data["schoolName"] {
            self.schoolName = schoolName
        }
        if let bio = data["bio"] {
            self.bio = bio
        }
        if let facebookLink = data["facebookLink"] {
            self.facebookLink = facebookLink
        }
        if let twitterLink = data["twitterLink"] {
            self.twitterLink = twitterLink
        }
        if let instagramLink = data["instagramLink"] {
            self.instagramLink = instagramLink
        }
        if let snapchatLink = data["snapchatLink"] {
            self.snapchatLink = snapchatLink
        }
        if let vscoLink = data["vscoLink"] {
            self.vscoLink = vscoLink
        }
    }
}

func == (lhs: Student, rhs: Student) -> Bool {
    return lhs.uid == rhs.uid
}

