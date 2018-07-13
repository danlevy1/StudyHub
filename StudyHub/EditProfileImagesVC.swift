//
//  EditProfileImagesVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/17/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import ImagePicker

class EditProfileImagesVC: UIViewController, ImagePickerDelegate {
    
    // MARK: Variables
    let imagePicker = ImagePickerController()
    var imagesAdded = [UIImageView]()
    var imageData = [String: String]()
    var imageViewSelected = UIImageView()
    var progressHUD = MBProgressHUD()
    
    // MARK: Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageBGView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpObjects()
        self.imagePicker.delegate = self
        self.imagePicker.imageLimit = 1
        self.setUpGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func addHeaderImage(img: AnyObject) {
        self.imageViewSelected = self.headerImageView
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc func addProfileImage(img: AnyObject) {
        self.imageViewSelected = self.profileImageView
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func setUpGestureRecognizer() {
        self.headerImageView.isUserInteractionEnabled = true
        self.profileImageView.isUserInteractionEnabled = true
        let headerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addHeaderImage(img:)))
        let profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addProfileImage(img:)))
        self.headerImageView.addGestureRecognizer(headerTapGestureRecognizer)
        self.profileImageView.addGestureRecognizer(profileTapGestureRecognizer)
    }
    
    func setUpObjects() {
        self.headerImageView.layer.borderColor = studyHubBlue.cgColor
        self.headerImageView.clipsToBounds = true
        self.profileImageView.layer.borderColor = studyHubBlue.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageBGView.layer.cornerRadius = self.profileImageBGView.frame.size.width / 2
        self.profileImageBGView.layer.borderColor = studyHubBlue.cgColor
        self.profileImageBGView.clipsToBounds = true
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: {
            self.imageViewSelected.image = images[0]
            self.imagesAdded.append(self.imageViewSelected)
        })
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    }
    
    func uploadImage(image: UIImage, imageType: String, numberOfImages: Int) {
        let imageUploadData = image.mediumQualityJPEGData
        let imageRef = storageReference.child("users").child("\(imageType)s").child("\(currentUser!.uid)\(imageType)")
        imageRef.putData(imageUploadData, metadata: nil) { (metadata, error) in
            if (error == nil) {
                imageRef.downloadURL(completion: { (url, error) in
                    if (error == nil) {
                        self.imageData["headerImageLink"] = url!.absoluteString
                    }
                })
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
                self.progressHUD.hide(animated: true)
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
