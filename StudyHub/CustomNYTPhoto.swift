//
//  CustomNYTPhoto.swift
//  StudyHub
//
//  Created by Dan Levy on 5/26/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class CustomNYTPhoto: NSObject, NYTPhoto {
    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString?
    let attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
    
    init(image: UIImage? = nil, imageData: Data? = nil, username: NSAttributedString, caption: NSAttributedString) {
        self.image = image
        self.imageData = imageData
        self.attributedCaptionTitle = username
        self.attributedCaptionSummary = caption
        super.init()
    }
    
}
