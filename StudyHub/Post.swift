//
//  Post.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class Post: Equatable {
    var uid = String()
    var numberOfImages = Int()
    var numberOfComments = Int()
    var numberOfLikes = Int()
    var numberOfTaggedStudents = Int()
    var numberOfShares = Int()
    var text = String()
    var studentUID = String()
    var studentFullName = String()
    var studentUsername = String()
    var studentProfileImage = #imageLiteral(resourceName: "Profile Image Placeholder")
    var images = [UIImage]()
    var taggedStudents = [Student]()
    var liked = Bool()
    var courseUID = String()
    var departmentUID = String()
    var instructorUID = String()
    var schoolUID = String()
    
    func setUserProfileImage(image: UIImage) {
        self.studentProfileImage = image
    }
    
    func setImages(images: [UIImage]) {
        self.images = images
    }
    
    func setTaggedStudents(students: [Student]) {
        self.taggedStudents = students
    }
    
    func setLiked(liked: Bool) {
        self.liked = liked
    }
    
    func setUserInfo(username: String, fullName: String) {
        self.studentUsername = username
        self.studentFullName = fullName
    }
    
    func setStudentInfo(data: [String: String]) {
        if let username = data["username"] {
            self.studentUsername = username
        }
        if let fullName = data["fullName"] {
            self.studentFullName = fullName
        }
    }
    
    init(data: [String : Any]) {
        if let uid = data["uid"] as? String {
            self.uid = uid
        }
        if let numberOfImages = data["numberOfImages"] as? Int {
            self.numberOfImages = numberOfImages
        }
        if let numberOfComments = data["numberOfComments"] as? Int {
            self.numberOfLikes = numberOfComments
        }
        if let numberOfLikes = data["numberOfLikes"] as? Int {
            self.numberOfLikes = numberOfLikes
        }
        if let numberOfShares = data["numberOfShares"] as? Int {
            self.numberOfShares = numberOfShares
        }
        if let numberOfTaggedStudents = data["numberOfTaggedStudents"] as? Int {
            self.numberOfTaggedStudents = numberOfTaggedStudents
        }
        if let text = data["postText"] as? String {
            self.text = text
        }
        if let studentUID = data["studentUID"] as? String {
            self.studentUID = studentUID
        }
        if let studentFullName = data["studentFullName"] as? String {
            self.studentFullName = studentFullName
        }
        if let studentUsername = data["studentUsername"] as? String {
            self.studentUsername = studentUsername
        }
        if let courseUID = data["courseUID"] as? String {
            self.courseUID = courseUID
        }
        if let departmentUID = data["departmentUID"] as? String {
            self.departmentUID = departmentUID
        }
        if let instructorUID = data["instructorUID"] as? String {
            self.instructorUID = instructorUID
        }
        if let schoolUID = data["schoolUID"] as? String {
            self.schoolUID = schoolUID
        }
    }
}

func == (lhs: Post2, rhs: Post2) -> Bool {
    return lhs.getUID() == rhs.getUID()
}


