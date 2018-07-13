//
//  AddPhotosAccountSetupViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/13/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import ReachabilitySwift
import Fusuma

class Test: UIViewController, FusumaDelegate {
    // MARK: Variables
    let fusuma = FusumaViewController()
    var imagesAdded = [String]()
    var imageData = [String: String]()
    var imageViewSelected = String()
    var progressHUD = MBProgressHUD()
    var profileImage = UIImage()
    
    // MARK: Outlets
    @IBOutlet weak var skipBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageViewBackgroundView: UIView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func skipBarButtonItemPressed(_ sender: Any) { // Brings user to Connect to Social VC without adding account images
        self.performSegue(withIdentifier: "successfulAddPhotosSegue", sender: self)
    }
    
    func addHeaderImage(img: AnyObject) {
        self.choosePhoto()
        self.imageViewSelected = "Header"
    }
    
    func addProfileImage(img: AnyObject) {
        self.choosePhoto()
        self.imageViewSelected = "Profile"
    }
    
    @IBAction func nextBarButtonItemPressed(_ sender: Any) {
        self.checkUserImages()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpImageViews()
        self.setUpGestureRecognizer()
        self.profileImageView.image = profileImage
        self.fusuma.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubColor
    }
    
    func setUpImageViews() {
        self.headerImageView.layer.borderColor = studyHubColor.cgColor
        self.headerImageView.clipsToBounds = true
        self.profileImageView.layer.borderColor = studyHubColor.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageViewBackgroundView.layer.cornerRadius = self.profileImageViewBackgroundView.frame.size.width / 2
        self.profileImageViewBackgroundView.layer.borderColor = studyHubColor.cgColor
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
    
    func choosePhoto() {
        self.present(fusuma, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { // Controls the image picker
        if (self.imageViewSelected == "Header") {
            self.processImage(imageView: self.headerImageView, info: info, imageAdded: "Header")
        } else {
            self.processImage(imageView: self.profileImageView, info: info, imageAdded: "Profile")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func processImage(imageView: UIImageView, info: [String : Any], imageAdded: String) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.image = pickedImage
            if (!self.imagesAdded.contains(imageAdded)) {
                self.imagesAdded.append(imageAdded)
            }
        } else {
            self.displayError(title: "Error", message: "Please try selecting a picture again")
        }
    }
    
    func checkUserImages() {
        if (self.imagesAdded.count == 0) {
            self.success()
        } else {
            if (self.checkNetwork() == false) {
                self.displayNoNetworkConnection()
            } else if (self.checkUser() == false) {
                print("THERE IS NO CURRENT USER")
            } else {
                self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.progressHUD.label.text = "Loading"
                if (self.imagesAdded.contains("Header")) {
                    self.uploadImage(image: self.headerImageView.image!, imageType: "headerPicture")
                }
                if (self.imagesAdded.contains("Profile")) {
                    self.uploadImage(image: self.profileImageView.image!, imageType: "profilePicture")
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: {
                    self.addImageLinksToDatabase()
                })
            }
        }
    }
    
    func uploadImage(image: UIImage, imageType: String) {
        let imageUploadData = image.mediumQualityJPEGData
        storageReference.child("users").child("\(imageType)s").child("\(currentUser!.uid)\(imageType)").putData(imageUploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                self.progressHUD.hide(animated: true)
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                self.imageData[imageType] = metadata?.downloadURL()?.absoluteString
            }
        }
    }
    
    func addImageLinksToDatabase() {
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(self.imageData, withCompletionBlock: { (error, ref) in
            if let error = error { // Checks for an error
                self.progressHUD.hide(animated: true)
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                self.success()
            }
        })
    }
    
    func success() {
        self.imagesAdded.removeAll(keepingCapacity: false)
        self.imageData.removeAll(keepingCapacity: false)
        self.progressHUD.hide(animated: true)
        self.performSegue(withIdentifier: "successfulAddPhotosSegue", sender: self)
    }
}
