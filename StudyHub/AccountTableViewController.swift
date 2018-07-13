//
//  AccountTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 1/8/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift
import FirebaseStorageUI
import NYTPhotoViewer

class AccountTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, NYTPhotosViewControllerDelegate {
    
    // MARK: Variables
    var loadingTableViewData = Bool()
    var userPosts = [UserPosts]()
    var numberOfSocialLinks = Int()
    var socialLinks = [String: URL]()
    
    // MARK: Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageBgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usersSchoolNameButton: UIButton!
    @IBOutlet weak var addSchoolButton: UIButton!
    @IBOutlet weak var socialAccountsLabel: UILabel!
    @IBOutlet weak var facebookLinkButton: UIButton!
    @IBOutlet weak var twitterLinkButton: UIButton!
    @IBOutlet weak var instagramLinkButton: UIButton!
    @IBOutlet weak var vscoLinkButton: UIButton!
    @IBOutlet weak var addSocialAccountsButton: UIButton!
    
    // MARK: Actions
    @IBAction func signOutBarButtonItemPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.signOut()
        } catch let error as NSError {
            self.displayError(title: "Error", message: error.localizedDescription)
        }
    }
    
    func signOut() {
        let newAuthVC = self.storyboard?.instantiateViewController(withIdentifier: "authenticationVC") as! AuthenticationViewController
        newAuthVC.authVC = "signIn"
        self.present(newAuthVC, animated: true, completion: nil)
    }
    
    @IBAction func usersSchoolNameButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "getSchoolFromAccountVCSegue", sender: self)
    }
    @IBAction func addSchoolButtonPressed(_ sender: Any) {
    }
    @IBAction func facebookLinkButtonPressed(_ sender: Any) {
        self.sendUserToSocialLink(socialNetwork: "facebook")
    }
    @IBAction func twitterLinkButtonPressed(_ sender: Any) {
        self.sendUserToSocialLink(socialNetwork: "twitter")
    }
    @IBAction func instagramLinkButtonPressed(_ sender: Any) {
        self.sendUserToSocialLink(socialNetwork: "instagram")
    }
    @IBAction func vscoLinkButtonPressed(_ sender: Any) {
        self.sendUserToSocialLink(socialNetwork: "vsco")
    }
    @IBAction func addSocialAccountsButtonPressed(_ sender: Any) {
    }

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpImageView()
        self.setUpHiddenObjects()
        self.setUpGestureRecognizer()
        let _ = self.checkInfo()
        self.setUpTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.displayUserDetails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    func setUpImageView() {
        self.profileImageBgView.layer.cornerRadius = self.profileImageBgView.frame.size.width / 2
        self.profileImageBgView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        self.headerImageView.clipsToBounds = true
    }
    
    func setUpHiddenObjects() {
        self.usersSchoolNameButton.isHidden = true
        self.addSchoolButton.isHidden = true
        self.socialAccountsLabel.isHidden = true
        self.addSocialAccountsButton.isHidden = true
        self.facebookLinkButton.isHidden = true
        self.instagramLinkButton.isHidden = true
        self.twitterLinkButton.isHidden = true
        self.vscoLinkButton.isHidden = true
    }
    
    func setUpGestureRecognizer() {
        self.headerImageView.isUserInteractionEnabled = true
        self.profileImageView.isUserInteractionEnabled = true
        let headerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enlargeImage(recognizer:)))
        let profileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enlargeImage(recognizer:)))
        self.headerImageView.addGestureRecognizer(headerTapGestureRecognizer)
        self.profileImageView.addGestureRecognizer(profileTapGestureRecognizer)
    }
    
    func enlargeImage(recognizer: UITapGestureRecognizer) {
        if (recognizer.view == self.headerImageView) {
            let caption = NSAttributedString(string: "Header Picture", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.gray])
            if (self.navigationItem.title?.contains("@") == true) {
               let username = NSAttributedString(string: self.navigationItem.title!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.gray])
                let photo = CustomNYTPhoto(image: self.headerImageView.image!, imageData: nil, username: username, caption: caption)
                let vc = NYTPhotosViewController(photos: [photo])
                vc.rightBarButtonItem = nil
                self.present(vc, animated: true, completion: nil)
            } else {
                let username = NSAttributedString(string: "", attributes: nil)
                let photo = CustomNYTPhoto(image: self.headerImageView.image!, imageData: nil, username: username, caption: caption)
                let vc = NYTPhotosViewController(photos: [photo])
                vc.rightBarButtonItem = nil
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            let caption = NSAttributedString(string: "Profile Picture", attributes: [NSForegroundColorAttributeName: UIColor.gray])
            if (self.navigationItem.title?.contains("@") == true) {
                let username = NSAttributedString(string: self.navigationItem.title!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.gray])
                let photo = CustomNYTPhoto(image: self.profileImageView.image!, imageData: nil, username: username, caption: caption)
                let vc = NYTPhotosViewController(photos: [photo])
                vc.rightBarButtonItem = nil
                self.present(vc, animated: true, completion: nil)
            } else {
                let username = NSAttributedString(string: "", attributes: nil)
                let photo = CustomNYTPhoto(image: self.profileImageView.image!, imageData: nil, username: username, caption: caption)
                let vc = NYTPhotosViewController(photos: [photo])
                vc.rightBarButtonItem = nil
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func displayUserDetails() {
        self.headerImageView.image = UIImage(data: userData.headerImage)
        self.profileImageView.image = UIImage(data: userData.profileImage)
        if userData.username.characters.count > 0 {
            self.navigationItem.title = userData.username
        } else {
            self.navigationItem.title = "Account."
        }
        if userData.fullName.characters.count > 0 {
            self.usersNameLabel.text = userData.fullName
        }
        if userData.schoolName.characters.count > 0 {
            self.usersSchoolNameButton.setTitle(userData.schoolName, for: .normal)
            self.usersSchoolNameButton.isHidden = false
        }
        if userData.facebookLink.characters.count > 0 {
            self.checkSocialLink(socialNetwork: "facebook", link: userData.facebookLink, button: self.facebookLinkButton)
        }
        if userData.twitterLink.characters.count > 0 {
            self.checkSocialLink(socialNetwork: "twitter", link: userData.twitterLink, button: self.twitterLinkButton)
        }
        if userData.instagramLink.characters.count > 0 {
            self.checkSocialLink(socialNetwork: "instagram", link: userData.instagramLink, button: self.instagramLinkButton)
        }
        if userData.vscoLink.characters.count > 0 {
            self.checkSocialLink(socialNetwork: "vsco", link: userData.vscoLink, button: self.vscoLinkButton)
        }
        if (self.numberOfSocialLinks == 0) {
            self.addSocialAccountsButton.isHidden = false
        }
    }
    
    func checkSocialLink(socialNetwork: String, link: String, button: UIButton) {
        if (link.characters.count > 0) {
            button.isHidden = false
            self.numberOfSocialLinks += 1
            self.socialLinks[socialNetwork] = URL(string: link)
        }
    }
    
    func setUpTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 103
        self.tableView.rowHeight = UITableViewAutomaticDimension
//        self.getUserPosts()
    }
    
    func sendUserToSocialLink(socialNetwork: String) {
        if (UIApplication.shared.canOpenURL(socialLinks[socialNetwork]!) == true) {
            UIApplication.shared.open(socialLinks[socialNetwork]!, options: [:], completionHandler: nil)
        } else {
            self.displayError(title: "Error", message: "We can't open this link")
        }
    }
    
//    func getUserPosts() {
//        self.loadingTableViewData = true
//        self.tableView.reloadData()
//        databaseReference.child("users").child(currentUser!.uid).child("posts").observeSingleEvent(of: .value, with: { (snap) in
//            if (snap.childrenCount >= 1) {
//                let children = snap.children.allObjects as! [DataSnapshot]
//                for child in children {
//                    var postData = [String: String]()
//                    postData["uid"] = child.key
//                    let post = UserPosts(data: postData)
//                    self.userPosts.append(post)
//                }
//            }
//            self.reloadData()
//        }) { (error) in
//            self.displayError(title: "Error", message: error.localizedDescription)
//            self.reloadData()
//        }
//    }
//    
//    func reloadData() {
//        self.loadingTableViewData = false
//        self.tableView.reloadData()
//    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (self.loadingTableViewData == true) {
//            return 1
//        } else {
//            return self.userPosts.count
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "loadingAccountCell", for: indexPath) as! LoadingAccountTableViewCell
//        cell.activityIndicator.startAnimating()
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // TODO: Set this up
//    }
}
