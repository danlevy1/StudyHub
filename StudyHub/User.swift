//
//  User.swift
//  StudyHub
//
//  Created by Dan Levy on 6/22/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class User {
    private var _uid = String()
    private var _authenticatedWith = String()
    private var _bio = String()
    private var _email = String()
    private var _facebookLink = String()
    private var _fullName = String()
    private var _headerImage = Data()
    private var _headerImageLink = String()
    private var _instagramLink = String()
    private var _profileImage = Data()
    private var _profileImageLink = String()
    private var _schoolName = String()
    private var _schoolUID = String()
    private var _twitterLink = String()
    private var _username = String()
    private var _vscoLink = String()
    
    var uid: String {
        return _uid
    }
    var authenticatedWith: String {
        return _authenticatedWith
    }
    var bio: String {
        return _bio
    }
    var email: String {
        return _email
    }
    var facebookLink: String {
        return _facebookLink
    }
    var fullName: String {
        return _fullName
    }
    var headerImage: Data {
        return _headerImage
    }
    var headerImageLink: String {
        return _headerImageLink
    }
    var instagramLink: String {
        return _instagramLink
    }
    var profileImage: Data {
        return _profileImage
    }
    var profileImageLink: String {
        return _profileImageLink
    }
    var schoolName: String {
        return _schoolName
    }
    var schoolUID: String {
        return _schoolUID
    }
    var twitterLink: String {
        return _twitterLink
    }
    var username: String {
        return _username
    }
    var vscoLink: String {
        return _vscoLink
    }
    
    func setHeaderImage(headerData: Data) {
        self._headerImage = headerData
    }
    func setProfileImage(profileData: Data) {
        self._profileImage = profileData
    }
    
    init(data: [String : String]) {
        if let uid = data["uid"] {
            self._uid = uid
        }
        if let authenticatedWith = data["authenticatedWith"] {
            self._authenticatedWith = authenticatedWith
        }
        if let bio = data["bio"] {
            self._bio = bio
        }
        if let email = data["email"] {
            self._email = email
        }
        if let facebookLink = data["facebookLink"] {
            self._facebookLink = facebookLink
        }
        if let fullName = data["fullName"] {
            self._fullName = fullName
        }
        if let headerImageLink = data["headerImageLink"] {
            self._headerImageLink = headerImageLink
        }
        if let instagramLink = data["instagramLink"] {
            self._instagramLink = instagramLink
        }
        if let profileImageLink = data["profileImageLink"] {
            self._profileImageLink = profileImageLink
        }
        if let schoolName = data["schoolName"] {
            self._schoolName = schoolName
        }
        if let schoolUID = data["schoolUID"] {
            self._schoolUID = schoolUID
        }
        if let twitterLink = data["twitterLink"] {
            self._twitterLink = twitterLink
        }
        if let username = data["username"] {
            self._username = username
        }
        if let vscoLink = data["vscoLink"] {
            self._vscoLink = vscoLink
        }
    }
}
