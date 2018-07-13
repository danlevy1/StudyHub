//
//  CourseInfoTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseStorageUI
import NYTPhotoViewer
import XLActionController

/*
 * UITableViewController that displays:
 * Posts, students, and instructors for the selected course
 */

class CourseInfoTVC: UITableViewController, NYTPhotoViewControllerDelegate , UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: Variables
    var course: Course2!
    var posts = [Post2]()
    var students = [Student2]()
    var instructors = [Instructor2]()
    var postsAreLoading = Bool()
    var studentsAreLoading = Bool()
    var instructorsAreLoading = Bool()
    var segmentedControlValue = Int()
    var currentRow = Int()
    var profileGestureRecognizerUsed = Bool()
    var postInteraction = String()
    var postsAreDownloaded = Bool()
    var studentsAreDownloaded = Bool()
    var instructorsAreDownloaded = Bool()
    var numPostImages = [Int]()
    
    // MARK: Basics
    /*
     * Checks for an active network connection
     * Registers segmented control header with table view
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpRefreshControl()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        if let courseID = self.course.getID() { // Tries to get course id for title
            self.navigationItem.title = courseID
        } else {
           self.navigationItem.title = "Course"
        }
        self.tableView.register(UINib(nibName: "SegmentedControlHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "segmentedControlHeaderView")
        self.setUpTableView(tableView: self.tableView)
        if (self.checkNetwork() == true) { // Makes sure network is available
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
     * Checks for the correct data set to reload
     * Sets data downloaded = true
     * Sets isLoading to false
     * Reloads the tableView
     * Ends refresh controller refreshing
     */
    func reloadData() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: Refresh Control
    /*
     * Sets up refresh control
     */
    func setUpRefreshControl() {
        self.refreshControl?.tintColor = .white
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: .valueChanged)
    }
    
    /*
     * Handles the refresh control being refreshed
     * Checks for an active network connection
     */
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        self.chooseDataToDisplay()
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
        } else if (self.segmentedControlValue == 1 && self.studentsAreDownloaded == false) { // Corresponds to students
            self.getStudents()
        } else if (self.segmentedControlValue == 2 && self.instructorsAreDownloaded == false) { // Corresponds to instructors
            self.getInstructorRefs()
        } else {
            self.tableView.reloadData()
        }
    }
    
    /*
     * Handles buttons on the options action controller
     */
    @objc func optionsButtonPressed(sender: UIButton) {
        let actionController = SkypeActionController()
        actionController.backgroundColor = studyHubBlue
        if let studentUID = self.posts[sender.tag].getStudent()?.getUID(), let userUID = (thisUser!.ref as? DocumentReference)?.documentID { // Tries to get student uid and current user uid
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
    
    // MARK: Enlarge Post Images
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
//            let vc = NYTPhotosViewController(photos: photos)
//            vc.rightBarButtonItem = nil
//            vc.display(photos[item], animated: true) // Displaus selected image first
//            self.present(vc, animated: true, completion: nil)
//        }
    }
    
    // MARK: Empty Data Set
    /*
     * Sets up custom empty data set
     */
    func setUpEmptyDataSet(cell: CourseInfoEmptyDataSetCell, title: String, description: String, image: UIImage) {
        // Sets up attributed string
        let text = NSMutableAttributedString()
        text.append(newAttributedString(string: title, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 15))
        text.append(newAttributedString(string: "\n" + description, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = text
        cell.largeImageView.image = image // Displays custom empty data set image
    }
    
    // MARK: Download Post Data
    /*
     * Checks network connection
     * Reloads tableView with loading cell
     * Downloads course posts
     * Uses DispatchGroup to wait for Firebase Firestore to get all data
     */
    func getPosts() {
        if (self.checkNetwork() == true) { // Checks for an active network connection
            // Reloads tableView with loading cell
            self.postsAreLoading = true
            self.tableView.reloadData()
            if let instructorRef = self.course.getInstructor()?.getRef() { // Tries to get the instructor reference
                instructorRef.collection("posts").getDocuments(completion: { (snap, error) in
                    if let error = error { // Checks for an error
                        self.displayError(title: "Error", message: error.localizedDescription)
                        self.postsAreDownloaded = false
                        self.postsAreLoading = false
                        if (self.segmentedControlValue == 0) { // Checks if the segmented control is still on posts
                            self.reloadData()
                        }
                    } else { // No error fround -> Creates a new DispatchGroup and loops through the Documents (posts) to get data
                        let group = DispatchGroup()
                        for post in snap!.documents { // Loops through posts to get data
                            group.enter()
                            // Creates a new object and adds it to the Post list
                            let postObj = Post2(uid: post.documentID, numComments: post.data()["numComments"] as? Int, numLikes: post.data()["numLikes"] as? Int, numTagged: post.data()["numTaggedStudents"] as? Int, text: post.data()["text"] as? String, imagePaths: post.data()["imagePaths"] as? [String], ref: post.reference)
                            self.posts.append(postObj)
                            if let userRef = post.data()["userRef"] as? DocumentReference { // Tries to get user reference
                               self.checkLike(userRef: userRef, postRef: post.reference, post: postObj, group: group)
                            } else { // User reference not found
                                self.displayError(title: "Error", message: "Something went wrong. Please try again later")
                                self.postsAreDownloaded = false
                                self.postsAreLoading = false
                                if (self.segmentedControlValue == 0) { // Checks if the segmented control is still on posts
                                    self.reloadData()
                                }
                            }
                        }
                        group.notify(queue: .main, execute: { // Reloads Post data
                            self.postsAreDownloaded = true
                            self.postsAreLoading = false
                            if (self.segmentedControlValue == 0) { // Checks if the segmented control is still on posts
                                self.reloadData()
                            }
                            self.getPostImages()
                        })
                    }
                })
            } else { // No instructor reference found
                self.postsAreDownloaded = false
                self.postsAreLoading = false
                if (self.segmentedControlValue == 0) { // Checks if the segmented control is still on posts
                    self.reloadData()
                }
            }
        }
    }
    
    /*
     * Checks to see if the user liked the post
     * Sets the bool in Post
     */
    func checkLike(userRef: DocumentReference, postRef: DocumentReference, post: Post2, group: DispatchGroup) {
        postRef.collection("likes").document(currentUser!.uid).getDocument { (snap, error) in // Tries to get user like
            if (error == nil && snap!.exists) { // Checks if there is no error and data exists
                post.setLiked(liked: true)
            } else { // Like found
                post.setLiked(liked: false)
            }
            self.getUser(userRef: userRef, post: post, group: group)
        }
    }
    
    /*
     * Downloads post author (student)
     * Adds student data to post
     */
    func getUser(userRef: DocumentReference, post: Post2, group: DispatchGroup) {
        userRef.getDocument { (snap, error) in // Gets user
            if (error == nil && snap!.exists) { // Checks if there is no error and data exists
                let student = Student2(uid: snap!.documentID, fullName: snap!.data()!["fullName"] as? String, username: snap!.data()!["username"] as? String, bio: snap!.data()!["bio"] as? String, facebook: snap!.data()!["facebookLink"] as? String, twitter: snap!.data()!["twitterLink"] as? String, instagram: snap!.data()!["instagramLink"] as? String, snapchat: snap!.data()!["snapchatLink"] as? String, ref: userRef, school: School(city: nil, coordinates: nil, countryCode: nil, name: nil, postalCode: nil, state: nil, ref: snap!.data()!["schoolRef"] as? DocumentReference)) // Creates new student object
                post.setStudent(student: student)
            }
            self.getUserProfileImage(userUID: userRef.documentID, post: post, group: group)
        }
    }
    
    /*
     * Downloads post author's profile image from Firebase Storage
     * Adds image to student
     */
    func getUserProfileImage(userUID: String, post: Post2, group: DispatchGroup) {
        if let student = post.getStudent() { // Checks if Student exists
            storageReference.child("users").child("profilePictures").child(userUID + "profilePicture").getData(maxSize: 1 * 1024 * 1024) { (data, error) in // Gets user's profile image
                if (error == nil && data != nil) { // Checks if there is no error and data exists
                    if let image = UIImage(data: data!) { // Tries to turn data into UIImage
                        student.setProfileImage(image: image)
                    }
                }
                group.leave()
            }
        } else {
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
    
    // MARK: Download Student Data
    /*
     * Checks network connection
     * Reloads tableView with loading cell
     * Downloads course students
     * Uses DispatchGroup to wait for Firebase Firestore to get all data
     */
    func getStudents() {
        if (self.checkNetwork() == true) { // Checks for an active network connection
            // Reloads tableView with loading cell
            self.studentsAreLoading = true
            self.tableView.reloadData()
            if let instructorRef = self.course.getInstructor()?.getRef() { // Tries to get instructor ref
                instructorRef.collection("students").getDocuments(completion: { (snap, error) in // Gets students
                    if let error = error { // Checks if there is an error
                        self.displayError(title: "Error", message: error.localizedDescription)
                        self.studentsAreDownloaded = false
                        self.studentsAreLoading = false
                        if (self.segmentedControlValue == 1) { // Checks if segmented control is still on students
                            self.reloadData()
                        }
                    } else { // No error found
                        let group = DispatchGroup()
                        for student in snap!.documents { // Loops through each student to get user refs
                            group.enter()
                            self.getStudent(studentRef: student.data()["userRef"]! as! DocumentReference, group: group)
                        }
                        group.notify(queue: .main, execute: { // Reloads student data
                            self.studentsAreDownloaded = true
                            self.studentsAreLoading = false
                            if (self.segmentedControlValue == 1) { // Checks if segmented control is still on students
                                self.reloadData()
                            }
                            self.getStudentProfileImages()
                        })
                    }
                })
            } else {
                self.studentsAreDownloaded = false
                self.studentsAreLoading = false
                if (self.segmentedControlValue == 1) { // Checks if segmented control is still on students
                    self.reloadData()
                }
            }
        }
    }
    
    /*
     * Gets student data
     * Reloads UITableView
     * Uses DispatchGroup to wait for Firebase Firestore to get all data
     */
    func getStudent(studentRef: DocumentReference, group: DispatchGroup) {
        studentRef.getDocument { (snap, error) in // Gets student
            if (error == nil && snap!.exists) { // Checks that there is no error and that data exists
                let student = Student2(uid: snap!.documentID, fullName: snap!.data()!["fullName"] as? String, username: snap!.data()!["username"] as? String, bio: snap!.data()!["bio"] as? String, facebook: snap!.data()!["facebookLink"] as? String, twitter: snap!.data()!["twitterLink"] as? String, instagram: snap!.data()!["instagramLink"] as? String, snapchat: snap!.data()!["snapchatLink"] as? String, ref: snap!.reference, school: School(city: nil, coordinates: nil, countryCode: nil, name: nil, postalCode: nil, state: nil, ref: snap!.data()!["school"] as? DocumentReference)) // Creates a new student object
                self.students.append(student) // Adds the Student to the student list
            }
            group.leave()
        }
    }
    
    /*
     * Gets student's profile image
     * Reloads student's UITableViewCell
     */
    func getStudentProfileImages() {
        for student in self.students { // Loops through each student to get profile image
            storageReference.child("users").child("profilePictures").child(student.getUID()! + "profilePicture").getData(maxSize: 1 * 1024 * 1024) { (data, error) in // Gets profile image
                if (error == nil && data != nil) { // Checks that there is no error and that data exists
                    if let image = UIImage(data: data!) { // Tries to convert data into UIImage
                        student.setProfileImage(image: image)
                    } else { // UIImage could not be created
                        student.setProfileImage(image: #imageLiteral(resourceName: "Snapchat"))
                    }
                } else { // An error exists or data does not exist
                    student.setProfileImage(image: #imageLiteral(resourceName: "Snapchat"))
                }
                if (self.segmentedControlValue == 1) { // Checks if segmented control is still on students
                    self.displayStudentProfileImage(student: student)
                }
            }
        }
    }
    
    /*
     * Gets the index of the Student
     * Reloads the row (index) of the TableView
     * Looks in section 1 (section 0 only holds course info)
     */
    func displayStudentProfileImage(student: Student2) {
        let row = self.students.index(of: student)
        self.tableView.reloadRows(at: [IndexPath(row: row!, section: 1)], with: .none)
    }
    
    // MARK: Download Instructor Data
    /*
     * Checks network connection
     * Reloads tableView with loading cell
     * Downloads course instructors
     * Uses DispatchGroup to wait for Firebase Firestore to get all data
     */
    func getInstructorRefs() {
        if (self.checkNetwork() == true) { // Checks for an active network connection
            // Reloads tableView with loading cell
            self.instructorsAreLoading = true
            self.tableView.reloadData()
            if let courseRef = self.course.getRef() { // Tries to get course ref
                courseRef.collection("instructors").getDocuments(completion: { (snap, error) in // Gets instructors
                    if let error = error { // Checks if there is an error
                        self.displayError(title: "Error", message: error.localizedDescription)
                        self.instructorsAreDownloaded = false
                        self.instructorsAreLoading = false
                        if (self.segmentedControlValue == 2) { // Checks if segmented control is still on instructors
                            self.reloadData()
                        }
                    } else { // No error
                        let group = DispatchGroup()
                        for instructor in snap!.documents { // Loops through instructors to get instructor refs
                            if let instructorRef = instructor.data()["instructorRef"] as? DocumentReference { // Tries to get instructor ref
                                group.enter()
                                self.getInstructor(deptInstructorRef: instructorRef, group: group)
                            }
                        }
                        group.notify(queue: .main, execute: {
                            self.instructorsAreDownloaded = true
                            self.instructorsAreLoading = false
                            if (self.segmentedControlValue == 2) { // Checks if segmented control is still on instructors
                                self.reloadData()
                            }
                        })
                    }
                })
            } else {
                self.instructorsAreDownloaded = false
                self.instructorsAreLoading = false
                if (self.segmentedControlValue == 2) { // Checks if segmented control is still on instructors
                    self.reloadData()
                }
            }
        }
    }
    
    /*
     * Downloads instructor
     * Adds instructor to instructors list
     */
    func getInstructor(deptInstructorRef: DocumentReference, group: DispatchGroup) {
        deptInstructorRef.getDocument { (snap, error) in
            if (error == nil && snap!.exists){ // Checks for no error and data exists
                self.instructors.append(Instructor2(uid: deptInstructorRef.documentID, name: snap!.data()!["name"] as? String, ref: deptInstructorRef))
            }
            group.leave()
        }
    }
    
    // UITableViewCell Buttons
    /*
     * Gets the selected row
     * Segues to StudentInfoTVC
     */
    @objc func profileTapped(recognizer: UITapGestureRecognizer) {
        self.profileGestureRecognizerUsed = true
        self.currentRow = recognizer.view!.tag
        self.performSegue(withIdentifier: "courseInfoTVCToStudentInfoTVCSegue", sender: self)
    }
    
    /*
     * Gets the selected row
     * Segues to PostInfoTVC
     */
    @objc func newComment(sender: UIButton) {
        self.currentRow = sender.tag
//        self.performSegue(withIdentifier: "courseInfoTVCToPostInfoTVCSegue", sender: self)
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
//        self.performSegue(withIdentifier: "courseInfoTVCToPostInteractionTVCSegue", sender: self)
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
     * Creates attributed string with course name and instructor name
     */
    func getCourseInfo() -> NSAttributedString? {
        var infoAdded = Bool()
        let info = NSMutableAttributedString()
        if let courseName = self.course.getName() { // Tries to get course name
            info.append(newAttributedString(string: courseName, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 15))
            infoAdded = true
        }
        if let instructorName = self.course.getInstructor()?.getName() { // Tries to get instructor name
            info.append(newAttributedString(string: "\n" + instructorName, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFont.Weight.regular, paragraphSpacing: 15))
            infoAdded = true
        }
        if (infoAdded) { // Info found
            return info
        } else { // Info not found
            return nil
        }
    }
    
    /*
     * Creates attributed string with student's full name and username
     */
    func getStudentInfo(student: Student2, usernameParagraphSpacing: CGFloat) -> NSMutableAttributedString? {
        // Gets font size
        var fontSize1 = CGFloat()
        var fontSize2 = CGFloat()
        if (self.segmentedControlValue == 0) { // Corresponds to "posts"
            fontSize1 = 15
            fontSize2 = 12
        } else { // Corresponds to "students"
            fontSize1 = 17
            fontSize2 = 13
        }
        var infoAdded = Bool()
        let info = NSMutableAttributedString()
        if let fullName = student.getFullName() { // Tries to get full name
           info.append(newAttributedString(string: fullName, color: .black, stringAlignment: .natural, fontSize: fontSize1, fontWeight: .bold, paragraphSpacing: 11))
            infoAdded = true
        }
        if let username = student.getUsername() { // Tries to get username
            info.append(newAttributedString(string: "\n" + username, color: .black, stringAlignment: .natural, fontSize: fontSize2, fontWeight: .regular, paragraphSpacing: usernameParagraphSpacing))
            infoAdded = true
        }
        if (infoAdded) { // Info found
            return info
        } else { // Info not found
            return nil
        }
    }
    
    /*
     * Adds bio to attributed string
     */
    func getProfileText(student: Student2) -> NSAttributedString? {
        if let info = self.getStudentInfo(student: student, usernameParagraphSpacing: 11) { // Tries to get student info and bio
            if let bio = student.getBio() {
                info.append(newAttributedString(string: "\n" + bio, color: .black, stringAlignment: .natural, fontSize: 20, fontWeight: .light, paragraphSpacing: 0))
            }
            return info
        } else { // Info and/or bio not fount
            return nil
        }
    }
    
    /*
     * Creates attributed string with instructor name for instructor cell
     */
    func getInstructorInfo(instructor: Instructor2) -> NSAttributedString? {
        if let name = instructor.getName() { // Tries to get instructor name
            return newAttributedString(string: name, color: .black, stringAlignment: .natural, fontSize: 25, fontWeight: .medium, paragraphSpacing: 10)
        } else { // Instructor name not found
            return nil
        }
    }
    
    // MARK: Set up UITableViewCells
    /*
     * Sets up course info text view
     */
    func setUpCourseInfoCell(cell: CourseInfoDetailsCell) {
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = self.getCourseInfo()
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
    func setUpPostCell(cell: CourseInfoPostCell, row: Int) {
        let post = self.posts[row]
        // Sets up text
        self.setUpTextView(textView: cell.userInfoTextView)
        self.setUpTextView(textView: cell.postTextView)
        if let student = post.getStudent() { // Tries to get student
            cell.userInfoTextView.attributedText = self.getStudentInfo(student: student, usernameParagraphSpacing: 0)
        }
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
        cell.userInfoTextView.tag = row
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
        // Sets up GestureRecognizers for profileImageView and profileTextView
        let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
        cell.profileImageView.addGestureRecognizer(profileImageGestureRecognizer)
        let profileTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
        cell.userInfoTextView.addGestureRecognizer(profileTextViewGestureRecognizer)
    }
    
    /*
     * Gets student
     * Sets up UITextViews
     * Sets up options button
     */
    func setUpStudentCell(cell: CourseInfoStudentCell, row: Int) {
        let student = self.students[row]
        // Sets up text
        self.setUpTextView(textView: cell.profileTextView)
        if let text = self.getProfileText(student: student) {
            cell.profileTextView.attributedText = text
        } else {
            cell.profileTextView.attributedText = newAttributedString(string: "Error", color: .black, stringAlignment: .natural, fontSize: 25, fontWeight: .medium, paragraphSpacing: 0)
        }
        if let profileImage = student.getProfileImage() { // Tries to get student's profile image
            cell.profileImageView.image = profileImage
        }
        // Sets up options button
        if let studentUID = student.getUID(), let userUID = currentUser?.uid { // Tries to get student uid and current user uid
            if (studentUID != userUID) { // Checks if the student is the current user
                cell.optionsButton.tag = row
                cell.optionsButton.addTarget(self, action: #selector(self.optionsButtonPressed(sender:)), for: .touchUpInside)
                return
            }
        }
        cell.optionsButton.isHidden = true // Cant get uids or student is not current user
    }
    
    func setUpInstructorCell(cell: CourseInfoInstructorCell, row: Int) {
        self.setUpTextView(textView: cell.textView)
        let instructor = self.instructors[row]
        cell.textView.attributedText = self.getInstructorInfo(instructor: instructor)
    }
    
    // MARK: UITableView
    /*
     * Returns number of sections (always 2)
     * Section 0 is the course info details cell
     * Section 1 includes post info cells
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    /*
     * Sets up a segmented control as the section 1 header
     */
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1) { // Only adds header to section 1
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "segmentedControlHeaderView") as! SegmentedControlHeaderView
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
        if (section == 0) { // Only one cell (course info)
            return 1
        } else if (self.segmentedControlValue == 0) { // Post cells
            if (self.postsAreLoading) { // Checks if posts are loading
                return 1
            } else if (self.posts.count > 0) { // Checks if posts exist
                return self.posts.count
            } else { // No posts exist
                return 1
            }
        } else if (self.segmentedControlValue == 1) { // Student cells
            if (self.studentsAreLoading) { // Checks if students are loading
                return 1
            } else if (self.students.count > 0) { // Checks if students exist
                return self.students.count
            } else { // No students exist
                return 1
            }
        } else { // Instructor cells
            if (self.instructorsAreLoading) { // Checks if instructors are loading
                return 1
            } else if (self.instructors.count > 0) { // Checks if instructors exist
                return self.instructors.count
            } else { // No instructors exist
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
        if (indexPath.section == 0) { // Sets up CourseInfoDetailsCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoDetailsCell", for: indexPath) as! CourseInfoDetailsCell // Dequeues new CourseInfoDetailsCell
            self.setUpCourseInfoCell(cell: cell)
            return cell
        } else if (self.segmentedControlValue == 0) { // Sets up post cell
            if (self.postsAreLoading) { // Checks if posts are loading
                return tableView.dequeueReusableCell(withIdentifier: "courseInfoLoadingCell", for: indexPath) as! CourseInfoLoadingCell // Dequeues new CourseInfoLoadingCell
            } else if (self.posts.count > 0) { // Checks if posts exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoPostCell", for: indexPath) as! CourseInfoPostCell
                self.setUpPostCell(cell: cell, row: indexPath.row)
                return cell
            } else { // No posts exist -> Sets up empty data set cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoEmptyDataSetCell", for: indexPath) as! CourseInfoEmptyDataSetCell
                self.setUpEmptyDataSet(cell: cell, title: "Posts", description: "There aren't any posts in this class", image: #imageLiteral(resourceName: "Posts"))
                return cell
            }
        } else if (self.segmentedControlValue == 1) { // Sets up student cell
            if (self.studentsAreLoading) { // Checks if students are loading
                return tableView.dequeueReusableCell(withIdentifier: "courseInfoLoadingCell", for: indexPath) as! CourseInfoLoadingCell // Dequeues new CourseInfoLoadingCell
            } else if (self.students.count > 0) { // Checks if any students exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoStudentCell", for: indexPath) as! CourseInfoStudentCell
                self.setUpStudentCell(cell: cell, row: indexPath.row)
                return cell
            } else { // No students exist -> Sets up empty data set cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoEmptyDataSetCell", for: indexPath) as! CourseInfoEmptyDataSetCell
                self.setUpEmptyDataSet(cell: cell, title: "Students", description: "There aren't any students in this class", image: #imageLiteral(resourceName: "Students"))
                return cell
            }
        } else { // Sets up Instructor cell
            if (self.instructorsAreLoading == true) { // Checks if instructors are loading
                return tableView.dequeueReusableCell(withIdentifier: "courseInfoLoadingCell", for: indexPath) as! CourseInfoLoadingCell // Dequeues new CourseInfoLoadingCell
            } else if (self.instructors.count > 0) { // Checks if any instructors exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoInstructorCell", for: indexPath) as! CourseInfoInstructorCell
                self.setUpInstructorCell(cell: cell, row: indexPath.row)
                return cell
            } else { // No students exist -> Sets up empty data set cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoEmptyDataSetCell", for: indexPath) as! CourseInfoEmptyDataSetCell
                self.setUpEmptyDataSet(cell: cell, title: "Instructors", description: "There aren't any instructors in this class", image: #imageLiteral(resourceName: "Students"))
                return cell
            }
        }
    }
    
    /*
     * Handles a selected UITableView cell
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentRow = -10 // Sentinel value
        if (self.segmentedControlValue == 0) { // Segues to PostInfoTVC
//            self.performSegue(withIdentifier: "courseInfoTVCToPostInfoTVCSegue", sender: self)
        } else if (self.segmentedControlValue == 1) { // Segues to StudentInfoTVC
            self.performSegue(withIdentifier: "courseInfoTVCToStudentInfoTVCSegue", sender: self)
        } else { // Segues to InstructorInfoTVC
            self.performSegue(withIdentifier: "courseInfoTVCToInstructorInfoTVCSegue", sender: self)
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseInfoPostImageCell", for: indexPath   ) as! CourseInfoPostImageCell // Dequeues new cell
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
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow // Gets selected row
        if (segue.identifier == "courseInfoTVCToPostInfoTVCSegue") {
//            let post: Post2
//            if (self.currentRow > -1) { // Uses currentRow to get post
//                post = self.posts[self.currentRow]
//            } else { // Uses indexPath.row to get post
//                post = self.posts[indexPath!.row]
//            }
//            (segue.destination as! PostInfoTVC).post = post // Sends post to PostInfoTVC
        } else if (segue.identifier == "courseInfoTVCToStudentInfoTVCSegue") {
            let student: Student2
            if (self.profileGestureRecognizerUsed == true) { // Gets Student from post list
                self.profileGestureRecognizerUsed = false // Resets value to false
                student = self.posts[self.currentRow].getStudent()!
            } else { // Gets Student from student list
                student = self.students[indexPath!.row]
            }
            (segue.destination as! StudentInfoTVC).student = student
        } else if (segue.identifier == "courseInfoTVCToPostInteractionTVCSegue") {
//            let post = self.posts[self.currentRow]
//            let destVC = segue.destination as! PostInteractionTVC
//            destVC.post = post
//            destVC.interaction = self.postInteraction
        } else if (segue.identifier == "courseInfoTVCToInstructorInfoTVCSegue") {
            let instructor = self.instructors[indexPath!.row]
            let destVC = segue.destination as! InstructorInfoTVC
            destVC.instructor = self.course.getInstructor()
            destVC.instructor = instructor
        }
    }
}
