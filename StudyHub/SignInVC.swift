//
//  SignInVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/19/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Allows the user to sign in using an email and password or Facebook
 * Handles authentication through Firebase auth
 */

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import TextFieldEffects
import MBProgressHUD
import NVActivityIndicatorView

class SignInVC: UIViewController {
    
    // MARK: Variables
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var emailSignInButton: UIButton!
    @IBOutlet weak var facebookSignInBGView: UIView!
    @IBOutlet weak var facebookSignInButton: UIButton!
    @IBOutlet weak var signUpBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var forgotPasswordBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    /*
     * Checks if there is an active network connection
     * Handles the user signing in with an email and password
     */
    @IBAction func emailSignInButtonPressed(_ sender: Any) {
        if (self.checkNetwork() == true) {
            self.checkEmailDetails()
        }
    }
    
    /*
     * Checks if there is an active network connection
     * Handles the user signing in with Facebook
     */
    @IBAction func facebookSignInButtonPressed(_ sender: Any) {
        if (self.checkNetwork() == true) {
            self.facebookSignIn()
        }
    }
    
    /*
     * Takes the user to the sign up vc
     */
    @IBAction func signUpBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signInVCToSignUpVCSegue", sender: self)
    }
    
    /*
     * Takes the user to the password reset vc
     */
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signInVCToForgotPasswordVCSegue", sender: self)
    }
    
    // MARK: Basics
    /*
     * Handles the initialization of the view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpObjects()
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
    
    /*
     * Rounds the corners on the sign in and email sign in buttons
     */
    func setUpObjects() {
        self.emailSignInButton.layer.cornerRadius = 10
        self.emailSignInButton.clipsToBounds = true
        self.facebookSignInBGView.layer.cornerRadius = 10
        self.facebookSignInBGView.clipsToBounds = true
    }
    
    // MARK: Email Sign In
    /*
     * Checks if there was an email entered
     * Makes sure the user's password is 8 + characters
     */
    func checkEmailDetails() {
        let email = self.trimString(string: self.emailTextField.text!)
        let password = self.trimString(string: self.passwordTextField.text!)
        if (email.count < 1) { // Checks if email was entered correctly
            self.displayError(title: "Error", message: "Please enter an email in the email field")
        } else if (password.count < 8) { // Checks if password was entered correctly
            self.displayError(title: "Error", message: "Your password must contain at least eight (8) characters")
        } else {
            self.emailSignIn(email: email, password: password)
        }
    }
    
    /*
     * Dismisses the keyboard
     * Activates an activity view
     * Authenticates the user with Firebase auth
     */
    func emailSignIn(email: String, password: String) {
        self.view.endEditing(true)
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        let email = self.trimString(string: self.emailTextField.text!)
        Auth.auth().signIn(withEmail: email, password: self.passwordTextField.text!, completion: { (authData, error) in // Firebase auth
            if let error = error {
                self.checkAuthenticationProvider(email: email, authError: error)
            } else {
                currentUser = authData!.user // Updates the currentUser global variable
                self.success()
            }
        })
    }
    
    func checkAuthenticationProvider(email: String, authError: Error) {
        firestoreRef.collection("users").whereField("email", isEqualTo: email).getDocuments { (snap, error) in
            if (error != nil) {
                self.displayError(title: "Error", message: authError.localizedDescription)
            } else if (snap?.documents.first?.data()["authenticatedWith"] as? String == "Facebook") {
                self.displayInfo(title: "Facebook User", message: "This email is associated with your Facebook account. Please sign in with Facebook.")
            } else {
                self.displayError(title: "Error", message: authError.localizedDescription)
            }
            self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        }
    }
    
    // MARK: Facebook Sign In
    /*
     * Activates an activity view
     * Authenticates the user with Facebook
     */
    func facebookSignIn() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        FBSDKLoginManager().logIn(withReadPermissions: nil, from: self, handler: { (user, error) in // Facebook authentication
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else if (!user!.isCancelled == true) { // Handles the user being successfully authenticated
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.signInWithCredential(credential: credential)
            } else {
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            }
        })
    }
    
    /*
     * Authenticates the Facebook user with Firebase
     */
    func signInWithCredential(credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in // Firebase authentication
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                currentUser = user!
                self.checkUserExists()
            }
        })
    }
    
    /*
     * Checks if the Facebook user exists
     * Continues the sign in flow if user exists
     */
    func checkUserExists() {
        self.userExists { (result) in
            if (result == -1) { // Error
                self.displayError(title: "Error", message: "We're sorry, we can't sign you up right now")
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else if (result == 0) { // User exists
                self.success()
            } else { // User does not exist
                self.displayError(title: "No User", message: "It looks like you don't have a StudyHub account. Please sign up first.")
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            }
        }
    }
    
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.performSegue(withIdentifier: "signInVCToHomeTVCSegue", sender: self) // Takes user to the home vc
    }
}
