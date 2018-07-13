//
//  PostViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/5/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
    
    // MARK: Variables
    var noNetworkConnection = Bool()
    var getUserDataSuccessful = Bool()
    var postNotPosted = Bool()
    var textViewHasText = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postTypeCollectionView: UICollectionView!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cameraAddBarButtonItem: UIBarButtonItem!
    
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func postBarButtonItemPressed(_ sender: Any) {
        print("Post Button Pressed")
    }
    
    @IBAction func cameraAddBarButtonItemPressed(_ sender: Any) {
        print("Camera Button Pressed")
    }
//    @IBAction func postButtonPressed(_ sender: Any) {
//        if reachabilityStatus == kNOTREACHABLE {
//            self.displayNoNetworkConnection()
//            self.noNetworkConnection = true
//        } else {
//            // Post the post
//        }
//    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keyboardToolbar.removeFromSuperview()
        self.postTextView.inputAccessoryView = self.keyboardToolbar
        
        // Nav Bar
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 15)!,  NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        // Object Layers
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height / 2
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.borderWidth = 0.5
        self.profileImage.layer.borderColor = studyHubBlue.cgColor
        self.postTextView.layer.cornerRadius = 10.0
        self.postTextView.layer.borderWidth = 1.0
        self.postTextView.layer.borderColor = UIColor.gray.cgColor
//        let keyboardExtensionViewTopBorder = CALayer()
//        self.keyboardExtensionView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: keyboardExtensionView.frame.size.width, height: keyboardExtensionView.frame.size.height + 1))
//        keyboardExtensionViewTopBorder.backgroundColor = UIColor.red.cgColor
//        keyboardExtensionViewTopBorder.borderWidth = 1.0
//        self.keyboardExtensionView.layer.addSublayer(keyboardExtensionViewTopBorder)
//        self.keyboardExtensionView.layer.masksToBounds = true
        
        // Reachability
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityStatusChanged), name: ReachabilityChangedNotification, object: reachability)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        if self.postTextView.text == "" || self.postTextView.text == "Hi." {
//            // If user tries to post "Hi.", it will not work, tell user to post something more than just "Hi."
//            self.postTextView.textColor = UIColor.lightGray
//            self.postTextView.text = "Hi."
//            // When user begins typing, auto-highlight "Hi." so that it goes away
//        } else {
//            self.postTextView.textColor = UIColor.black
//        }
//    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (self.textViewHasText == false) {
           textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "Hi." || textView.text == "") {
            textView.text = "Hi."
            textView.textColor = UIColor.lightGray
            self.textViewHasText = false
        } else {
            self.textViewHasText = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = postTypeCollectionView.dequeueReusableCell(withReuseIdentifier: "postTypeCell", for: indexPath) as! PostCollectionViewCell
    
        cell.postTypeButton.titleLabel?.text = "• General"
         cell.postTypeButton.titleLabel?.textColor = studyHubBlue
        
        return cell
    }
    
    func reachabilityStatusChanged() {
        if (networkIsReachable == true) {
            self.displayNetworkReconnection()
        } else {
            self.displayNoNetworkConnection()
        }
    }
}
