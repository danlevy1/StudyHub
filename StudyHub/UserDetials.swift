//
//  UserDetials.swift
//  StudyHub
//
//  Created by Dan Levy on 1/8/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

public class UserDetials {
    private var _authenticatedWith = String()
    private var _email = String()
    private var _fullName = String()
    private var _fullNameLC = String()
    private var _username = String()
    private var _schoolName = String()
    private var _schoolUID = String()
    private var _facebookLink = String()
    private var _twitterLink = String()
    private var _instagramLink = String()
    private var _vscoLink = String()
    
    var authenticatedWith: String {
        return _authenticatedWith
    }
    var email: String {
        return _email
    }
    var fullName: String {
        return _fullName
    }
    var fullNameLC: String {
        return _fullNameLC
    }
    var username: String {
        return _username
    }
    var schoolName: String {
        return _schoolName
    }
    var schoolUID: String {
        return _schoolUID
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
        if let authenticatedWith = data["authenticatedWith"] {
            self._authenticatedWith = authenticatedWith
        }
        if let email = data["email"] {
            self._email = email
        }
        if let fullName = data["fullName"] {
            self._fullName = fullName
        }
        if let fullNameLC = data["fullNameLC"] {
            self._fullNameLC = fullNameLC
        }
        if let username = data["username"] {
            self._username = username
        }
        if let schoolName = data["schoolName"] {
            self._schoolName = schoolName
        }
        if let schoolUID = data["schoolUID"] {
            self._schoolUID = schoolUID
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
