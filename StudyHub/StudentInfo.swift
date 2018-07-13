//
//  StudentInfo.swift
//  StudyHub
//
//  Created by Dan Levy on 1/6/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

class StudentInfo {
    private var _fullName = String()
    private var _username = String()
    private var _schoolName = String()
    private var _schoolUID = String()
    private var _profilePictureURL = String()
    private var _headerPictureURL = String()
    private var _facebookLink = String()
    private var _twitterLink = String()
    private var _instagramLink = String()
    private var _vscoLink = String()
    
    var username: String {
        return _username
    }
    var fullName: String {
        return _fullName
    }
    var schoolName: String {
        return _schoolName
    }
    var schoolUID: String {
        return _schoolUID
    }
    var profilePictureURL: String {
        return _profilePictureURL
    }
    var headerPictureURL: String {
        return _headerPictureURL
    }
    var facebookLink: String {
        return _facebookLink
    }
    var twitterLink: String {
        return _twitterLink
    }
    var instagramLink: String {
        return _instagramLink
    }
    var vscoLink: String {
        return _vscoLink
    }
    
    init(data: [String : String]) {
        if let username = data["username"] {
            self._username = "@" + username
        }
        if let fullName = data["fullName"] {
            self._fullName = fullName
        }
        if let schoolUID = data["schoolUID"] {
            self._schoolUID = schoolUID
        }
        if let schoolName = data["schoolName"] {
            self._schoolName = schoolName
        }
        if let profilePictureURL = data["profilePictureURL"] {
            self._profilePictureURL = profilePictureURL
        }
        if let headerPictureURL = data["headerPictureURL"] {
            self._headerPictureURL = headerPictureURL
        }
        if let facebookLink = data["facebookLink"] {
            self._facebookLink = facebookLink
        }
        if let twitterLink = data["twitterLink"] {
            self._twitterLink = twitterLink
        }
        if let instagramLink = data["instagramLink"] {
            self._instagramLink = instagramLink
        }
        if let vscoLink = data["vscoLink"] {
            self._vscoLink = vscoLink
        }
    }
}
