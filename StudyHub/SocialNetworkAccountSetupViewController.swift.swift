//
//  SocialNetworkAccountSetupViewController.swift
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
class SocialNetworkAccountSetupViewController: UIViewController {
    
    // MARK: Variables
    var progressHUD = MBProgressHUD()
    var signupMethod = String()
    var profileImage = UIImage()
    var userData = [String: String]()
    
    // MARK: Outlets
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    
    // MARK: Actions
    @IBAction func nextBarButtonItemPressed(_ sender: Any) { // Adds user's username to Firebase Auth and Firebase Database
        self.view.endEditing(true)
        self.checkSignUpMethod()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customizeVC()
        self.setUpKeyboardToolbar()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO: Dispose of any resources that can be recreated.
    }
    
    func customizeVC() {
        if (signupMethod == "Facebook") {
            self.customizeColors(color: facebookColor)
            self.instructionsLabel.text = "Enter a username below"
            self.fullNameTextField.isHidden = true
            self.emailTextField.isHidden = true
        } else {
            self.customizeColors(color: twitterColor)
            self.instructionsLabel.text = "Enter a username, your full name, and your email below"
        }
    }
    
    func customizeColors(color: UIColor) {
        self.view.backgroundColor = color
        self.keyboardToolbar.barTintColor = color
        self.navigationController?.navigationBar.barTintColor = color
    }
    
    func setUpKeyboardToolbar() {
        self.keyboardToolbar.removeFromSuperview()
        self.usernameTextField.inputAccessoryView = self.keyboardToolbar
        self.fullNameTextField.inputAccessoryView = self.keyboardToolbar
        self.emailTextField.inputAccessoryView = self.keyboardToolbar
    }
    
    func checkSignUpMethod() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else if (self.checkUser() == false) {
            print("THERE IS NO CURRENT USER")
        } else {
            if (self.signupMethod == "Facebook") {
                self.checkFacebookData()
            } else {
                self.checkTwitterData()
            }
        }
    }
    
    func checkFacebookData() {
        if (self.usernameTextField.text!.characters.count > 0) {
            let trimmedUsername = self.usernameTextField.text!.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
            self.userData["username"] = "@" + trimmedUsername
            if (trimmedUsername.characters.count < 5) {
                self.displayError(title: "Error", message: "Your username needs to be five (5) or more characters")
            } else {
                self.checkUsername()
            }
        } else {
            self.displayError(title: "Error", message: "Please enter a username")
        }
    }
    
    func checkTwitterData() {
        let trimmedUsername = self.usernameTextField.text!.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
        if (trimmedUsername.characters.count > 0) {
            self.userData["username"] = "@" + trimmedUsername
        } else {
            self.displayError(title: "Error", message: "Please enter a username")
        }
        if (self.fullNameTextField.text!.characters.count >= 1) {
            let trimmedFullName = self.fullNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            self.userData["fullName"] = trimmedFullName
        } else {
            self.displayError(title: "Error", message: "Please enter your full name")
        }
        if (self.emailTextField.text!.characters.count >= 1) {
            var trimmedEmail = self.emailTextField.text!.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
            if (trimmedEmail.characters.count >= 5) { // Checks if the user's username is long enough
                self.userData["email"] = trimmedEmail
            } else {
                self.displayError(title: "Error", message: "Your email needs to be five (5) or more characters")
            }
        }
        self.checkUsername()
    }
    
    func checkUsername() {
        self.checkUsername(username: "@" + self.usernameTextField.text!, completion: { (result) in
            if (result == 1) {
                let alert = SCLAlertView()
                alert.addButton("Continue") {
                    self.performSegue(withIdentifier: "successfulSocialNetworkAccountSetupSegue", sender: self)
                }
                alert.showError("Error", subTitle: "'\("@" + self.usernameTextField.text!)' is your current username", closeButtonTitle: "Change Username", duration: 0.0, colorStyle: 0xFF0000, colorTextButton: 0xFFFFFF, circleIconImage: nil)
            } else if (result == 2) {
                self.displayError(title: "Error", message: "The username '\(String(describing: self.usernameTextField.text!))' is already taken. Please choose a new username")
            } else {
                self.addUserDetailsToDatabase()
            }
        })
    }
    
    func addEmailToAuth() {
        self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progressHUD.label.text = "Loading"
        currentUser?.updateEmail(to: self.userData["email"]!, completion: { (_) in
            self.success()
        })
        
    }
    
    func addUserDetailsToDatabase() {
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(self.userData)
        if (signupMethod == "Twitter") {
            self.addEmailToAuth()
        } else {
            self.success()
        }
    }
    
    func success() {
        self.progressHUD.hide(animated: true)
        self.performSegue(withIdentifier: "successfulSocialNetworkAccountSetupSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "successfulSocialNetworkAccountSetupSegue") {
            let destVC = segue.destination as! AddPhotosAccountSetupViewController
            destVC.profileImage = self.profileImage
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
