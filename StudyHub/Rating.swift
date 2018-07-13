//
//  Rating.swift
//  StudyHub
//
//  Created by Dan Levy on 7/5/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class Rating {
    var uid = String()
    var studentUID = String()
    var rating = Int()
    var review = String()
    var chooseAgain = Bool()
    var coursesTaken = String()
    
    init(data: [String: String]) {
        if let uid = data["uid"] {
            self.uid = uid
        }
        if let studentUID = data["studentUID"] {
            self.studentUID = studentUID
        }
        if let rating = data["rating"] {
            self.rating = Int(rating)!
        }
        if let review = data["review"] {
            self.review = review
        }
        if let chooseAgain = data["chooseAgain"] {
            if (chooseAgain == "true") {
                self.chooseAgain = true
            } else {
                self.chooseAgain = false
            }
        }
        if let coursesTaken = data["coursesTaken"] {
            self.coursesTaken = coursesTaken
        }
    }
}
