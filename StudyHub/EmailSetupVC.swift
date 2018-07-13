//
//  EmailSetupVC.swift
//  StudyHub
//
//  Created by Dan Levy on 11/13/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import MBProgressHUD
import NVActivityIndicatorView
import SCLAlertView

class EmailSetupVC: UIViewController {
    
    // MARK: Variables
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var userData = [String: String]()
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: HoshiTextField!
    @IBOutlet weak var fullNameTextField: HoshiTextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func nextBarButtonItemPresses(_ sender: Any) {
        self.view.endEditing(true)
        self.checkUserData()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO: Dispose of any resources that can be recreated.
    }
    
    func checkUserData() {
        let username = self.trimString(string: "@" + self.usernameTextField.text!)
        let fullName = self.trimString(string: self.fullNameTextField.text!)
        if (username.count < 6) {
            self.displayError(title: "Error", message: "Your username must be 5 or more characters long")
        } else if (fullName.count < 1) {
            self.displayError(title: "Error", message: "Please enter your full name in the full name field")
        } else if (self.checkInfo() == true) {
            self.checkUsername(username: username, completion: { (isUnique) in
                if (isUnique == true) {
                    self.userData["username"] = username
                    self.userData["fullName"] = fullName
                    self.addUserDataToDatabase()
                }
            })
        }
    }
    
    func addUserDataToDatabase() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(self.userData)
        self.success()
    }
    
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.performSegue(withIdentifier: "emailSetupVCToProfileImagesSetupVCSegue", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
