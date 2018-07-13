//
//  StudentInfoTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 1/6/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SCLAlertView
import NYTPhotoViewer
import XLActionController

class StudentInfoTVC: UITableViewController, NYTPhotosViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Variables
    var student: Student2!
    var postsAreLoading = Bool()
    var postsAreDownloaded = Bool()
    var posts = [Post2]()
    var socialAccounts = [SocialAccount]()
    var segmentedControlValue = Int()
    var profileGestureRecognizerUsed = Bool()
    var currentRow = Int()
    var postInteraction = String()
    
    // MARK: Basics
    /*
     * Checks for an active network connection
     * Registers segmented control header with table view
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpNavBarTitle()
        self.setUpTableView(tableView: self.tableView)
        self.tableView.register(UINib(nibName: "SegmentedControlHeaderView3", bundle: nil), forHeaderFooterViewReuseIdentifier: "segmentedControlHeaderView3")
        if (self.checkNetwork() == true) { // Checks for an active network connection
            self.getSchool()
            self.getPosts()
        }
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    } 
    
    /*
     * Sets navigation bar title to be username or "Student"
     */
    func setUpNavBarTitle() {
        if let username = student?.getUsername() { // Tries to get username
            self.navigationItem.title = username
        } else { // Username not found
            self.navigationItem.title = "Student"
        }
    }
    
    // MARK: Segmented Control
    /*
     * Gets the segmented control value
     */
    @objc func getSegmentValue(sender: UISegmentedControl) {
        self.segmentedControlValue = sender.selectedSegmentIndex
        self.chooseDataToDisplay()
    }
    
    /*
     * Chooses data to display depending on segmented control value
     * Gets new data if refresh control is refreshing or data has not yet been downloaded
     * Displays pre-loaded data otherwise
     */
    func chooseDataToDisplay() {
        if (self.segmentedControlValue == 0 && self.postsAreDownloaded == false) { // Corresponds to posts
            self.getPosts()
        } else { // Corresponds to social links
            self.getSocialLinks()
        }
    }
    
    // MARK: Get School
    func getSchool() {
        if let schoolRef = self.student.getSchool()?.getRef() { // Tries to get school ref
            schoolRef.getDocument(completion: { (snap, error) in // Gets school
                if (error == nil && snap!.exists) { // Checks for no error and data (snap) exists
                    self.student.setSchool(school: School(city: snap?.data()!["city"] as? String, coordinates: snap?.data()!["coordinates"] as? GeoPoint, countryCode: snap?.data()!["countryCode"] as? String, name: snap?.data()!["name"] as? String, postalCode: snap?.data()!["postalCode"] as? String, state: snap?.data()!["state"] as? String, ref: schoolRef))
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            })
        }
    }
    
    // MARK: Get Posts
    /*
     * Reloads table view to show activity indicator
     * Downloads user's posts from Firebase Firestore
     * Uses DispatchGroup to get all data
     */
    func getPosts() {
        // Reloads table view to show activity indicator
        self.postsAreLoading = true
        self.tableView.reloadData()
        if let studentRef = self.student?.getRef() { // Tries to get student ref
            studentRef.collection("posts").getDocuments(completion: { (snap, error) in // Downloads posts
                if let error = error { // Checks for an error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.reloadData()
                } else { // No error
                    let group = DispatchGroup()
                    for post in snap!.documents { // Gets all posts
                        if let postRef = post.data()["postRef"] as? DocumentReference { // Tries to get post ref
                            group.enter()
                            self.getPost(postRef: postRef, group: group)
                        }
                    }
                    group.notify(queue: .main, execute: {
                        if (self.segmentedControlValue == 0) { // Checks if segmented control is still on posts
                            self.reloadData()
                        }
                        self.getPostImages()
                    })
                }
            })
        } else { // Student ref not found
            self.displayError(title: "Error", message: "Something went wrong. Plase try again later")
            if (self.segmentedControlValue == 0) { // Checks if segmented control is still on posts
                self.reloadData()
            }
        }
    }
    
    func getPost(postRef: DocumentReference, group: DispatchGroup) {
        postRef.getDocument { (snap, error) in
            if (error == nil && snap!.exists) { // Checks for no error and snap exists
                let postObj = Post2(uid: snap!.documentID, numComments: snap!.data()!["numComments"] as? Int, numLikes: snap!.data()!["numLikes"] as? Int, numTagged: snap!.data()!["numTagged"] as? Int, text: snap!.data()!["text"] as? String, imagePaths: snap!.data()!["imagePaths"] as? [String], ref: snap!.reference)
                self.posts.append(postObj)
                self.checkLike(postRef: snap!.reference, post: postObj, group: group)
            } else { // Error and/or snap does not exist
                group.leave()
            }
        }
    }
    
    /*
     * Checks to see if the user liked the post
     * Sets the bool in Post
     */
    func checkLike(postRef: DocumentReference, post: Post2, group: DispatchGroup) {
        postRef.collection("likes").document(currentUser!.uid).getDocument { (snap, error) in // Tries to get user like
            if (error == nil && snap!.exists) { // Checks if there is no error and data exists
                post.setLiked(liked: true)
            } else { // Like found
                post.setLiked(liked: false)
            }
            group.leave()
        }
    }
    
    /*
     * Downloads images included in the post
     * Adds images to post
     * Uses DispatchGroup to wait for all images to download (for each post individually)
     */
    func getPostImages() {
        for post in self.posts { // Loops through posts to get image paths
            if let imagePaths = post.getImagePaths() { // Tries to get Firebase Storage image paths
                let group = DispatchGroup()
                for imagePath in imagePaths { // Loops through image paths to get images
                    group.enter()
                    storageReference.child(imagePath).getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if (error == nil && data != nil) { // Gets image
                            if let image = UIImage(data: data!) { // Tries to turn data into UIImage
                                post.addImage(image: image)
                            }
                        }
                        group.leave()
                    })
                }
                group.notify(queue: .main, execute: {
                    if (self.segmentedControlValue == 0) { // Checks if the segmented control is still on posts
                        self.displayPostImages(post: post)
                    }
                })
            }
        }
    }
    
    /*
     * Gets the index of the post
     * Reloads the row (index) of the UITableView
     * Looks in section 1 (section 0 only holds course info)
     */
    func displayPostImages(post: Post2) {
        let row = self.posts.index(of: post)
        self.tableView.reloadRows(at: [IndexPath(row: row!, section: 1)], with: .none)
    }
    
    /*
     * Sets postsAreLoading to false
     * Sets postsAreDownloaded to true
     * Reloads table view
     * Ends refresh controler's refreshing
     */
    func reloadData() {
        self.postsAreLoading = false
        self.postsAreDownloaded = true
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: Get Social Links
    /*
     * Gets social links
     * Reloads table view to display links
     */
    func getSocialLinks() {
        if let facebook = self.student.getFacebook() { // Tries to get Facebook link
            self.socialAccounts.append(SocialAccount(bgColor: facebookColor, textColor: .white, image: #imageLiteral(resourceName: "Facebook Logo"), text: "Facebook Link", link: URL(string: facebook)))
        }
        if let twitter = self.student.getTwitter() { // Tries to get Twitter link
            self.socialAccounts.append(SocialAccount(bgColor: twitterColor, textColor: .white, image: #imageLiteral(resourceName: "Twitter Logo"), text: "Twitter Link", link: URL(string: twitter)))
        }
        if let instagram = self.student.getInstagram() { // Tries to get Instagram link
            self.socialAccounts.append(SocialAccount(bgColor: .white, textColor: .black, image: #imageLiteral(resourceName: "Instagram Logo"), text: "Instagram Link", link: URL(string: instagram)))
        }
        if let snapchat = self.student.getSnapchat() { // Tries to get Snapchat link
            self.socialAccounts.append(SocialAccount(bgColor: snapchatColor, textColor: .black, image: #imageLiteral(resourceName: "Snapchat"), text: "Snapchat Link", link: URL(string: snapchat)))
        }
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewCell Buttons
    /*
     * Handles buttons on the options action controller
     */
    @objc func optionsButtonPressed(sender: UIButton) {
        let actionController = SkypeActionController()
        actionController.backgroundColor = studyHubBlue
        if let studentUID = self.student.getUID(), let userUID = currentUser?.uid { // Tries to get student uid and current user uid
            if (studentUID == userUID && self.segmentedControlValue == 0) { // Checks if the student is the current user and the segemted control is on "posts"
                actionController.addAction(Action("Share Post", style: .default, handler: { (action) in
                    
                }))
                actionController.addAction(Action("Edit Post", style: .default, handler: { (action) in
                    
                }))
                actionController.addAction(Action("Delete Post", style: .default, handler: { (action) in
                    
                }))
            } else { // Student is not the current user and/or the segemented control value is not on "posts"
                actionController.addAction(Action("Message User", style: .default, handler: { (action) in
                    
                }))
                actionController.addAction(Action("Block User", style: .default, handler: { (action) in
                    
                }))
                if (self.segmentedControlValue == 0) { // Checks if the segemted control is on "posts"
                    actionController.addAction(Action("Flag Post", style: .default, handler: { (action) in
                        
                    }))
                }
            }
            actionController.addAction(Action("Cancel", style: .default, handler: { (action) in
                
            }))
            self.present(actionController, animated: true, completion: nil)
        } else { // Student uid and/or current user uid was not found
            self.displayError(title: "Error", message: "Something went wrong. Please try again later")
        }
    }
    
    /*
     * Gets the selected row
     * Segues to PostInfoTVC
     */
    @objc func newComment(sender: UIButton) {
        self.currentRow = sender.tag
//        self.performSegue(withIdentifier: "studentInfoTVCToPostInfoTVCSegue", sender: self)
    }
    
    /*
     * Gets the selected row
     * Checks if the post is currently liked or not liked
     * Updates liked image
     */
    @objc func likePost(sender: UIButton) {
        if (sender.currentImage == #imageLiteral(resourceName: "Like Inactive")) { // Post was previously not liked
            sender.setImage(#imageLiteral(resourceName: "Like Active"), for: .normal)
            self.addLike(row: sender.tag)
        } else { // Post was previously liked
            sender.setImage(#imageLiteral(resourceName: "Like Inactive"), for: .normal)
            self.removeLike(row: sender.tag)
        }
    }
    
    /*
     * Gets the selected row
     * Sets the postInteraction
     * Segues to PostInteractionTVC
     */
    @objc func viewTaggedStudents(sender: UIButton) {
        self.currentRow = sender.tag
        self.postInteraction = "taggedStudents"
//        self.performSegue(withIdentifier: "studentInfoTVCToPostInteractionTVCSegue", sender: self)
    }
    
    // MARK: Handle Post Likes
    /*
     * Gets the post
     * Adds the user to the post's likes list
     * Adds the post to the user's post likes list
     */
    func addLike(row: Int) {
        let post = self.posts[row] // Gets the post
        if let postRef = post.getRef(), let userRef = thisUser!.ref as? DocumentReference { // Tries to get the post ref and user ref
            postRef.collection("likes").document(userRef.documentID).setData(["userRef": userRef]) // Adds the user to the post's likes list
            userRef.collection("postLikes").document(postRef.documentID).setData(["postRef": postRef])// Adds the post to the user's post likes list
            self.handleLikeTransaction(post: post, liked: true)
            post.setLiked(liked: true)
        }
    }
    
    /*
     * Gets the post
     * Removes the user to the post's likes list
     * Removes the post from the user's post likes list
     */
    func removeLike(row: Int) {
        let post = self.posts[row] // Gets the post
        if let postRef = post.getRef(), let userRef = thisUser!.ref as? DocumentReference  { // Tries to get the post ref and user ref
            postRef.collection("likes").document(userRef.documentID).delete() // Removes the user from the post's likes list
            userRef.collection("postLikes").document(postRef.documentID).delete() // Removes the post from the user's post likes list
            self.handleLikeTransaction(post: post, liked: false)
            post.setLiked(liked: false)
        }
    }
    
    /*
     * Increments or decrements the post's numLikes
     * Uses transaction
     */
    func handleLikeTransaction(post: Post2, liked: Bool) {
        firestoreRef.runTransaction({ (transaction, error) -> Any? in
            let snap: DocumentSnapshot
            // Tries to get the current numLikes
            do {
                try snap = transaction.getDocument(post.getRef()!)
                if (snap.exists) { // Gets number of likes
                    // Determines whether to increment or decrement numLikes
                    var numLikes = 0
                    if let number = snap.data()!["numLikes"] as? Int { // Tries to get number of likes
                        numLikes = number
                    }
                    if (liked) { // Post was liked
                        numLikes += 1
                    } else if (numLikes > 0) { // Post was unliked and number of likes is > 0
                        numLikes -= 1
                    }
                    transaction.updateData(["numLikes": numLikes], forDocument: post.getRef()!) // Uploads updated number of likes
                }
            } catch {
            }
            return nil
        }, completion: { (_, _) in
        })
    }
    
    // MARK: Set up NSAttributedStrings
    /*
     * Creates attributed string with student's full name and bio
     */
    func getStudentHeader() -> NSAttributedString? {
        let info = NSMutableAttributedString()
        var infoAdded = Bool()
        if let fullName = self.student.getFullName() { // Tries to get full name
            info.append(newAttributedString(string: fullName, color: .black, stringAlignment: .natural, fontSize: 20, fontWeight: .medium, paragraphSpacing: 10))
            infoAdded = true
        }
        if let bio = self.student.getBio() { // Tries to get bio
            info.append(newAttributedString(string: "\n" + bio, color: .black, stringAlignment: .natural, fontSize: 15, fontWeight: .regular, paragraphSpacing: 0))
            infoAdded = true
        }
        if (infoAdded) { // Checks if info was added
            return info
        } else { // No info added
            return nil
        }
    }
    
    /*
     * Creates attributed string with student's full name and username
     */
    func getStudentInfo() -> NSMutableAttributedString? {
        var infoAdded = Bool()
        let info = NSMutableAttributedString()
        if let fullName = student.getFullName() { // Tries to get full name
            info.append(newAttributedString(string: fullName, color: .black, stringAlignment: .natural, fontSize: 15, fontWeight: .bold, paragraphSpacing: 11))
            infoAdded = true
        }
        if let username = student.getUsername() { // Tries to get username
            info.append(newAttributedString(string: "\n" + username, color: .black, stringAlignment: .natural, fontSize: 12, fontWeight: .regular, paragraphSpacing: 0))
            infoAdded = true
        }
        if (infoAdded) { // Checks if info was added
            return info
        } else { // No info added
            return nil
        }
    }
    
    // MARK: Enlarge Images
    /*
     * Tries to gets profile image
     * Displays images using NYTPhotoVC
     */
    @objc func enlargeProfileImage(recognizer: UITapGestureRecognizer) {
//        let photo = NYTPhotoImgOnly(image: self.student.getProfileImage()!)
//        let vc = NYTPhotosViewController(photos: [photo])
//        vc.rightBarButtonItem = nil
//        self.present(vc, animated: true, completion: nil)
    }
    
    /*
     * Gets post images from selected post image
     * Displays images using NYTPhotoVC
     * Displays selected image first
     */
    func enlargePostImage(row: Int, item: Int) {
//        let post = self.posts[row] // Gets the correct post
//        var photos = [NYTPhotoImgOnly]() // Holds images to be displayed
//        if let images = post.getImages() { // Tries to get post images
//            for image in images { // Loops through all images and adds them to photos
//                photos.append(NYTPhotoImgOnly(image: image))
//            }
//            // Sets up the NYTPhotosVC and displays the images
//            NYTPhotosViewController(
//            let vc = NYTPhotosViewController(photos: photos)
//            vc.rightBarButtonItem = nil
//            vc.display(photos[item], animated: true) // Displays selected image first
//            self.present(vc, animated: true, completion: nil)
//        }
    }
    
    // MARK: Empty Data Set
    /*
     * Sets up custom empty data set
     */
    func setUpEmptyDataSet(cell: StudentInfoEmptyDataSetCell, title: String, description: String, image: UIImage) {
        // Sets up attributed string
        let text = NSMutableAttributedString()
        text.append(newAttributedString(string: title, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 15))
        text.append(newAttributedString(string: "\n" + description, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = text
        cell.largeImageView.image = image // Displays custom empty data set image
    }
    
    // MARK: Set up UITableViewCells
    /*
     * Gets student information (full name, profile image, and school name)
     * Sets up profile image view, profile text view, and school button
     */
    func setUpDetailsCell(cell: StudentInfoDetailsCell) {
        if let profileImage = self.student.getProfileImage() { // Tries to get profile image
            cell.profileImageView.image = profileImage
            let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargeProfileImage(recognizer:)))
            cell.profileImageView.addGestureRecognizer(profileImageGestureRecognizer)
        }
        if let info = self.getStudentHeader() { // Tries to get student info
            cell.profileTextView.attributedText = info
        } else { // Student info not found
            cell.profileTextView.attributedText = newAttributedString(string: "Error", color: .black, stringAlignment: .natural, fontSize: 25, fontWeight: .bold, paragraphSpacing: 0)
        }
        if let schoolName = self.student.getSchool()?.getName() { // Tries to gets school name
            cell.schoolButton.setTitle(schoolName, for: .normal)
            cell.schoolButton.addTarget(self, action: #selector(self.schoolButtonPressed(sender: )), for: .touchUpInside)
        } else { // School name not found
            cell.schoolButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
    
    @objc func schoolButtonPressed(sender: UIButton) {
//        self.performSegue(withIdentifier: "studentInfoTVCToSchoolInfoTVCSegue", sender: self)
    }
    
    /*
     * Gets post
     * Sets up UITextViews
     * Sets up bottom UIButtons (comments, likes, and tagged students
     * Sets button tags to cell row
     * Sets up actions for buttons
     * Sets up profile image view
     * Changes the height anchor of the images collection view if the post doesn't have any images
     * Sets up gesture recognizers for profile image view and profile info
     */
    func setUpPostCell(cell: StudentInfoPostCell, row: Int) {
        let post = self.posts[row]
        // Sets up text
        self.setUpTextView(textView: cell.profileTextView)
        self.setUpTextView(textView: cell.postTextView)
        cell.profileTextView.attributedText = self.getStudentInfo()
        if let text = post.getText() { // Tries to get text
            cell.postTextView.attributedText = newAttributedString(string: text, color: .black, stringAlignment: .natural, fontSize: 20, fontWeight: .regular, paragraphSpacing: 0)
        }
        // Sets up bottom buttons
        if let numComments = post.getNumComments() { // Tries to get number of comments
            if (numComments > 0) { // Only displays number if there are 1+ comments
                cell.commentButton.setTitle("\(numComments)", for: .normal)
            }
        }
        if let liked = post.isLiked() { // Tries to get if Student liked the Post
            if (liked) { // Checks if the Student liked the Post
                cell.likeButton.setImage(#imageLiteral(resourceName: "Like Active"), for: .normal)
            }
        } else {
            cell.likeButton.setImage(#imageLiteral(resourceName: "Like Inactive"), for: .normal)
        }
        if let numLikes = post.getNumLikes() { // Tries to get number of likes
            if (numLikes > 0) { // Only displays number if there are 1+ likes
                cell.likeButton.setTitle("\(numLikes)", for: .normal)
            }
        }
        if let numTagged = post.getNumTagged() { // Tries to get number of tagged students
            if (numTagged > 0) { // Only displays number if there are 1+ tagged students
                cell.taggedStudentsButton.setTitle("\(numTagged)", for: .normal)
            } else { // Hides button if there are no tagged students
                cell.taggedStudentsButton.isHidden = true
            }
        } else {
            cell.taggedStudentsButton.isHidden = true
        }
        // Sets up tags for tappable objects
        cell.commentButton.tag = row
        cell.likeButton.tag = row
        cell.taggedStudentsButton.tag = row
        cell.optionsButton.tag = row
        cell.profileImageView.tag = row
        cell.profileTextView.tag = row
        // Sets up actions for buttons
        cell.commentButton.addTarget(self, action: #selector(self.newComment(sender:)), for: .touchUpInside)
        cell.likeButton.addTarget(self, action: #selector(self.likePost(sender:)), for: .touchUpInside)
        cell.taggedStudentsButton.addTarget(self, action: #selector(self.viewTaggedStudents), for: .touchUpInside)
        cell.optionsButton.addTarget(self, action: #selector(self.optionsButtonPressed(sender:)), for: .touchUpInside)
        // Sets profileImageView
        if let profileImage = post.getStudent()?.getProfileImage() {
            cell.profileImageView.image = profileImage
        } else {
            cell.profileImageView.image = #imageLiteral(resourceName: "Snapchat")
        }
        cell.imagesCollectionView.delegate = self
        cell.imagesCollectionView.dataSource = self
        cell.imagesCollectionView.tag = row
        if let numImages = post.getImages()?.count { // Tries to get number of post images
            if (numImages == 0) { // No images exist
                cell.imagesCollectionView.heightAnchor.constraint(equalToConstant: 0).isActive = true // Make height of images collection view 0
            }
        }
        cell.imagesCollectionView.reloadData()
    }
    
    /*
     * Gets social account
     * Sets up cell background view, image view, and text view
     */
    func setUpSocialCell(cell: StudentInfoSocialCell, row: Int) {
        let socialAccount = self.socialAccounts[row]
        cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: socialAccount.getBGColor()!)
        cell.socialImageView.image = socialAccount.getImage()!
        cell.accountUsernameTextView.attributedText = newAttributedString(string: socialAccount.getText()!, color: socialAccount.getTextColor()!, stringAlignment: .natural, fontSize: 25, fontWeight: .medium, paragraphSpacing: 0)
    }
    
    func sendUserToSocialLink(link: String) {
        if (UIApplication.shared.canOpenURL(URL(string: link)!) == true) {
            UIApplication.shared.open(URL(string: link)!, options: [:], completionHandler: nil)
        } else {
            self.displayError(title: "Error", message: "There was a problem opening this link. Please try again later.")
        }
    }
    
    // MARK: UITableView
    /*
     * Returns number of sections (always 2)
     * Section 0 is the student info details cell
     * Section 1 includes student info cells
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /*
     * Sets up a segmented control as the section 1 header
     */
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1) { // Only adds header to section 1
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "segmentedControlHeaderView3") as! SegmentedControlHeaderView3
            header.contentView.backgroundColor = .white
            header.segmentedControl.selectedSegmentIndex = self.segmentedControlValue
            header.segmentedControl.layer.cornerRadius = 10
            header.segmentedControl.layer.borderWidth = 1.0
            header.segmentedControl.layer.borderColor = studyHubBlue.cgColor
            header.segmentedControl.clipsToBounds = true
            header.segmentedControl.addTarget(self, action: #selector(self.getSegmentValue(sender:)), for: .valueChanged)
            return header
        } else { // Not section 1
            return nil
        }
    }
    
    /*
     * Returns custom height for segmented control header
     */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1) { // Header only exists for section 1
            return 45
        } else { // Not section 1
            return 0
        }
    }
    
    /*
     * Returns number of rows in each section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) { // Only one cell (student info)
            return 1
        } else if (self.segmentedControlValue == 0) { // Post cells
            if (self.postsAreLoading) { // Checks if posts are loading
                return 1
            } else if (self.posts.count > 0) { // Checks if posts exist
                return self.posts.count
            } else { // No posts exist
                return 1
            }
        } else { // Social Account cells
            if (self.socialAccounts.count > 0) { // Checks if social accounts exist
                return self.socialAccounts.count
            } else { // No students exist
                return 1
            }
        }
    }
    
    /*
     * Sets up UITableView cells
     * Checks if different data exists
     * Dequeues cells
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) { // Sets up StudentInfoDetailsCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentInfoDetailsCell", for: indexPath) as! StudentInfoDetailsCell // Dequeues new StudentInfoDetailsCell
            self.setUpDetailsCell(cell: cell)
            return cell
        } else if (self.segmentedControlValue == 0) { // Sets up post cell
            if (self.postsAreLoading) { // Checks if posts are loading
                return tableView.dequeueReusableCell(withIdentifier: "studentInfoLoadingCell", for: indexPath) as! StudentInfoLoadingCell // Dequeues new StudentInfoLoadingCell
            } else if (self.posts.count > 0) { // Checks if posts exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "studentInfoPostCell", for: indexPath) as! StudentInfoPostCell
                self.setUpPostCell(cell: cell, row: indexPath.row)
                return cell
            } else { // No posts exist -> Sets up empty data set cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "studentInfoEmptyDataSetCell", for: indexPath) as! StudentInfoEmptyDataSetCell
                self.setUpEmptyDataSet(cell: cell, title: "Posts", description: "This student doesn't have any posts", image: #imageLiteral(resourceName: "Posts"))
                return cell
            }
        } else { // Sets up social account cell
            if (self.socialAccounts.count > 0) { // Checks if any social accounts exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "studentInfoSocialCell", for: indexPath) as! StudentInfoSocialCell
                self.setUpSocialCell(cell: cell, row: indexPath.row)
                return cell
            } else { // No students exist -> Sets up empty data set cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "studentInfoEmptyDataSetCell", for: indexPath) as! StudentInfoEmptyDataSetCell
                self.setUpEmptyDataSet(cell: cell, title: "Social Accounts", description: "This user doesn't have any social accounts", image: #imageLiteral(resourceName: "Instructors"))
                return cell
            }
        }
    }
    
    /*
     * Handles a selected UITableView cell
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentRow = -10 // Sentinel value
        
    }
    
    // MARK: UICollectionView for Post Cells
    /*
     * Returns number of items in the UICollectionView
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numImages = self.posts[collectionView.tag].getImagePaths()?.count { // Tries to get number of images in post
            return numImages
        } else { // Number of images not found
            return 0
        }
    }
    
    /*
     * Sets up image for UICollectionViewCell
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studentInfoPostImageCell", for: indexPath   ) as! StudentInfoPostImageCell // Dequeues new cell
        // Sets up image view
        cell.imageView.layer.cornerRadius = 5
        cell.imageView.clipsToBounds = true
        if let images = self.posts[collectionView.tag].getImages() { // Tries to get post images
            if (images.count > indexPath.item) { // Only adds images downloaded (other cells left blank)
                cell.imageView.image = images[indexPath.item]
            }
        }
        return cell
    }
    
    /*
     *
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.enlargePostImage(row: collectionView.tag ,item: indexPath.item)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let indexPath = tableView.indexPathForSelectedRow
//        if (segue.identifier == "studentInfoTVCToPostInfoTVCSegue") {
//            if (self.currentRow > -1) {
//                let post = self.posts[self.currentRow]
//                let destVC = segue.destination as! PostInfoTVC
//                post.setUserInfo(username: self.student!.username, fullName: self.student!.fullName)
//                post.setUserProfileImage(image: self.student!.profileImage)
//                destVC.post = post
//            } else {
//                let post = self.posts[indexPath!.row]
//                let destVC = segue.destination as! PostInfoTVC
//                post.setUserInfo(username: self.student!.username, fullName: self.student!.fullName)
//                post.setUserProfileImage(image: self.student!.profileImage)
//                destVC.post = post
//            }
//        } else if (segue.identifier == "studentInfoTVCToPostInteractionTVCSegue") {
//            let post = self.posts[self.currentRow]
//            let destVC = segue.destination as! PostInteractionTVC
//            destVC.post = post
//            post.setUserInfo(username: self.student!.username, fullName: self.student!.fullName)
//            post.setUserProfileImage(image: self.student!.profileImage)
//            destVC.interaction = self.postInteraction
//        }
//    }
}
