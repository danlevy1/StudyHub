//
//  CourseInfoPost3ImgCell.swift
//  StudyHub
//
//  Created by Dan Levy on 8/1/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class CourseInfoPost3ImgCell: CourseInfoPost0ImgCell {
    // MARK: Outlets
    @IBOutlet weak var imageView0: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    // MARK: Functions
    override func awakeFromNib() {
        self.imageView0.clipsToBounds = true
        self.imageView1.clipsToBounds = true
        self.imageView2.clipsToBounds = true
        self.imageView0.layer.cornerRadius = 10
        self.imageView1.layer.cornerRadius = 10
        self.imageView2.layer.cornerRadius = 10
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
