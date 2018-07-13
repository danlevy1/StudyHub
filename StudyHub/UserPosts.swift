//
//  UserPosts.swift
//  StudyHub
//
//  Created by Dan Levy on 1/8/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import Foundation

class UserPosts {
    private var _postUID = String()
    private var _postUsernameAndName = String()
    private var _postText = String()
    private var _postDate = String()
    
    var postUID: String {
        return _postUID
    }
    var postUsernameAndName: String {
        return _postUsernameAndName
    }
    var postText: String {
        return _postText
    }
    //    var _postImageDownloadURLs: [UIImage] {
    //        return _postImageDownloadURLs
    //    }
    var postDate: String {
        return _postDate
    }
    
    init(data: [String : String]) {
        if let postUID = data["postUID"] {
            self._postUID = postUID
        }
        var postUsernameAndName = String()
        if let postUserName = data["postUserName"] {
            if (postUserName.characters.count >= 1) {
                postUsernameAndName = postUserName
            }
        }
        if let postUsername = data["postUsername"] {
            if (postUsernameAndName.characters.count >= 1) {
                postUsernameAndName = postUsernameAndName + " • @" + postUsername
            } else {
                postUsernameAndName = "@" + postUsername
            }
        }
        if (postUsernameAndName.characters.count >= 1) {
            self._postUsernameAndName = postUsernameAndName
        }
        if let postText = data["postText"] {
            self._postText = postText
            
            if let postDate = data["postDate"] {
                self._postDate = postDate
            }
        }
    }
}
