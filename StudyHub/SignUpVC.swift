//
//  SignUpVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/20/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Allows the user to sign up using an email and password or Facebook
 * Handles authentication through Firebase auth
 * Adds user data to Firebase Firestore
 */

import UIKit
import Firebase
import FBSDKLoginKit
import Fabric
import TwitterKit
import TextFieldEffects
import MBProgressHUD
import NVActivityIndicatorView
import SCLAlertView

class SignUpVC: UIViewController {
    
    // MARK: Variables
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var userData = [String: Any]()
    var userProfileImage = UIImage()
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var facebookSignUpView: UIView!
    @IBOutlet weak var facebookSignUpImageView: UIImageView!
    @IBOutlet weak var facebookSignupButton: UIButton!
    @IBOutlet weak var signInBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var privacyPolicyBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var termsOfServiceBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var emailSignUpButton: UIButton!
    
    // MARK: Actions
    /*
     * Checks if there is an active network connection
     * Handles the user signing up with an email and password
     */
    @IBAction func emailSignUpButtonPressed(_ sender: Any) {
        if (self.checkNetwork() == true) {
            self.checkEmailDetails()
        }
    }
    
    /*
     * Checks if there is an active network connection
     * Handles the user signing up with Facebook
     */
    @IBAction func facebookSignUpButtonPressed(_ sender: Any) {
        if (self.checkNetwork() == true) {
            self.facebookSignUp()
        }
    }
    
    /*
     * Takes the user to the sign in vc
     */
    @IBAction func signInBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signUpVCToSignInVCSegue", sender: self)
    }
    
    @IBAction func privacyPolicyBarButtonItemPressed(_ sender: Any) {
    }
    
    @IBAction func termsOfServiceBarButtonItemPressed(_ sender: Any) {
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
     * Rounds the corners on the sign up and email sign up buttons
     */
    func setUpObjects() {
        self.emailSignUpButton.layer.cornerRadius = 10
        self.emailSignUpButton.clipsToBounds = true
        self.facebookSignUpView.layer.cornerRadius = 10
        self.facebookSignUpView.clipsToBounds = true
    }
    
    // MARK: Email Sign Up
    /*
     * Checks if there was an email entered
     * Makes sure the user's password is 8 + characters
     */
    func checkEmailDetails() {
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        if (email!.count < 1) {
            self.displayError(title: "Error", message: "Please enter an email in the email field")
        } else if (password!.count < 8) {
            self.displayError(title: "Error", message: "Your password must contain at least eight (8) characters")
        } else {
            self.emailSignUp()
        }
    }
    
    /*
     * Dismisses the keyboard
     * Displays an activity view
     * Authenticates the user with Firebase auth
     */
    func emailSignUp() {
        self.view.endEditing(true)
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        let email = self.trimString(string: self.emailTextField.text!)
        let password = self.trimString(string: self.passwordTextField.text!)
        Auth.auth().createUser(withEmail: email, password: password) { (authData, error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                currentUser = authData!.user // Updates the currentUser global variable
                self.userData["email"] = email
                self.userData["authenticatedWith"] =  "Email"
                self.addUserToDatabase()
            }
        }
    }
    
    // MARK: Facebook Sign Up
    /*
     * Dismisses the keyboard
     * Displays an activity view
     * Authenticates the user with Facebook
     */
    func facebookSignUp() {
        self.view.endEditing(true)
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        if (self.checkNetwork() == true) {
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { (user, error) in
                if let error = error {
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else if (!user!.isCancelled == true) { // Handles the user being successfully authenticated
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    self.addUserToAuth(credential: credential)
                } else {
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                }
            })
        }
    }
    
    /*
     * Authenticates the Facebook user with Firebase
     */
    func addUserToAuth(credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                self.checkUserExists(uid: user!.uid)
            }
        })
    }
    
    /*
     * Checks if the Facebook user exists in Firebase
     * Allows the user to sign in if they exist already
     * Continues sign up flow if user does not exist
     */
    func checkUserExists(uid: String) {
        self.userExists { (result) in
            if (result == -1) { // Error
                self.displayError(title: "Error", message: "We're sorry, we can't sign you up right now")
            } else if (result == 0) { // User exists
                let alertViewappearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                let alertView = SCLAlertView(appearance: alertViewappearance)
                alertView.addButton("Yes!", action: {
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                    alertView.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "signUpVCToHomeTVCSegue", sender: self)
                })
                alertView.addButton("No", action: {
                    alertView.dismiss(animated: true, completion: nil)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                })
                alertView.showInfo("User Exists", subTitle: "It looks like you already have a StudyHub account. Would you like to sign in using this existing account?")
            } else { // User does not exist
                self.facebookGraphRequest()
            }
        }
    }
    
    /*
     * Creates a new Facebook graph request
     * Requests the user's id, email, and name
     * Accesses user's profile image
     * Adds info to userData dictionary
     */
    func facebookGraphRequest() {
        self.userData = ["authenticatedWith": "Facebook"]
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name"])!.start { (connection, result, error) in // Creates new graph request
            if (error != nil) { // Skips graph request if there is an error
                self.addUserToDatabase()
            } else {
                let graphData = result as! [String : Any]
                if let email = graphData["email"] as? String {
                    self.userData["email"] = email
                }
                self.userData["fullName"]  = graphData["name"]! as? String
                let profileImageURL = "https://graph.facebook.com/\(String(describing: graphData["id"]!))/picture?type=large" // Accesses profile image
                self.userData["profileImageLink"] = profileImageURL
                self.addProfileImageToStorage()
            }
        }
    }
    
    /*
     * Moves facebook profile image to Firebase storage
     */
    func addProfileImageToStorage() {
        let profileImageURL = URL(string: self.userData["profileImageLink"]! as! String)
        do { // Tries to access url
            let profileImageData = try Data(contentsOf: profileImageURL!)
            self.userProfileImage = UIImage(data: profileImageData)!
            storageReference.child("users").child("profilePictures").child("\(currentUser!.uid)profilePicture").putData(userProfileImage.mediumQualityJPEGData) // Adds the profile image to Firebase storage
        } catch { // Ignore error accessing url
        }
        self.addUserToDatabase()
    }
    
    /*
     * Adds all user data to Firebase realtime database
     */
    func addUserToDatabase() {
        self.userData.removeValue(forKey: "profileImageLink")
//        self.userData["signUpTimestamp"] = Date()
        firestoreRef.collection("users").document(currentUser!.uid).setData(self.userData)
        self.success()
    }
    
    // MARK: Transfer to New VC
    /*
     * Removes the activity view
     * Sends the user to the social accounts vc
     */
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.performSegue(withIdentifier: "signUpVCToAccountSetupVCSegue", sender: self)
    }
    
    /*
     * Sends the user's profile image over to the account setup vc
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "signUpVCToAccountSetupVCSegue") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! AccountSetupVC
            destVC.userProfileImage = self.userProfileImage
            destVC.userData["fullName"] = self.userData["fullName"] as? String
        }
    }
}
