//
//  AccountTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 1/8/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SCLAlertView
//import FirebaseStorageUI
import NYTPhotoViewer
import CoreData
import NotificationBannerSwift
import XLActionController

class AccountTVC: UITableViewController, NYTPhotosViewControllerDelegate {
    
    // MARK: Variables
    var loading = Bool()
    var posts = [Post]()
    var socialAccounts = [SocialAccount]()
    var segmentedControlValue = Int()
    var firstAppearance = true
    var postsAreDownloaded = Bool()
    var currentRow = Int()
    var postInteraction = String()
    
    // MARK: Actions
    @IBAction func settingsBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "accountTVCToSettingsTVCSegue", sender: self)
    }
    @IBAction func signOutBarButtonItemPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.signOut()
        } catch let error as NSError {
            self.displayError(title: "Error", message: error.localizedDescription)
        }
    }

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
//        self.getSocialLinks()
        self.setUpNavBarTitle()
        self.getPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBarTitle() {
        if let username = thisUser?.username {
            self.navigationItem.title = username
        }
    }
    
    func signOut() {
        self.performSegue(withIdentifier: "accountTVCToSignInVCSegue", sender: self)
    }
    
    func getPosts() {
        self.loading = true
        self.tableView.reloadData()
        databaseReference.child("users").child(thisUser!.uid!).child("coursePosts").observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount > 0) {
                let children = snap.children.allObjects as! [DataSnapshot]
                var data = [String: Any]()
                for child in children {
                    data = child.value as! [String: Any]
                    data["uid"] = child.key
                    let post = Post(data: data)
                    self.posts.append(post)
                    self.checkLike(post: post)
                }
            } else {
                self.reloadData()
            }
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData()
        }
    }
    
    func checkLike(post: Post) {
        databaseReference.child("users").child(thisUser!.uid!).child("postLikes").child("_").child(post.courseUID).child(post.instructorUID).child(post.uid).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount == 1) {
                post.setLiked(liked: (snap.children.allObjects.first as! DataSnapshot).value! as! Bool)
            }
            self.reloadData()
            self.enableLivePostChanges()
            if (post.numberOfImages > 0) {
                self.getPostImages(post: post)
            }
        })
    }
    
    func getPostImages(post: Post) {
        var postImages = [UIImage]()
        var downloadCount = Int()
        for i in 1 ... post.numberOfImages {
            storageReference.child("coursePostImages").child(post.schoolUID).child(post.departmentUID).child(post.courseUID).child(post.instructorUID).child(post.uid).child("image\(i)") .getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if (error == nil && data != nil) {
                    if let image = UIImage(data: data!) {
                        postImages.append(image)
                    } else {
                        postImages.append(#imageLiteral(resourceName: "Image not Available"))
                    }
                    downloadCount += 1
                    if (downloadCount == post.numberOfImages) {
                        post.setImages(images: postImages)
                        let row = self.posts.index(of: post)
                        if let row = row {
                            self.tableView.reloadRows(at: [IndexPath(row: row, section: 1)], with: .none)
                        }
                    }
                }
            }
        }
    }
    
    func enableLivePostChanges() {
        databaseReference.child("users").child(thisUser!.uid!).child("coursePosts").observe(.childChanged, with: { (snap) in
            var data: [String: Any]
            data = snap.value as! [String: Any]
            data["uid"] = snap.key
            let newPost = Post(data: data)
            let index = self.posts.index(of: newPost)
            if let row = index {
                let oldPost = self.posts[row]
                let profileImage = oldPost.studentProfileImage
                let images = oldPost.images
                newPost.studentProfileImage = profileImage
                newPost.images = images
                self.posts[row] = newPost
                newPost.liked = oldPost.liked
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 1)], with: .none)
            }
        })
    }
    
    @objc func enlargeAccountImage(recognizer: UITapGestureRecognizer) {
//        if (recognizer.view?.tag == 0) {
//            let photo = NYTPhotoImgOnly(image: UIImage(data: thisUser!.headerImage! as Data))
//            let vc = NYTPhotosViewController(photos: [photo])
//            vc.rightBarButtonItem = nil
//            self.present(vc, animated: true, completion: nil)
//        } else {
//            let photo = NYTPhotoImgOnly(image: UIImage(data: thisUser!.profileImage! as Data))
//            let vc = NYTPhotosViewController(photos: [photo])
//            vc.rightBarButtonItem = nil
//            self.present(vc, animated: true, completion: nil)
//        }
    }
    
    @objc func enlargePostImage(recognizer: UITapGestureRecognizer) {
//        let tapLocation = recognizer.location(in: self.tableView)
//        let row = self.tableView.indexPathForRow(at: tapLocation)?.row
//        let tag = recognizer.view!.tag
//        let post = self.posts[row!]
//        var photos = [NYTPhotoImgOnly]()
//        for image in post.images {
//            photos.append(NYTPhotoImgOnly(image: image))
//        }
//        let vc = NYTPhotosViewController(photos: photos)
//        vc.rightBarButtonItem = nil
//        vc.display(photos[tag], animated: true)
//        self.present(vc, animated: true, completion: nil)
    }
    
