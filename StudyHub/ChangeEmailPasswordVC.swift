//
//  ChangeEmailPasswordVC.swift
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

class ChangeEmailPasswordVC: UIViewController {
    
    // MARK: Variables
    var progressHUD = MBProgressHUD()
    var change = String()
    
    // MARK: Outlets
    @IBOutlet weak var signInEmailTextField: HoshiTextField!
    @IBOutlet weak var signInPasswordTextField: HoshiTextField!
    @IBOutlet weak var newEmailPasswordTextField: HoshiTextField!
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        self.checkUserCredentials()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpObjects() {
        if (self.change == "Email") {
            self.newEmailPasswordTextField.placeholder = "New Email"
        } else {
            self.newEmailPasswordTextField.placeholder = "New Password"
        }
    }
    
    func checkUserCredentials() {
        if (self.signInEmailTextField.text!.count < 1) {
            self.displayError(title: "Error", message: "Please enter the email that you use to sign in")
        } else if (self.signInPasswordTextField.text!.count < 1) {
            self.displayError(title: "Error", message: "Please enter the password that you use to sign in")
        } else {
            self.reauthenticateUser()
        }
    }
    
    func reauthenticateUser() {
        let credential = EmailAuthProvider.credential(withEmail: self.signInEmailTextField.text!, password: self.signInPasswordTextField.text!)
        currentUser?.reauthenticate(with: credential, completion: { (error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                self.checkNew()
            }
        })
    }
    
    func checkNew() {
        if (self.newEmailPasswordTextField.text!.count > 0) {
            if (self.change == "Email") {
                self.changeEmail()
            } else {
                self.changePassword()
            }
        } else {
            if (self.change == "Email") {
                self.displayError(title: "Error", message: "Please enter an email in the email field")
            } else {
                self.displayError(title: "Error", message: "Please enter a password in the password field")
            }
        }
    }
    
    func changeEmail() {
        currentUser?.updateEmail(to: self.newEmailPasswordTextField.text!, completion: { (error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
            }
        })
    }
    
    func changePassword() {
        currentUser?.updatePassword(to: self.newEmailPasswordTextField.text!, completion: { (error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                self.success()
            }
        })
    }
    
    func success() {
        self.progressHUD.hide(animated: true)
        self.displayBanner(title: "Success!", subtitle: "Your profile has been updated", style: .success)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
