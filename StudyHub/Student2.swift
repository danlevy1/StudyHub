//
//  Student.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class Student2: Equatable {
    private var _uid: String?
    private var _fullName: String?
    private var _username: String?
    private var _school: School?
    private var _bio: String?
    private var _profileImage: UIImage?
    private var _facebookLink: String?
    private var _twitterLink: String?
    private var _instagramLink: String?
    private var _snapchatLink: String?
    private var _ref: DocumentReference?
    
    init(uid: String?, fullName: String?, username: String?, bio: String?, facebook: String?, twitter: String?, instagram: String?, snapchat: String?, ref: DocumentReference?, school: School?) {
        self._uid = uid
        self._fullName = fullName
        self._username = username
        self._school = school
        self._bio = bio
        self._facebookLink = facebook
        self._twitterLink = twitter
        self._instagramLink = instagram
        self._snapchatLink = snapchat
        self._ref = ref
    }
    
    func getUID() -> String? {
        return self._uid
    }
    func getFullName() -> String? {
        return self._fullName
    }
    func getUsername() -> String? {
        return self._username
    }
    func getSchool() -> School? {
        return self._school
    }
    func getBio() -> String? {
        return self._bio
    }
    func getProfileImage() -> UIImage? {
        return self._profileImage
    }
    func getFacebook() -> String? {
        return self._facebookLink
    }
    func getTwitter() -> String? {
        return self._twitterLink
    }
    func getInstagram() -> String? {
        return self._instagramLink
    }
    func getSnapchat() -> String? {
        return self._snapchatLink
    }
    func getRef() -> DocumentReference? {
        return self._ref
    }
    
    func setProfileImage(image: UIImage) {
        self._profileImage = image
    }
    func setSchool(school: School) {
        self._school = school
    }
}

func == (lhs: Student2, rhs: Student2) -> Bool {
    return lhs.getUID() == rhs.getUID()
}


