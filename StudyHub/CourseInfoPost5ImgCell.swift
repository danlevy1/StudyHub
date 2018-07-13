//
//  CourseInfoPost5ImgCell.swift
//  StudyHub
//
//  Created by Dan Levy on 8/1/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class CourseInfoPost5ImgCell: CourseInfoPost0ImgCell {
    // MARK: Outlets
    @IBOutlet weak var imageView0: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView0.clipsToBounds = true
        self.imageView1.clipsToBounds = true
        self.imageView2.clipsToBounds = true
        self.imageView3.clipsToBounds = true
        self.imageView4.clipsToBounds = true
        self.imageView0.layer.cornerRadius = 10
        self.imageView1.layer.cornerRadius = 10
        self.imageView2.layer.cornerRadius = 10
        self.imageView3.layer.cornerRadius = 10
        self.imageView4.layer.cornerRadius = 10
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
