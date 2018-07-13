//
//  CustomUIImageView.swift
//  StudyHub
//
//  Created by Dan Levy on 8/3/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class PostImageView: UIImageView {
    var postIndex = Int()
    var imageIndex = Int()
    
    init(data: [String: Int]) {
        if let postIndex = data["postIndex"] {
            self.postIndex = postIndex
        }
        if let imageIndex = data["imageIndex"] {
            self.imageIndex = imageIndex
        }
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
