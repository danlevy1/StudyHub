//
//  ProfileImagesSetupVC.swift
//  StudyHub
//
//  Created by Dan Levy on 11/13/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import NVActivityIndicatorView
import ImagePicker

class ProfileImagesSetupVC: UIViewController, ImagePickerDelegate {
    // MARK: Variables
    let imagePicker = ImagePickerController()
    var imagesAdded = [UIImageView]()
    var imageData = [String: String]()
    var imageViewSelected = UIImageView()
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var profileImage = UIImage()
    
    // MARK: Outlets
    @IBOutlet weak var skipBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageViewBackgroundView: UIView!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func skipBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "profileImagesSetupVCToSocialAccountsSetupVC", sender: self)
    }
    
    @objc func addHeaderImage(img: AnyObject) {
        self.imageViewSelected = self.headerImageView
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc func addProfileImage(img: AnyObject) {
        self.imageViewSelected = self.profileImageView
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func nextBarButtonItemPressed(_ sender: Any) {
        self.checkUserImages()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpImageViews()
        self.setUpGestureRecognizer()
        self.profileImageView.image = profileImage
        self.imagePicker.delegate = self
        self.imagePicker.imageLimit = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpImageViews() {
        self.headerImageView.layer.borderColor = studyHubBlue.cgColor
        self.headerImageView.clipsToBounds = true
        self.profileImageView.layer.borderColor = studyHubBlue.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageViewBackgroundView.layer.cornerRadius = self.profileImageViewBackgroundView.frame.size.width / 2
        self.profileImageViewBackgroundView.layer.borderColor = studyHubBlue.cgColor
        self.profileImageViewBackgroundView.clipsToBounds = true
    }
    
    func setUpGestureRecognizer() {
        self.headerImageView.isUserInteractionEnabled = true
        self.profileImageView.isUserInteractionEnabled = true
        let headerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addHeaderImage(img:)))
        let profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addProfileImage(img:)))
        self.headerImageView.addGestureRecognizer(headerTapGestureRecognizer)
        self.profileImageView.addGestureRecognizer(profileTapGestureRecognizer)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: {
            print(images.count)
            self.imageViewSelected.image = images[0]
            self.imagesAdded.append(self.imageViewSelected)
        })
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    }
    
    func checkUserImages() {
        if (self.imagesAdded.count == 0) {
            self.performSegue(withIdentifier: "profileImagesSetupVCToSocialAccountsSetupVC", sender: self)
        } else {
            if (self.checkNetwork() == false) {
                self.displayNoNetworkConnection()
            } else if (self.checkUser() == false) {
                print("THERE IS NO CURRENT USER")
            } else {
                if (self.imagesAdded.contains(self.headerImageView) && self.imagesAdded.contains(self.profileImageView)) {
                    self.uploadImage(image: self.headerImageView.image!, imageType: "headerImage", numberOfImages: 2)
                } else if (self.imagesAdded.contains(self.headerImageView)) {
                    self.uploadImage(image: self.headerImageView.image!, imageType: "headerImage", numberOfImages: 1)
                } else if (self.imagesAdded.contains(self.profileImageView)) {
                    self.uploadImage(image: self.profileImageView.image!, imageType: "profileImage", numberOfImages: 2)
                } else {
                    self.success()
                }
            }
        }
    }
    
    func uploadImage(image: UIImage, imageType: String, numberOfImages: Int) {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        let imageUploadData = image.mediumQualityJPEGData
        storageReference.child("users").child("\(imageType)s").child("\(currentUser!.uid)\(imageType)").putData(imageUploadData, metadata: nil) { (metadata, error) in
            if (metadata != nil) {
              self.imageData["headerImageLink"] = metadata!.downloadURL()!.absoluteString
                if (numberOfImages == 2) {
                    self.uploadImage(image: self.profileImageView.image!, imageType: "profileImageLink", numberOfImages: 1)
                } else {
                    self.addImageLinksToDatabase()
                }
            }
        }
    }
    
    func uploadImage(image: UIImage, imageType: String, completion: @escaping (StorageMetadata?, Error?) -> ()) {
        let imageUploadData = image.mediumQualityJPEGData
        storageReference.child("users").child("\(imageType)s").child("\(currentUser!.uid)\(imageType)").putData(imageUploadData, metadata: nil) { (metadata, error) in
            completion(metadata, error)
        }
    }
    
    func addImageLinksToDatabase() {
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(self.imageData, withCompletionBlock: { (error, ref) in
            if let error = error { // Checks for an error
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                self.success()
            }
        })
    }
    
    func success() {
        self.imagesAdded.removeAll(keepingCapacity: false)
        self.imageData.removeAll(keepingCapacity: false)
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.performSegue(withIdentifier: "profileImagesSetupVCToSocialAccountsSetupVC", sender: self)
    }
}