//    func getSocialLinks() {
//        var data = [String: Any]()
//        if let facebookLink = thisUser!.facebookLink {
//            data["type"] = "Facebook"
//            data["link"] = facebookLink
//            data["image"] = #imageLiteral(resourceName: "Facebook Logo")
//            data["textColor"] = UIColor.white
//            data["bgColor"] = facebookColor
//            self.socialAccounts.append(SocialAccount(data: data))
//        }
//        if let twitterLink = thisUser!.twitterLink {
//            data.removeAll(keepingCapacity: true)
//            data["type"] = "Twitter"
//            data["link"] = twitterLink
//            data["image"] = #imageLiteral(resourceName: "Twitter Logo")
//            data["textColor"] = UIColor.white
//            data["bgColor"] = twitterColor
//            self.socialAccounts.append(SocialAccount(data: data))
//        }
//        if let instagramLink = thisUser!.instagramLink {
//            data.removeAll(keepingCapacity: true)
//            data["type"] = "Instagram"
//            data["link"] = instagramLink
//            data["image"] = #imageLiteral(resourceName: "Instagram Logo")
//            data["textColor"] = UIColor.black
//            data["bgColor"] = UIColor.white
//            self.socialAccounts.append(SocialAccount(data: data))
//        }
//        if let snapchatLink = thisUser!.snapchatLink  {
//            data.removeAll(keepingCapacity: true)
//            data["type"] = "Snapchat"
//            data["link"] = snapchatLink
//            data["image"] = #imageLiteral(resourceName: "Snapchat")
//            data["textColor"] = UIColor.black
//            data["bgColor"] = snapchatColor
//            self.socialAccounts.append(SocialAccount(data: data))
//        }
//        if let vscoLink = thisUser!.vscoLink {
//            data.removeAll(keepingCapacity: true)
//            data["type"] = "VSCO"
//            data["link"] = vscoLink
//            data["image"] = #imageLiteral(resourceName: "VSCO Logo")
//            data["textColor"] = UIColor.black
//            data["bgColor"] = UIColor.white
//            self.socialAccounts.append(SocialAccount(data: data))
//        }
//        self.tableView.reloadData()
//    }
    
    func accountDetailsText() -> NSAttributedString {
        let info = NSMutableAttributedString()
        if let fullName = thisUser!.fullName {
           info.append(newAttributedString(string: fullName, color: .black, stringAlignment: .left, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
        }
        if let schoolName = thisUser!.schoolName {
          info.append(newAttributedString(string: "\n" + schoolName, color: .black, stringAlignment: .left, fontSize: 20, fontWeight: UIFont.Weight.regular, paragraphSpacing: 10))
        }
        if let bio = thisUser!.bio {
            info.append(newAttributedString(string: "\n" + bio, color: .black, stringAlignment: .left, fontSize: 20, fontWeight: UIFont.Weight.light, paragraphSpacing: 0))
        }
        return info
    }
    
    func setUpAccountGestureRecognizer(imageView: UIImageView) {
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargeAccountImage(recognizer:)))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    func setUpPostGestureRecognizer(imageView: UIImageView) {
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func getSegmentValue(sender: UISegmentedControl) {
        self.segmentedControlValue = sender.selectedSegmentIndex
        self.tableView.reloadData()
    }
    
    func sendUserToSocialLink(link: String) {
        if (self.checkNetwork() == true) {
            if (UIApplication.shared.canOpenURL(URL(string: link)!) == true) {
                UIApplication.shared.open(URL(string: link)!, options: [:], completionHandler: nil)
            } else {
                self.displayError(title: "Error", message: "There was a problem opening this link. Please try again later.")
            }
        } else {
            let banner = NotificationBanner(title: "Internet Connection", subtitle: "Please reconnect to the internet", style: .warning, colors: CustomBannerColors())
            banner.show()
        }
    }
    
    func accountEmptyDataSet(tableView: UITableView, indexPath: IndexPath, title: String, description: String, image: UIImage) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountEmptyDataSetCell", for: indexPath) as! AccountEmptyDataSetCell
        let text = NSMutableAttributedString()
        text.append(newAttributedString(string: title, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 15))
        text.append(newAttributedString(string: "\n" + description, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = text
        cell.largeImageView.image = image
        return cell
    }
    
    @objc func newComment(sender: UIButton) {
        self.currentRow = sender.tag
        self.performSegue(withIdentifier: "studentInfoTVCToPostInfoTVCSegue", sender: self)
    }
    
    @objc func likePost(sender: UIButton) {
        if (sender.currentImage == #imageLiteral(resourceName: "Like Inactive")) {
            sender.setImage(#imageLiteral(resourceName: "Like Active"), for: .normal)
            self.addLike(row: sender.tag)
        } else {
            sender.setImage(#imageLiteral(resourceName: "Like Inactive"), for: .normal)
            self.removeLike(row: sender.tag)
        }
    }
    
    @objc func viewTaggedStudents(sender: UIButton) {
        self.currentRow = sender.tag
        self.postInteraction = "taggedStudents"
        self.performSegue(withIdentifier: "accountTVCToPostInteractionTVCSegue", sender: self)
    }
    
    func addLike(row: Int) {
        var values = [String: String]()
        if let fullName = thisUser!.fullName {
            values["fullName"] = fullName
        }
        if let username = thisUser!.username {
            values["username"] = username
        }
        let post = self.posts[row]
        post.liked = true
        databaseReference.child("coursePostLikes").child(post.schoolUID).child(post.departmentUID).child(post.uid).child(post.instructorUID).child(post.uid).child(thisUser!.uid!).updateChildValues(values) { (error, _) in
            if (error == nil) {
                databaseReference.child("coursePosts").child(post.schoolUID).child(post.departmentUID).child(post.uid).child(post.instructorUID).child(post.uid).child("numberOfLikes").runTransactionBlock { (currentData) -> TransactionResult in
                    var value = currentData.value as? Int
                    if (value == nil) {
                        value = 0
                    }
                    currentData.value = value! + 1
                    return TransactionResult.success(withValue: currentData)
                }
                
                databaseReference.child("users").child(post.studentUID).child("coursePosts").child(post.uid).child("numberOfLikes").runTransactionBlock { (currentData) -> TransactionResult in
                    var value = currentData.value as? Int
                    if (value == nil) {
                        value = 0
                    }
                    currentData.value = value! + 1
                    return TransactionResult.success(withValue: currentData)
                }
                databaseReference.child("users").child(thisUser!.uid!).child("postLikes").child(post.schoolUID).child(post.uid).child(post.instructorUID).child(post.uid).updateChildValues([post.uid: true])
            }
        }
    }
    
    func removeLike(row: Int) {
        let post = self.posts[row]
        post.liked = true
        databaseReference.child("coursePostLikes").child(post.schoolUID).child(post.departmentUID).child(post.uid).child(post.instructorUID).child(post.uid).removeValue { (error, _) in
            if (error == nil) {
                databaseReference.child("coursePosts").child(post.schoolUID).child(post.departmentUID).child(post.uid).child(post.instructorUID).child(post.uid).child("numberOfLikes").runTransactionBlock { (currentData) -> TransactionResult in
                    var value = currentData.value as? Int
                    if (value == nil) {
                        value = 0
                    }
                    currentData.value = value! - 1
                    return TransactionResult.success(withValue: currentData)
                }
                
                databaseReference.child("users").child(post.studentUID).child("coursePosts").child(post.uid).child("numberOfLikes").runTransactionBlock { (currentData) -> TransactionResult in
                    var value = currentData.value as? Int
                    if (value == nil) {
                        value = 0
                    }
                    currentData.value = value! - 1
                    return TransactionResult.success(withValue: currentData)
                }
                databaseReference.child("users").child(thisUser!.uid!).child("postLikes").child(post.schoolUID).child(post.uid).child(post.instructorUID).child(post.uid).updateChildValues([post.uid: false])
            }
        }
    }
    
    func reloadData() {
        self.loading = false
        self.postsAreDownloaded = true
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func postStudentInfo(post: Post) -> NSAttributedString {
        let info = NSMutableAttributedString()
        if let fullName = thisUser!.fullName {
            info.append(newAttributedString(string: fullName, color: .black, stringAlignment: .natural, fontSize: 19, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
        }
        if let username = thisUser!.username {
            info.append(newAttributedString(string: "\n" + username, color: .black, stringAlignment: .natural, fontSize: 17, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        }
        return info
    }
    
    @objc func postOptions(sender: UIButton) {
//        let post = self.posts[sender.tag]
        let actionController = SkypeActionController()
        actionController.addAction(Action("Share Post", style: .default, handler: { (action) in
            
        }))
        actionController.addAction(Action("Flag Post", style: .default, handler: { (action) in
            
        }))
        actionController.addAction(Action("Message User", style: .default, handler: { (action) in
            
        }))
        actionController.addAction(Action("Block User", style: .default, handler: { (action) in
            
        }))
        actionController.addAction(Action("Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(actionController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1) {
            let header = tableView.dequeueReusableCell(withIdentifier: "accountControlCell") as! AccountControlCell
            header.segmentedControl.selectedSegmentIndex = self.segmentedControlValue
            header.segmentedControl.addTarget(self, action: #selector(self.getSegmentValue(sender:)), for: .valueChanged)
            return header
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1) {
            return 45
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (self.segmentedControlValue == 0) {
            if (self.posts.count > 0) {
                return self.posts.count
            } else {
                return 1
            }
        } else {
            if (self.socialAccounts.count > 0) {
                return self.socialAccounts.count
            } else {
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountDetailsCell", for: indexPath) as! AccountDetailsCell
            self.setUpTextView(textView: cell.textView)
            cell.headerImageView.tag = 0
            if let headerImageData = thisUser!.headerImage {
                cell.headerImageView.image = UIImage(data: headerImageData as Data)
                self.setUpAccountGestureRecognizer(imageView: cell.headerImageView)
            }
            cell.profileImageView.tag = 1
            if let profileImageData = thisUser!.profileImage {
                cell.profileImageView.image = UIImage(data: profileImageData as Data)
                self.setUpAccountGestureRecognizer(imageView: cell.profileImageView)
            }
            cell.profileImageBGView.layer.cornerRadius = cell.profileImageBGView.frame.size.height / 2
            cell.profileImageBGView.clipsToBounds = true
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.height / 2
            cell.profileImageView.clipsToBounds = true
            self.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = self.accountDetailsText()
            return cell
        } else if (self.loading == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountLoadingCell", for: indexPath) as! AccountLoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            if (self.posts.count > 0) {
                let post = self.posts[indexPath.row]
                let images = post.images
                if (post.numberOfImages == 0) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "accountPost0ImgCell", for: indexPath) as! AccountPost0ImgCell
                    cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                    if let profileImageData = thisUser!.profileImage {
                        cell.profileImageView.image = UIImage(data: profileImageData as Data)
                        self.setUpAccountGestureRecognizer(imageView: cell.profileImageView)
                    }
                    self.setUpTextView(textView: cell.profileTextView)
                    self.setUpTextView(textView: cell.postTextView)
                    cell.profileTextView.attributedText = self.postStudentInfo(post: post)
                    cell.postTextView.text = post.text
                    cell.commentButton.setTitle("\(post.numberOfComments)", for: .normal)
                    if (post.liked == true) {
                        cell.likeButton.setImage(#imageLiteral(resourceName: "Like Active"), for: .normal)
                    } else {
                        cell.likeButton.setImage(#imageLiteral(resourceName: "Like Inactive"), for: .normal)
                    }
                    cell.likeButton.setTitle("\(post.numberOfLikes)", for: .normal)
                    cell.taggedStudentsButton.setTitle("\(post.numberOfTaggedStudents)", for: .normal)
                    let buttons = [cell.commentButton, cell.likeButton, cell.taggedStudentsButton, cell.optionsButton]
                    for button in buttons {
                        button!.tag = indexPath.row
                    }
                    cell.profileImageView.tag = indexPath.row
                    cell.profileTextView.tag = indexPath.row
                    cell.commentButton.addTarget(self, action: #selector(self.newComment(sender:)), for: .touchUpInside)
                    cell.likeButton.addTarget(self, action: #selector(self.likePost(sender:)), for: .touchUpInside)
                    cell.taggedStudentsButton.addTarget(self, action: #selector(self.viewTaggedStudents), for: .touchUpInside)
                    cell.optionsButton.addTarget(self, action: #selector(self.postOptions(sender:)), for: .touchUpInside)
                    return cell
                } else if (post.numberOfImages == 3) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "accountPost3ImgCell", for: indexPath) as! AccountPost3ImgCell
                    cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                    if let profileImageData = thisUser!.profileImage {
                        cell.profileImageView.image = UIImage(data: profileImageData as Data)
                        self.setUpAccountGestureRecognizer(imageView: cell.profileImageView)
                    }
                    self.setUpTextView(textView: cell.profileTextView)
                    self.setUpTextView(textView: cell.postTextView)
                    cell.profileTextView.attributedText = self.postStudentInfo(post: post)
                    cell.postTextView.text = post.text
                    cell.commentButton.setTitle("\(post.numberOfComments)", for: .normal)
                    if (post.liked == true) {
                        cell.likeButton.setImage(#imageLiteral(resourceName: "Like Active"), for: .normal)
                    } else {
                        cell.likeButton.setImage(#imageLiteral(resourceName: "Like Inactive"), for: .normal)
                    }
                    cell.likeButton.setTitle("\(post.numberOfLikes)", for: .normal)
                    cell.taggedStudentsButton.setTitle("\(post.numberOfTaggedStudents)", for: .normal)
                    let buttons = [cell.commentButton, cell.likeButton, cell.taggedStudentsButton]
                    for button in buttons {
                        button!.tag = indexPath.row
                    }
                    cell.imageView0.tag = 0
                    cell.imageView1.tag = 1
                    cell.imageView2.tag = 2
                    cell.profileImageView.tag = indexPath.row
                    cell.profileTextView.tag = indexPath.row
                    if (post.images.indices.contains(0)) {
                        cell.imageView0.image = images[0]
                        cell.imageView0.isUserInteractionEnabled = true
                        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                        cell.imageView0.addGestureRecognizer(gestureRecognizer)
                    }
                    if (post.images.indices.contains(1)) {
                        cell.imageView1.image = images[1]
                        cell.imageView1.isUserInteractionEnabled = true
                        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                        cell.imageView1.addGestureRecognizer(gestureRecognizer)
                    }
                    if (post.images.indices.contains(2)) {
                        cell.imageView2.image = images[2]
                        cell.imageView2.isUserInteractionEnabled = true
                        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                        cell.imageView1.addGestureRecognizer(gestureRecognizer)
                    }
                    cell.commentButton.addTarget(self, action: #selector(self.newComment(sender:)), for: .touchUpInside)
                    cell.likeButton.addTarget(self, action: #selector(self.likePost(sender:)), for: .touchUpInside)
                    cell.taggedStudentsButton.addTarget(self, action: #selector(self.viewTaggedStudents), for: .touchUpInside)
                    cell.optionsButton.addTarget(self, action: #selector(self.postOptions(sender:)), for: .touchUpInside)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "accountPost5ImgCell", for: indexPath) as! AccountPost5ImgCell
                    cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                    if let profileImageData = thisUser!.profileImage {
                        cell.profileImageView.image = UIImage(data: profileImageData as Data)
                        self.setUpAccountGestureRecognizer(imageView: cell.profileImageView)
                    }
                    self.setUpTextView(textView: cell.profileTextView)
                    self.setUpTextView(textView: cell.postTextView)
                    cell.profileTextView.attributedText = self.postStudentInfo(post: post)
                    cell.postTextView.text = post.text
                    cell.commentButton.setTitle("\(post.numberOfComments)", for: .normal)
                    if (post.liked == true) {
                        cell.likeButton.setImage(#imageLiteral(resourceName: "Like Active"), for: .normal)
                    } else {
                        cell.likeButton.setImage(#imageLiteral(resourceName: "Like Inactive"), for: .normal)
                    }
                    cell.likeButton.setTitle("\(post.numberOfLikes)", for: .normal)
                    cell.taggedStudentsButton.setTitle("\(post.numberOfTaggedStudents)", for: .normal)
                    let buttons = [cell.commentButton, cell.likeButton, cell.taggedStudentsButton]
                    for button in buttons {
                        button!.tag = indexPath.row
                    }
                    cell.imageView0.tag = 0
                    cell.imageView1.tag = 1
                    cell.imageView2.tag = 2
                    cell.imageView3.tag = 3
                    cell.imageView4.tag = 4
                    cell.profileImageView.tag = indexPath.row
                    cell.profileTextView.tag = indexPath.row
                    if (post.numberOfImages == 1) {
                        if (post.images.indices.contains(0)) {
                            cell.imageView0.image = images[0]
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView0.addGestureRecognizer(gestureRecognizer)
                        }
                    } else if (post.numberOfImages == 2) {
                        cell.imageView1.isHidden = false
                        if (post.images.indices.contains(0)) {
                            cell.imageView0.image = images[0]
                            cell.imageView0.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView0.addGestureRecognizer(gestureRecognizer)
                        }
                        if (post.images.indices.contains(1)) {
                            cell.imageView1.image = images[1]
                            cell.imageView1.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView1.addGestureRecognizer(gestureRecognizer)
                        }
                    } else if (post.numberOfImages == 4) {
                        cell.bottomStackView.isHidden = false
                        cell.imageView1.isHidden = false
                        cell.imageView2.isHidden = false
                        cell.imageView3.isHidden = false
                        if (post.images.indices.contains(0)) {
                            cell.imageView0.image = images[0]
                            cell.imageView0.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView0.addGestureRecognizer(gestureRecognizer)
                        }
                        if (post.images.indices.contains(1)) {
                            cell.imageView1.image = images[1]
                            cell.imageView1.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView1.addGestureRecognizer(gestureRecognizer)
                        }
                        if (post.images.indices.contains(2)) {
                            cell.imageView2.image = images[2]
                            cell.imageView2.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView2.addGestureRecognizer(gestureRecognizer)
                        }
                        if (post.images.indices.contains(3)) {
                            cell.imageView3.image = images[3]
                            cell.imageView0.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView3.addGestureRecognizer(gestureRecognizer)
                        }
                    } else {
                        cell.bottomStackView.isHidden = false
                        cell.imageView1.isHidden = false
                        cell.imageView2.isHidden = false
                        cell.imageView3.isHidden = false
                        cell.imageView4.isHidden = false
                        if (post.images.indices.contains(0)) {
                            cell.imageView0.image = images[0]
                            cell.imageView0.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView0.addGestureRecognizer(gestureRecognizer)
                        }
                        if (post.images.indices.contains(1)) {
                            cell.imageView1.image = images[1]
                            cell.imageView1.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView1.addGestureRecognizer(gestureRecognizer)
                        }
                        if (post.images.indices.contains(2)) {
                            cell.imageView2.image = images[2]
                            cell.imageView2.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView2.addGestureRecognizer(gestureRecognizer)
                        }
                        if (post.images.indices.contains(3)) {
                            cell.imageView3.image = images[3]
                            cell.imageView3.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView3.addGestureRecognizer(gestureRecognizer)
                        }
                        if (post.images.indices.contains(4)) {
                            cell.imageView4.image = images[4]
                            cell.imageView4.isUserInteractionEnabled = true
                            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargePostImage(recognizer:)))
                            cell.imageView4.addGestureRecognizer(gestureRecognizer)
                        }
                    }
                    cell.commentButton.addTarget(self, action: #selector(self.newComment(sender:)), for: .touchUpInside)
                    cell.likeButton.addTarget(self, action: #selector(self.likePost(sender:)), for: .touchUpInside)
                    cell.taggedStudentsButton.addTarget(self, action: #selector(self.viewTaggedStudents), for: .touchUpInside)
                    cell.optionsButton.addTarget(self, action: #selector(self.postOptions(sender:)), for: .touchUpInside)
                    return cell
                }
            } else {
                return self.accountEmptyDataSet(tableView: self.tableView, indexPath: indexPath, title: "Posts", description: "There user hasen't posted anything", image: #imageLiteral(resourceName: "Posts"))
            }
        }
//        else {
//            if (self.socialAccounts.count > 0) {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "studentInfoSocialAccountCell", for: indexPath) as! StudentInfoSocialAccountCell
//                let socialAccount = self.socialAccounts[indexPath.row]
//                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: socialAccount.bgColor)
//                cell.socialImageView.clipsToBounds = true
//                cell.socialImageView.image = socialAccount.image
//                self.setUpTextView(textView: cell.textView)
//                cell.textView.textColor = socialAccount.textColor
//                cell.textView.text = socialAccount.type
//                return cell
//            } else {
//                return self.accountEmptyDataSet(tableView: self.tableView, indexPath: indexPath, title: "Social Accounts", description: "This user hasen't linked any of their social accounts yet", image: #imageLiteral(resourceName: "Instructors"))
//            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentRow = -10
        if (indexPath.section == 1) {
            if (self.segmentedControlValue == 0) {
                self.performSegue(withIdentifier: "accountTVCToPostInfoTVCSegue", sender: self)
            } else {
                let socialAccount = socialAccounts[indexPath.row]
//                self.sendUserToSocialLink(link: socialAccount.link)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if (segue.identifier == "accountTVCToPostInfoTVCSegue") {
            if (self.currentRow > -1) {
                let post = self.posts[self.currentRow]
                let destVC = segue.destination as! PostInfoTVC
                if let username = thisUser!.username, let fullName = thisUser!.fullName {
                   post.setUserInfo(username: username, fullName: fullName)
                }
                if let profileImageData = thisUser!.profileImage {
                    post.setUserProfileImage(image: UIImage(data: profileImageData as Data)!)
                }
                destVC.post = post
            } else {
                let post = self.posts[indexPath!.row]
                let destVC = segue.destination as! PostInfoTVC
                if let username = thisUser!.username, let fullName = thisUser!.fullName {
                    post.setUserInfo(username: username, fullName: fullName)
                }
                if let profileImageData = thisUser!.profileImage {
                    post.setUserProfileImage(image: UIImage(data: profileImageData as Data)!)
                }
                destVC.post = post
            }
        } else if (segue.identifier == "accountTVCToPostInteractionTVCSegue") {
            let post = self.posts[self.currentRow]
            let destVC = segue.destination as! PostInteractionTVC
            destVC.post = post
            if let username = thisUser!.username, let fullName = thisUser!.fullName {
                post.setUserInfo(username: username, fullName: fullName)
            }
            if let profileImageData = thisUser!.profileImage {
                post.setUserProfileImage(image: UIImage(data: profileImageData as Data)!)
            }
            destVC.interaction = self.postInteraction
        }
    }
}
