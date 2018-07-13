//
//  SocialSetupVC.swift
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

class SocialSetupVC: UIViewController {
    
    // MARK: Variables
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var signupMethod = String()
    var profileImage = UIImage()
    var userData = [String: String]()
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func nextBarButtonItemPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.checkData()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpVC()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO: Dispose of any resources that can be recreated.
    }
    
    func setUpVC() {
        if (self.signupMethod == "Facebook") {
            self.fullNameTextField.isHidden = true
            self.emailTextField.isHidden = true
        }
    }
    
    func checkData() {
        if (self.signupMethod == "Facebook") {
            let username = self.trimString(string: "@" + self.usernameTextField.text!)
            if (username.characters.count < 5) {
                self.displayError(title: "Error", message: "Your username must be 5 or more characters long")
            } else if (self.checkInfo() == true) {
                self.checkUsername(username: username, completion: { (isUnique) in
                    if (isUnique == true) {
                        self.userData["username"] = username
                        self.addUserDataToDatabase()
                    }
                })
            }
        } else {
            let username = self.trimString(string: self.usernameTextField.text!)
            let fullName = self.trimString(string: self.fullNameTextField.text!)
            let email = self.trimString(string: self.emailTextField.text!)
            if (username.characters.count < 5) {
                self.displayError(title: "Error", message: "Your username must be 5 or more characters long")
            } else if(fullName.characters.count < 1) {
                self.displayError(title: "Error", message: "Please enter your full name in the full name field")
            } else if (email.characters.count < 1) {
                self.displayError(title: "Error", message: "Please enter email name in the email field")
            } else if (self.checkInfo() == true) {
                self.checkUsername(username: username, completion: { (isUnique) in
                    if (isUnique == true) {
                        self.userData["username"] = username
                        self.userData["username"] = username
                        self.userData["username"] = username
                        self.addUserDataToDatabase()
                    }
                })
            }
        }
    }
    
    func addEmailToAuth() {
        currentUser?.updateEmail(to: self.userData["email"]!, completion: { (_) in
            self.success()
        })
        
    }
    
    func addUserDataToDatabase() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(self.userData)
        if (signupMethod == "Twitter") {
            self.addEmailToAuth()
        } else {
            self.success()
        }
    }
    
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.performSegue(withIdentifier: "socialSetupVCToProfileImagesSetupVCSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "socialSetupVCToProfileImagesSetupVCSegue") {
            let destVC = segue.destination as! ProfileImagesSetupVC
            destVC.profileImage = self.profileImage
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
