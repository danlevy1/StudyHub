//
//  SectionsTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class SectionsTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var sectionTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
