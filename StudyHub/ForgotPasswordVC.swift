//
//  ForgotPasswordVC.swift
//  StudyHub
//
//  Created by Dan Levy on 12/15/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * Allows the user to reset their password
 * Password reset sent via email using Firebase Auth
 */

import UIKit
import FirebaseAuth
import TextFieldEffects
import MBProgressHUD
import NVActivityIndicatorView

class ForgotPasswordVC: UIViewController {
    
    // MARK: Variables
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    // MARK: Actions
    /*
     * Dismisses the forgot password vc
     */
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Handles the password reset
     */
    @IBAction func resetPasswordButtonPressed(_ sender: Any) {
        self.checkEmail()
    }
    
    // MARK: Basics
    /*
     * Handles the initialization of the view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Dismisses keyboard on tap outside UITextView
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func setUpObjects() {
        self.resetPasswordButton.layer.cornerRadius = 10
        self.resetPasswordButton.clipsToBounds = true
    }
    
    // MARK: Password Reset
    /*
     * Checks if there was an email entered
     */
    func checkEmail() {
        if (self.emailTextField.text!.count > 0) {
            self.sendPasswordReset()
        } else {
            self.displayError(title: "Error", message: "Please enter your email in the email field")
        }
    }
    
    /*
     * Dismisses the keyboard
     * Activates an activity view
     * Sends a password reset email through firebase auth
     */
    func sendPasswordReset() {
        if (self.checkNetwork() == true) {
            self.view.endEditing(true)
            self.activityView = self.customProgressHUDView()
            self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in // Sends email
                if let error = error {
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else {
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                    self.displayBanner(title: "Success!", subtitle: "Your password reset email has been sent", style: .success)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: { // Dismisses the vc
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            })
        }
    }
}
