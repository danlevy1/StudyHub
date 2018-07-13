//
//  SectionDetails.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation
import UIKit

class SectionDetails {
    private var _postUID = String()
    private var _postText = String()
    private var _postImageDownloadURLs = [String]()
    
    var postUID: String {
        return _postUID
    }
    var postText: String {
        return _postText
    }
    var _postImageDownloadURLs: [UIImage] {
        return _postImageDownloadURLs
    }
    
    init(data: [String : String]) {
        if let postUID = data["postUID"] {
            self._postUID = postUID
        }
        if let postText = data["postText"] {
            self._postText = postText
        }
        if let [postImageDownloadURLs] = data["postImageDownloadURLs"] {
            for imageURL in postImageDownloadURLs {
                self._postImageDownloadURLs.append(imageURL)
            }
        }
    }
}
