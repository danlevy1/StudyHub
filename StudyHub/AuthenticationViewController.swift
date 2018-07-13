//
//  AuthenticationViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/13/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import Fabric
import TwitterKit
import TextFieldEffects
import MBProgressHUD
import SCLAlertView
import ReachabilitySwift

class AuthenticationViewController: UIViewController {
    
    // MARK: Variables
    var authVC = String()
    var progressHUD = MBProgressHUD()
    var userData = [String: String]()
    var profileImage = UIImage()
    var authTypeAndService = String()
    var isUploading = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var authenticateWithFacebookImageView: UIImageView!
    @IBOutlet weak var authenticateWithTwitterImageView: UIImageView!
    @IBOutlet weak var changeAuthTypeButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termsOfServiceButton: UIButton!
    @IBOutlet weak var authenticateWithEmailBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func authenticateWithEmailBarButtonItemPressed(_ sender: Any) { // Authenticates user with email and password
        self.authenticateWithEmail()
    }
    
    @IBAction func changeAuthTypeButtonPressed(_ sender: Any) { // Changes between sign in and sign up
        if (self.authVC == "signIn") {
            let newAuthVC = self.storyboard?.instantiateViewController(withIdentifier: "authenticationVC") as! AuthenticationViewController
            newAuthVC.authVC = "signUp"
            self.present(newAuthVC, animated: true, completion: nil)
        } else {
            let newAuthVC = self.storyboard?.instantiateViewController(withIdentifier: "authenticationVC") as! AuthenticationViewController
            newAuthVC.authVC = "signIn"
            self.present(newAuthVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) { // Takes user to forgot password vc
        self.performSegue(withIdentifier: "forgotPasswordSegue", sender: self)
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) { // Takes user to privacy policy page
        // TODO: Set up privacy policy VC or link
    }
    
    @IBAction func termsOfServiceButtonPressed(_ sender: Any) { // Takes user to terms of service page
        // TODO: Set up terms of service VC or link
    }
    
    func signInWithFacebook(img: AnyObject) { // Logs user in with Facebook
        self.signInWithFacebook()
    }
    
    func signInWithTwitter(img: AnyObject) { // Logs user in with Twitter
        self.signInWithTwitter()
    }
    
    func signUpWithFacebook(img: AnyObject) { // Signs user up with Facebook
        self.signUpWithFacebook()
    }
    
    func signUpWithTwitter(img: AnyObject) { // Signs user up with Twitter
        self.signUpWithTwitter()
    }
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpVC()
        self.customizeNavBar()
        self.setUpKeyboardExtension()
        self.setUpTapRecognizer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func customizeNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpKeyboardExtension() {
        self.keyboardToolbar.removeFromSuperview()
        self.emailTextField.inputAccessoryView = self.keyboardToolbar
        self.passwordTextField.inputAccessoryView = self.keyboardToolbar
    }
    
    func setUpTapRecognizer() {
        self.authenticateWithFacebookImageView.isUserInteractionEnabled = true
        self.authenticateWithTwitterImageView.isUserInteractionEnabled = true
        if (self.authVC == "signIn") {
            let logInWithFacebookTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signInWithFacebook(img:)))
            let logInWithTwitterTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signInWithTwitter(img:)))
            self.authenticateWithFacebookImageView.addGestureRecognizer(logInWithFacebookTapGestureRecognizer)
            self.authenticateWithTwitterImageView.addGestureRecognizer(logInWithTwitterTapGestureRecognizer)
        } else {
            let signUpWithFacebookTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signUpWithFacebook(img:)))
            let signUpWithTwitterTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signUpWithTwitter(img:)))
            self.authenticateWithFacebookImageView.addGestureRecognizer(signUpWithFacebookTapGestureRecognizer)
            self.authenticateWithTwitterImageView.addGestureRecognizer(signUpWithTwitterTapGestureRecognizer)
        }
    }
    
    func setUpVC() {
        if (self.authVC == "signIn") {
            self.authenticateWithFacebookImageView.image = #imageLiteral(resourceName: "Facebook Sign In")
            self.authenticateWithTwitterImageView.image = #imageLiteral(resourceName: "Twitter Sign In")
            self.changeAuthTypeButton.setTitle("Sign Up", for: .normal)
            self.authenticateWithEmailBarButtonItem.title = "Sign In"
        } else {
            self.authenticateWithFacebookImageView.image = #imageLiteral(resourceName: "Facebook Sign Up")
            self.authenticateWithTwitterImageView.image = #imageLiteral(resourceName: "Twitter Sign Up")
            self.forgotPasswordButton.isHidden = true
            self.changeAuthTypeButton.setTitle("Sign In", for: .normal)
            self.authenticateWithEmailBarButtonItem.title = "Sign Up"
        }
    }
    
    // MARK: Email
    
    func authenticateWithEmail() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else {
            if (self.authVC == "signIn") {
                self.signInWithEmail(email: self.emailTextField.text!, password: self.passwordTextField.text!)
            } else {
                self.signUpWithEmail(email: self.emailTextField.text!, password: self.passwordTextField.text!)
            }
        }
    }
    
    func checkEmailDetails() -> Bool {
        self.view.endEditing(true)
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        if (email!.characters.count < 1) { // Checks if email was entered correctly
            self.displayError(title: "Error", message: "Please enter an email in the email field")
            return false
        } else if (password!.characters.count < 8) { // Checks if password was entered correctly
            self.displayError(title: "Error", message: "Your password must contain at least eight (8) characters")
            return false
        } else {
            return true
        }
    }
    
    func signInWithEmail(email: String, password: String) { // Logs user in with email and password
        self.view.endEditing(true)
        self.isUploading = true
        self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progressHUD.label.text = "Loading"
        self.progressHUD.customView = self.customProgressHUDView()
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error { // Checks if Firebase error occured
                self.isUploading = false
                self.progressHUD.hide(animated: true)
                self.displayError(title: "Error", message: error)
            } else {
                currentUser = user
                self.authTypeAndService = "Email_Sign_In"
                self.progressHUD.hide(animated: true)
                self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
            }
        })
    }
    
    func signUpWithEmail(email: String, password: String) { // Signs user up with email and password
        self.view.endEditing(true)
        self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progressHUD.label.text = "Loading"
        self.progressHUD.customView = self.customProgressHUDView()
        self.isUploading = true
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in  // Creates user with Firebase Auth
            if let error = error { // Checks if Firebase error occured
                self.isUploading = false
                self.progressHUD.hide(animated: true)
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                currentUser = user
                self.authTypeAndService = "Email_Sign_Up"
                self.userData["authenticatedWith"] = "Email"
                self.userData["email"] = email
                self.addUserToDatabase()
            }
        })
    }
    
    // MARK: Facebook
    
    func signInWithFacebook() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else {
            self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.progressHUD.label.text = "Loading"
            self.progressHUD.customView = self.customProgressHUDView()
            self.isUploading = true
            FBSDKLoginManager().logIn(withReadPermissions: nil, from: self, handler: { (user, error) in
                if let error = error {
                    self.isUploading = false
                    self.progressHUD.hide(animated: true)
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else if (!user!.isCancelled == true) {
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    self.authTypeAndService = "FB_Sign_In"
                    self.logInWithCredential(credential: credential)
                } else {
                    self.progressHUD.hide(animated: true)
                }
            })
        }
    }
    
    func signUpWithFacebook() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else {
            self.progressHUD = self.setUpProgressHUD()
            self.isUploading = true
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self) { (user, error) in // Opens up Facebook auth webpage and asks user to authenticate
                if let error = error { // Checks if Facebook error occured
                    self.isUploading = false
                    self.progressHUD.hide(animated: true)
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else if (!user!.isCancelled == true) {
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    self.authTypeAndService = "FB_Sign_Up"
                    self.addUserToAuth(credential: credential, twitterUserID: "")
                } else {
                    self.progressHUD.hide(animated: true)
                }
            }
        }
    }
    
    func facebookGraphRequest() { // Gets additional user data from Facebook
        self.userData = ["authenticatedWith": "Facebook"]
        self.isUploading = true
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name"])!.start { (connection, result, error) in // Gets Facebook user's info
            if (error != nil) { // Checks if Facebook Graph error occured
                self.addUserToDatabase()
            } else { // Checks if Facebook Graph data was downloaded
                let graphData = result as! [String : Any]
                if let email = graphData["email"] as? String {
                   self.userData["email"] = email
                }
                self.userData["fullName"]  = graphData["name"]! as? String
                let profileImageURL = "https://graph.facebook.com/\(String(describing: graphData["id"]!))/picture?type=large" // TODO: Is this always available
                self.userData["profileImageLink"] = profileImageURL
                self.addProfileImageToStorage()
            }
        }
    }
    
    func signInWithTwitter() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else {
            self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.progressHUD.label.text = "Loading"
            self.progressHUD.customView = self.customProgressHUDView()
            self.isUploading = true
            Twitter.sharedInstance().logIn(completion: { (user, error) in
                if let error = error {
                    self.isUploading = false
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.progressHUD.hide(animated: true)
                } else {
                    self.authTypeAndService = "TW_Sign_In"
                    let credential = TwitterAuthProvider.credential(withToken: user!.authToken, secret: user!.authTokenSecret)
                    self.logInWithCredential(credential: credential)
                }
            })
        }
    }
    
    func signUpWithTwitter() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else {
            self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.progressHUD.label.text = "Loading"
            self.progressHUD.customView = self.customProgressHUDView()
            self.isUploading = true
            Twitter.sharedInstance().logIn { (user, error) in
                if let error = error {
                    self.isUploading = false
                    self.progressHUD.hide(animated: true)
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else {
                    self.authTypeAndService = "TW_Sign_Up"
                    let credential = TwitterAuthProvider.credential(withToken: user!.authToken, secret: user!.authTokenSecret)
                    self.addUserToAuth(credential: credential, twitterUserID: user!.userID)
                }
            }
        }
    }
    
    func additionalTwitterDetails(twitterUserID: String) {
        self.userData = ["authenticatedWith": "Twitter"]
        TWTRAPIClient(userID: twitterUserID).loadUser(withID: twitterUserID, completion: { (user, error) in
            if (error != nil) {
                self.addUserToDatabase()
            } else {
                if let profileImageURL = user?.profileImageLargeURL {
                    self.userData["profileImageLink"] = profileImageURL
                    self.addProfileImageToStorage()
                } else {
                    self.addUserToDatabase()
                }
            }
        })
    }
    
    func logInWithCredential(credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                self.isUploading = false
                self.displayError(title: "Error", message: error.localizedDescription)
                self.progressHUD.hide(animated: true)
            } else {
                self.progressHUD.hide(animated: true)
                self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
            }
        })
    }
    
    func addUserToAuth(credential: AuthCredential, twitterUserID: String) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error = error {
                self.isUploading = false
                self.progressHUD.hide(animated: true)
                self.displayError(title: "Error", message: error.localizedDescription)
            } else if (self.authTypeAndService.contains("FB")){
                self.facebookGraphRequest()
            } else {
                self.additionalTwitterDetails(twitterUserID: twitterUserID)
            }
        })
    }
    
    func addProfileImageToStorage() {
        let profileImageURL = URL(string: self.userData["profileImageLink"]!)
        do {
            let profileImageData = try Data(contentsOf: profileImageURL!)
            self.profileImage = UIImage(data: profileImageData)!
            storageReference.child("users").child("profileImages").child("\(currentUser!.uid)profileImage").putData(profileImage.mediumQualityJPEGData, metadata: nil) { (metadata, error) in
                if (error == nil) {
                    self.userData["profileImageLink"] = metadata!.downloadURL()!.absoluteString
                }
                self.addUserToDatabase()
            }
        } catch {
            self.addUserToDatabase()
        }
    }
    
    func addUserToDatabase() {
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(userData)
        self.successfulSignUp()
    }
    
    func successfulSignUp() {
        self.isUploading = false
        self.progressHUD.hide(animated: true)
        if (self.userData["authenticatedWith"] != "Email") {
            self.performSegue(withIdentifier: "successfulSocialNetworkSignupSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "successfulEmailSignupSegue", sender: self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "successfulSocialNetworkSignupSegue") {
            let nav = segue.destination as! UINavigationController
            let destVC = nav.topViewController as! SocialNetworkAccountSetupViewController
            if (self.userData["authenticatedWith"] == "Facebook") {
                destVC.signupMethod = "Facebook"
            } else {
                destVC.signupMethod = "Twitter"
            }
            destVC.profileImage = self.profileImage
        } else if (segue.identifier == "forgotPasswordSegue") {
            let destVC = segue.destination as! ForgotPasswordViewController
            destVC.emailText = self.emailTextField.text!
        }
    }
}
