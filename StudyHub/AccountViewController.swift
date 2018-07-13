//
//  AccountViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/11/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SCLAlertView
import DZNEmptyDataSet

class AccountViewController: UIViewController {
    
//    , UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    
    // MARK: Variables
    var schoolUID = String()
    var studentClassObjectIds = [String]()
    var studentClassNames = String()
    var classmateObjectIds = [String]()
    var cardSets : [FIRDataSnapshot]?
    var classes : [FIRDataSnapshot]?
    var classmates : [FIRDataSnapshot]?
    var classmatePhotos = [String : UIImage]()
    var cardSetClassNames = [String:AnyObject]()
    var loadingStudentData = Bool()
    var loadingCardSetData = Bool()
    var loadingClassData = Bool()
    var loadingClassmateData = Bool()
    var noStudentResults = Bool()
    var noCardSetResults = Bool()
    var noClassResults = Bool()
    var noClassmateResults = Bool()
    var getStudentDataSuccessful = Bool()
    var getCardSetDataSuccessful = Bool()
    var getClassDataSuccessful = Bool()
    var getClassmateDataSuccessful = Bool()
    var schoolObjectId = String()
    var selectedCardSetObjectId = String()
    var selectedClassObjectId = String()
    var selectedClassmateObjectId = String()
    var facebookLinkURL = String()
    var twitterLinkURL = String()
    var instagramLinkURL = String()
    var vscoLinkURL = String()
    var noNetworkConnection = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var logOutBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageViewBorderView: UIView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolButton: UIButton!
    @IBOutlet weak var addSchoolButton: UIButton!
    @IBOutlet weak var socialAccountsTitleLabel: UILabel!
    @IBOutlet weak var addSocialAccountButton: UIButton!
    @IBOutlet weak var facebookLinkButton: UIButton!
    @IBOutlet weak var twitterLinkButton: UIButton!
    @IBOutlet weak var instagramLinkButton: UIButton!
    @IBOutlet weak var vscoLinkButton: UIButton!
    
    // MARK: Actions
    
    

