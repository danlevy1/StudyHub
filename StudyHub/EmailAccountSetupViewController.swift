//
//  EmailAccountSetupViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/13/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import MBProgressHUD
import SCLAlertView
import ReachabilitySwift

class EmailAccountSetupViewController: UIViewController {
    
    // MARK: Variables
    var progressHUD = MBProgressHUD()
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: HoshiTextField!
    @IBOutlet weak var fullNameTextField: HoshiTextField!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func nextBarButtonItemPresses(_ sender: Any) { // Adds user's username and full name to Firebase Auth and Firebase Database
        self.view.endEditing(true)
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else {
           self.checkUserData()
        }
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpKeyboardExtension()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO: Dispose of any resources that can be recreated.
    }
    
    func customizeNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpKeyboardExtension() {
        self.keyboardToolbar.removeFromSuperview()
        self.usernameTextField.inputAccessoryView = self.keyboardToolbar
        self.fullNameTextField.inputAccessoryView = self.keyboardToolbar
    }
    
    func checkUserData() {
        if (self.usernameTextField.text!.characters.count < 5) {
            self.displayError(title: "Error", message: "Your username needs to be 5 or more characters")
        } else if (fullNameTextField.text!.characters.count < 1) {
            self.displayError(title: "Error", message: "Please enter your name")
        } else {
            self.checkUsername(username: "@" + self.usernameTextField.text!, completion: { (result) in
                if (result == 1) {
                    let alert = SCLAlertView()
                    alert.addButton("Continue") {
                        self.performSegue(withIdentifier: "successfulEmailAccountSetupSegue", sender: self)
                    }
                    alert.showError("Error", subTitle: "'\("@" + self.usernameTextField.text!)' is your current username", closeButtonTitle: "Change Username", duration: 0.0, colorStyle: 0xFF0000, colorTextButton: 0xFFFFFF, circleIconImage: nil)
                } else if (result == 2) {
                    self.displayError(title: "Error", message: "The username '\(String(describing: self.usernameTextField.text!))' is already taken. Please choose a new username")
                } else {
                    self.addUserDetailsToDatabase()
                }
            })
        }
    }
    
    func addUserDetailsToDatabase() { // Adds user's username and full name to Firebase Database
        var values = ["fullName": fullNameTextField.text!]
        values["username"] = "@" + self.usernameTextField.text!
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(values)
        self.success()
    }
    
    func success() {
        self.progressHUD.hide(animated: true)
        self.performSegue(withIdentifier: "successfulEmailAccountSetupSegue", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
