//
//  EditProfileVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/17/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import TextFieldEffects

class EditProfileVC: UIViewController {
    
    // MARK: Variables
    var progressHUD = MBProgressHUD()
    
    // MARK: Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageBGView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: HoshiTextField!
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTextView(textView: self.bioTextView)
        self.setUpObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpObjects() {
        self.profileImageBGView.layer.cornerRadius = self.profileImageBGView.frame.size.height / 2
        self.profileImageBGView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
    }

}