    @IBAction func settingsBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    
    @IBAction func logoutBarButtonItemPressed(_ sender: Any) {
        if (networkReachable == false) {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else {
            do {
                databaseReference.removeAllObservers()
                try FIRAuth.auth()?.signOut()
                self.performSegue(withIdentifier: "logoutFromAccountSegue", sender: self)
            } catch let error as NSError {
                self.displayError(title: "Logout Failed", message: "\(error.code): \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
//        if (networkReachable == false) {
//            self.displayNoNetworkConnection()
//            self.noNetworkConnection = true
//        } else {
//            let alertController = YBAlertController()
//            alertController.title = "Edit User Info"
//            alertController.addButton(UIImage(named: "Username"), title: "Edit Profile", action: {
//                self.performSegue(withIdentifier: "editProfileFromMyAccountSegue", sender: self)
//            })
//            alertController.addButton(UIImage(named: "Share Button"), title: "Edit Social Accounts", action: {
//                alertController.dismiss()
//                self.performSegue(withIdentifier: "editSocialAccountsFromMyAccountSegue", sender: self)
//            })
//            alertController.addButton(UIImage(named: "Classes Image"), title: "Edit Classes", action: {
//                alertController.dismiss()
//                self.performSegue(withIdentifier: "editClassesFromMyAccountSegue", sender: self)
//                
//            })
//            alertController.addButton(UIImage(named: "School"), title: "Change School", action: {
//                alertController.dismiss()
//                self.performSegue(withIdentifier: "changeSchoolFromMyAccountSegue", sender: self)
//            })
//            alertController.addButton(UIImage(named: "Check Mark Unchecked"), title: "Cancel", action: {
//                alertController.dismiss()
//            })
//            alertController.show()
//        }
    }
    
    @IBAction func addSchoolButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "changeSchoolFromMyAccountSegue", sender: self)
    }
    
    @IBAction func schoolNameButtonPresed(_ sender: Any) {
        if (networkReachable == false) {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else if self.schoolObjectId != "" {
            //            Answers.logCustomEventWithName("Account VC", customAttributes: ["School Name Button Pressed" : ""])
            self.performSegue(withIdentifier: "schoolButtonFromAccountVCSegue", sender: self)
        } else {
            self.displayError(title: "Your School Was Not Found", message: "Please try again")
        }
    }
    
    @IBAction func addSocialAccountButtonPressed(_ sender: Any) {
        if (networkReachable == false) {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else {
            self.performSegue(withIdentifier: "editSocialAccountsFromMyAccountSegue", sender: self)
        }
    }
    
    @IBAction func facebookLinkButtonPressed(_ sender: Any) {
        self.socialNetworkLinkButtonPressed(linkName: "Facebook", link: self.facebookLinkURL)
    }
    
    @IBAction func twitterLinkButtonPressed(_ sender: Any) {
        self.socialNetworkLinkButtonPressed(linkName: "Instagram", link: self.instagramLinkURL)
    }

    @IBAction func instagramLinkButtonPressed(_ sender: Any) {
        self.socialNetworkLinkButtonPressed(linkName: "Twitter", link: self.twitterLinkURL)
    }
    
    @IBAction func vscoLinkButtonPressed(_ sender: Any) {
        self.socialNetworkLinkButtonPressed(linkName: "VSCO", link: self.vscoLinkURL)
    }
    
//    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
//        if segmentedControl.selectedSegmentIndex == 0 {
//            if self.getCardSetDataSuccessful == true {
//                self.tableView.reloadData()
//            } else if reachabilityStatus == kNOTREACHABLE {
//                self.displayNoNetworkConnection()
//                self.noNetworkConnection = true
//            } else {
//                // Get data
//            }
//        } else if segmentedControl.selectedSegmentIndex == 1 {
//            if self.getClassDataSuccessful == true {
//                self.tableView.reloadData()
//            } else if reachabilityStatus == kNOTREACHABLE {
//                self.displayNoNetworkConnection()
//                self.noNetworkConnection = true
//            } else {
//                // Get data
//            }
//        } else if segmentedControl.selectedSegmentIndex == 2 {
//            if self.getClassDataSuccessful == true {
//                self.tableView.reloadData()
//            } else if reachabilityStatus == kNOTREACHABLE {
//                self.displayNoNetworkConnection()
//                self.noNetworkConnection = true
//            } else {
//                // Get data
//            }
//        }
//    }

    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.tableFooterView = UIView()
        self.setobjectLayers()
        self.setHiddenViews()
        self.setNavBar()
//        self.checkUserDetails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setobjectLayers() {
        self.headerImageView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = profileImageViewBorderView.frame.size.width / 2
        self.profileImageViewBorderView.layer.borderColor = UIColor.white.cgColor
        self.profileImageViewBorderView.layer.borderWidth = 3
        self.profileImageViewBorderView.clipsToBounds = true
        self.editProfileButton.layer.cornerRadius = 5
        self.editProfileButton.layer.borderColor = UIColor.gray.cgColor
        self.editProfileButton.layer.borderWidth = 0.5
    }
    
    func setHiddenViews() {
        self.nameLabel.isHidden = true
        self.schoolButton.isHidden = true
        self.addSchoolButton.isHidden = true
        self.addSocialAccountButton.isHidden = true
        self.facebookLinkButton.isHidden = true
        self.twitterLinkButton.isHidden = true
        self.instagramLinkButton.isHidden = true
        self.vscoLinkButton.isHidden = true
        
    }
    
    func setNavBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.init(name: "HelveticaNeue-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
    }
    
    func getUserDetails(snapshot: FIRDataSnapshot) {
        if let fullName = snapshot.value(forKey: "Name") as? String {
            self.nameLabel.text = fullName
            self.nameLabel.isHidden = false
        } else {
            self.nameLabel.text = ""
            self.nameLabel.isHidden = true
        }
        
        if let username = snapshot.value(forKey: "username") as? String {
            self.navigationItem.title = username
        } else {
            self.navigationItem.title = "My Account"
        }
        
        if let schoolName = snapshot.value(forKey:"schoolName") as? String {
            self.schoolButton.setTitle(schoolName, for: .normal)
            self.schoolButton.isHidden = false
            
            if let schoolUID = snapshot.value(forKey: "schoolUID") as? String {
                self.schoolUID = schoolUID
            }
        } else {
            self.schoolButton.setTitle("", for: .normal)
            self.schoolButton.isHidden = true
        }
        
        self.getSocialNetworkLinks(snapshot: snapshot, value: "facebookLink", buttonName: self.facebookLinkButton)
        self.getSocialNetworkLinks(snapshot: snapshot, value: "twitterLink", buttonName: self.twitterLinkButton)
        self.getSocialNetworkLinks(snapshot: snapshot, value: "instagramLink", buttonName: self.instagramLinkButton)
        self.getSocialNetworkLinks(snapshot: snapshot, value: "vscoLink", buttonName: self.vscoLinkButton)
        
        if self.facebookLinkButton.isHidden == true && self.twitterLinkButton.isHidden == true && self.instagramLinkButton.isHidden == true && self.vscoLinkButton.isHidden == true {
            self.addSocialAccountButton.layer.cornerRadius = 5
            self.addSocialAccountButton.isHidden = false
        } else {
            self.addSocialAccountButton.isHidden = true
        }
        
        if let headerImageURLString = snapshot.value(forKey: "headerPictureURL") as? String {
            let headerImageURL = URL(string: headerImageURLString)
            do {
                let headerImageData = try?  Data(contentsOf: headerImageURL!)
                let headerImage = UIImage(data: headerImageData!)
                self.headerImageView.image = headerImage
            }
        }
        
        if let profileImageURLString = snapshot.value(forKey: "profilePictureURL") as? String {
            let profileImageURL = URL(string: profileImageURLString)
            do {
                let profileImageData = try Data(contentsOf: profileImageURL!)
                let profileImage = UIImage(data: profileImageData)
                self.profileImageView.image = profileImage
            } catch {
                // Do nothing
            }
        }
    }
    
    func getSocialNetworkLinks(snapshot: FIRDataSnapshot, value: String, buttonName: UIButton) {
        if let username = snapshot.value(forKey: value) as? String {
            buttonName.isHidden = false
            if value == "facebookLink" {
                self.facebookLinkURL = "https://www.facebook.com/\(username)"
            } else if value == "twitterLink" {
                self.twitterLinkURL = "https://www.twitter.com/\(username)"
            } else if value == "instagramLink" {
                self.instagramLinkURL = "https://www.instagram.com/\(username)"
            } else {
                self.vscoLinkURL = "https://vsco.co/\(username)/images/1"
            }
        } else {
            buttonName.isHidden = true
        }
    }
    
    func socialNetworkLinkButtonPressed(linkName: String, link: String) {
        if (networkReachable == false) {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else if link != "" {
            UIApplication.shared.open(URL(string: link)!, options: [:], completionHandler: nil);
        } else {
            self.displayError(title: "No Link", message: "\(linkName) link not found. Add it again using the edit profile button.")
            
        }
    }
}
