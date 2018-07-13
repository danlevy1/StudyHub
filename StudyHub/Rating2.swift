//
//  Rating2.swift
//  StudyHub
//
//  Created by Dan Levy on 7/5/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class Rating2 {
    private var _uid: String?
    private var _rating: Int?
    private var _review: String?
    private var _recommends: Bool?
    private var _coursesTaken: [DocumentReference]?
    
    init(uid: String?, rating: Int?, review: String?, recommends: Bool?) {
        self._uid = uid
        self._rating = rating
        self._review = review
        self._recommends = recommends
        self._coursesTaken = nil
    }
    
    func getUID() -> String? {
        return self._uid
    }
    func getRating() -> Int? {
        return self._rating
    }
    func getReview() -> String? {
        return self._review
    }
    func recommends() -> Bool? {
        return self._recommends
    }
    func getCoursesTaken() -> [DocumentReference]? {
        return self._coursesTaken
    }
    
    func addCourse(course: DocumentReference) {
        if (self._coursesTaken == nil) {
            self._coursesTaken = [DocumentReference]()
        }
        self._coursesTaken!.append(course)
    }
}

