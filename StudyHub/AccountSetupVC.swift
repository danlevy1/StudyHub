//
//  AccountSetupVC.swift
//  StudyHub
//
//  Created by Dan Levy on 11/13/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * Allows the user to add a profile image, a username and their full name
 * Adds the profile image to Firebase storage
 * Adds other data to Firebase Firestore
 */

import UIKit
import TextFieldEffects
import MBProgressHUD
import NVActivityIndicatorView
import ImagePicker

class AccountSetupVC: UIViewController, ImagePickerDelegate {
    
    // MARK: Variables
    var imagePicker = ImagePickerController()
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var userData = [String: String]()
    var userProfileImage: UIImage?
    
    // MARK: Outlets
    @IBOutlet weak var profileImageBGView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: HoshiTextField!
    @IBOutlet weak var fullNameTextField: HoshiTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Actions
    /*
     * Handles new user data
     */
    @IBAction func nextButtonPressed(_ sender: Any) {
        self.checkUsername()
    }
    
    @objc func addProfileImage(sender: AnyObject) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Basics
    /*
     * Handles the initialization of the view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpObjects()
        self.setUpGestureRecognizer()
        self.setUpUserData()
        self.imagePicker.delegate = self
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO: Dispose of any resources that can be recreated.
    }
    
    /*
     * Dismisses keyboard on tap outside UITextView
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /*
     * Makes the profile image view and its background view circular
     * Rounds the corners on the next button
     */
    func setUpObjects() {
        self.profileImageBGView.layer.cornerRadius = self.profileImageBGView.frame.height / 2
        self.profileImageBGView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.clipsToBounds = true
        self.nextButton.layer.cornerRadius = 10
        self.nextButton.clipsToBounds = true
    }
    
    /*
     * Adds a gesture recognizer to the profile image view
     * Allows the user to add or change their profile image
     */
    func setUpGestureRecognizer() {
        self.profileImageView.isUserInteractionEnabled = true
        let profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addProfileImage(sender:)))
        self.profileImageView.addGestureRecognizer(profileTapGestureRecognizer)
    }
    
    /*
     * If a profile image was pulled from Facebook, it is pre-loaded into the profile image view
     */
    func setUpUserData() {
        if (self.userProfileImage != nil) {
            self.profileImageView.image = self.userProfileImage
        }
        if let fullName = self.userData["fullName"] {
            self.fullNameTextField.text = fullName
        }
    }
    
    // MARK: Add New User Data
    /*
     * Gets rid of whitespace on username
     * Checks that the username entered is 6 + characters with @ sign
     * Checks if username is unique
     */
    func checkUsername() {
        let username = "@" + self.trimString(string: self.usernameTextField.text!)
        if (username.count < 6) {
            self.displayError(title: "Error", message: "Your username must be 5 or more characters long")
        }
        firestoreRef.collection("users").whereField("username", isEqualTo: username).getDocuments { (snap, error) in
            if (error != nil) {
                self.displayError(title: "Error", message: "There is a problem adding your username. Please try again later.") // TODO: Handle error
            } else if (snap!.count > 0) {
                self.displayError(title: "Error", message: "\(username) is already taken. Please enter a different username")
            } else {
                self.userData["username"] = username
                self.checkUserData()
            }
        }
    }
    
    /*
     * Gets rid of whitespace on full name
     * Checks that there was a full name entered
     * Checks for a user profile image
     */
    func checkUserData() {
        let fullName = self.trimString(string: self.fullNameTextField.text!)
        if (fullName.count < 1) {
            self.displayError(title: "Error", message: "Please enter your full name in the full name field")
        } else if (self.checkNetwork() == true) {
            self.userData["fullName"] = fullName
            if (self.profileImageView.image?.size != CGSize(width: 0, height: 0)) { // Adds profile image before adding other user data
                self.addUserProfileImageToStorage()
            } else {
                self.addUserDataToDatabase()
            }
        }
    }
    
    /*
     * Dismisses the keyboard
     * Displays an activity view
     * Adds the profile image to Firebase storage
     */
    func addUserProfileImageToStorage() {
        self.view.endEditing(true)
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        let imageUploadData = self.profileImageView.image!.mediumQualityJPEGData
        storageReference.child("users").child("profilePictures").child("\(currentUser!.uid)profilePicture").putData(imageUploadData, metadata: nil) { (metadata, error) in // Adds the profile image and ignores any errors
            self.addUserDataToDatabase()
        }
    }
    
    /*
     * Dismisses the keyboard and displaus an activity view if there is no profile image
     * Displays an activity view
     * Adds new user data to the Firebase realtime database
     */
    func addUserDataToDatabase() {
        if (self.profileImageView.image?.size == CGSize(width: 0, height: 0)) { // Checks if there is no profile image
            self.view.endEditing(true)
            self.activityView = self.customProgressHUDView()
            self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        }
        firestoreRef.collection("users").document(currentUser!.uid).updateData(self.userData)
        self.success()
    }
    
    // MARK: Transfer to New VC
    /*
     * Removes the activity view
     * Moves user to vc to add a profile image
     */
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.performSegue(withIdentifier: "accountSetupVCToScoailAccountsSetupVCSegue", sender: self)
    }
    
    // MARK: ImagePicker
    /*
     * Dismisses the image picker controller
     * Updates the profile image view with the new image
     */
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: {
            self.profileImageView.image = images[0]
        })
    }
    
    /*
     * Ignore this function
     */
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    }
    
    /*
     * Dismisses image picker when cancled
     */
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
