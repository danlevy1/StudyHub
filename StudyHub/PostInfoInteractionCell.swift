//
//  PostInfoInteractionCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/27/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class PostInfoInteractionCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var sharesButton: UIButton!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
