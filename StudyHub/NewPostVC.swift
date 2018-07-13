//
//  NewPostVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/24/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Allows user to create a post
 * Posts can include text, up to five images, and tagged students
 * Posts are specified for a certain course
 */

import UIKit
import Firebase
import MBProgressHUD
import NVActivityIndicatorView
import SCLAlertView
import ImagePicker

class NewPostVC: UIViewController, UITextViewDelegate, ImagePickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Variables
    var course: Course2?
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var taggedStudentIndexPaths = [IndexPath]()
    var taggedStudents = [Student2]()
    let imagePicker = ImagePickerController()
    var imagesAdded = [UIImage]()
    var courses = [Course2]()
    
    // MARK: Outlets
    @IBOutlet weak var profileImageBGView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userDetailsTextView: UITextView!
    @IBOutlet weak var postTextTextView: UITextView!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var coursePicker: UIPickerView!
    
    // MARK: Actions
    /*
     * Dismisses vc
     */
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        //        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Checks that network is available
     */
    @IBAction func postBarButtonItemPressed(_ sender: Any) {
        if (self.checkNetwork() == true) {
            self.checkData()
        }
    }
    
    /*
     * Checks that a course has been selected
     * Segues to TagStudentsTVC
     */
    @IBAction func tagStudentsBarButtonItemPressed(_ sender: Any) {
        self.view.endEditing(true)
        if (self.course != nil) { // Checks that a user selected a course
            if let courseName = self.course?.getName() { // Tries to get the course name
                if (courseName != "Select Course") { // Checks that a course has been selected
                    self.performSegue(withIdentifier: "NewPostVCToTagStudentsTVCSegue", sender: self)
                    return
                }
            }
        }
        self.displayError(title: "Error", message: "Please select a course first") // Display error if any of the above fails
    }
    
    /*
     * Presents ImagePickerController
     */
    @IBAction func addImagesBarButtonItemPressed(_ sender: Any) {
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
        self.setUpImagePicker()
        self.getUserCourses()
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Dismisses keyboard on tap outside UITextView
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /*
     * Dismisses keyboard on scroll of UITextView
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    /*
     * Makes profile image a circle
     * Sets up user details
     * Sets up post text text view and keyboard toolbar
     */
    func setUpObjects() {
        // Makes profile image view and it's bg view a circle
        self.profileImageBGView.layer.cornerRadius = self.profileImageBGView.frame.height / 2
        self.profileImageBGView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
        if let profileImageData = thisUser!.profileImage { // Tries to get profile image
            self.profileImageView.image = UIImage(data: profileImageData as Data)
        } else { // No profile image found
            self.profileImageView.image = #imageLiteral(resourceName: "Snapchat")
        }
        self.setUpTextView(textView: self.userDetailsTextView)
        self.postTextTextView.textContainerInset = UIEdgeInsets.zero // Gets rid of edge insets
        // Gets user's full name and username
        let userDetails = NSMutableAttributedString()
        if (thisUser!.fullName != nil) {
            userDetails.append(newAttributedString(string: thisUser!.fullName!, color: .white, stringAlignment: .natural, fontSize: 20, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
        }
        if (thisUser!.fullName != nil) {
            userDetails.append(newAttributedString(string: "\n" + thisUser!.username!, color: .white, stringAlignment: .natural, fontSize: 15, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        }
        self.userDetailsTextView.attributedText = userDetails
        // Sets up keyboard toolbar
        self.keyboardToolbar.removeFromSuperview()
        self.postTextTextView.inputAccessoryView = self.keyboardToolbar
    }
    
    // MARK: Download Data
    /*
     * Downloads user's courses from Firebase Firestore
     * Uses DispatchGroup to wait for data to download
     */
    func getUserCourses() {
        // Presents loading component
        self.courses.append(Course2(uid: nil, id: nil, name: "Loading...", instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: nil, department: nil)) // Adds "loading" component
        self.coursePicker.reloadAllComponents()
        if let userRef = thisUser?.ref as? DocumentReference { // Checks that user ref exists
            userRef.collection("currentCourses").getDocuments(completion: { (snap, error) in // Gets course ref and instructor ref
                if (error == nil) {
                    self.courses[0] = Course2(uid: nil, id: nil, name: "Select Course", instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: nil, department: nil) // Changes "loading" component to "select course"
                    let group = DispatchGroup()
                    for course in snap!.documents { // Loops through all courses
                        if let courseRef = course.data()["courseRef"] as? DocumentReference, let instructorRef = course.data()["instructorRef"] as? DocumentReference { // Tries to get a course ref and an instructor ref
                            group.enter()
                            self.getCourse(courseRef: courseRef, instructorRef: instructorRef, group: group)
                        }
                    }
                    group.notify(queue: .main, execute: {
                        if (self.courses.count < 2) {
                            self.courses[0] = Course2(uid: nil, id: nil, name: "No Courses Found", instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: nil, department: nil) // Changes "select course" component to "no course found"
                        }
                        self.coursePicker.reloadAllComponents()
                    })
                }
            })
        } else { // User ref does not exist
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
            // TODO: Add dismiss on button tap
        }
    }
    
    /*
     * Downloads course from Firebase Firestore
     */
    func getCourse(courseRef: DocumentReference, instructorRef: DocumentReference, group: DispatchGroup) {
        courseRef.getDocument { (snap, error) in
            if (error == nil && snap!.exists) {
                let course = Course2(uid: snap!.documentID, id: snap!.data()!["id"] as? String, name: snap!.data()!["name"] as? String, instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: snap!.reference, department: Department2(uid: snap!.reference.parent.parent?.documentID, name: nil, ref: snap!.reference.parent.parent)) // Tries to get needed data
                self.courses.append(course)
                self.getInstructor(instructorRef: instructorRef, group: group, course: course)
            } else { // Data was not found
                group.leave()
            }
        }
    }
    
    /*
     * Downloads instructor from Firebase Firestore
     */
    func getInstructor(instructorRef: DocumentReference, group: DispatchGroup, course: Course2) {
        instructorRef.getDocument { (snap, error) in
            if (error == nil && snap!.exists) {
                course.setInstructor(instructor: Instructor2(uid: snap!.documentID, name: snap!.data()!["name"] as? String, ref: instructorRef))
            }
            group.leave()
        }
    }
    
    // MARK: ImagePicker
    /*
     * Allows user to select up to five images for the post
     */
    func setUpImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.imageLimit = 5
    }
    
    /*
     * Dismisses the picker controller
     * Removes old images and adds new images
     */
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: {
            self.imagesAdded.removeAll(keepingCapacity: false)
            for image in images {
                self.imagesAdded.append(image)
            }
        })
    }
    
    /*
     * Dismisses the picker controller
     */
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Ignore
     */
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    }
    
    // MARK: Upload Post
    /*
     * Checks that post has text (trimmed text)
     */
    func checkData() {
        if (self.postTextTextView.text!.count > 0) { // Checks that text exists
            self.addImagesToStorage()
        } else { // Text does not exist
            self.displayError(title: "Error", message: "Please add some text to your post")
        }
    }
    
    /*
     * Displays progress HUD
     * Uploads all post images to Firebase Storage
     * Uses DispatchGroup to wait for all data to upload
     */
    func addImagesToStorage() {
        let group = DispatchGroup()
        var imagePaths = [String]()
        var imageNumber = 0
        if let instructorRef = self.course?.getInstructor()?.getRef() { // Tries to get instructor ref
            self.activityView = self.customProgressHUDView()
            self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
            let postRef = instructorRef.collection("posts").document() // Creates new post ref
            for image in self.imagesAdded { // Loops through all images
                if let schoolUID = (thisUser?.school as? DocumentReference)?.documentID, let deptUID = self.course?.getRef()?.parent.parent?.documentID, let courseUID = self.course?.getUID(), let instructorUID = self.course?.getInstructor()?.getUID() { // Tries to get needed data
                    group.enter()
                    let imageRef = storageReference.child("schools").child(schoolUID).child("departments").child(deptUID).child("courses").child(courseUID).child("instructors").child(instructorUID).child("posts").child(postRef.documentID).child("image\(imageNumber)")
                    imageRef.putData(image.mediumQualityJPEGData, metadata: nil, completion: { (_, _) in // Uploads image
                        group.leave()
                        imagePaths.append(imageRef.fullPath)
                    })
                    imageNumber += 1
                } else { // Could not get data
                    break
                }
            }
            group.notify(queue: .main) {
                self.uploadPost(postRef: postRef, imagePaths: imagePaths)
            }
        } else {
            self.displayError(title: "Error", message: "Something went wrong. Please try again later")
        }
    }
    
    /*
     * Uploads post data Firebase Firestore
     */
    func uploadPost(postRef: DocumentReference, imagePaths: [String]) {
        if let userRef = thisUser?.ref as? DocumentReference {
            // Data to upload
            var data = ["text": self.postTextTextView.text!, "imagePaths": imagePaths, "userRef": userRef] as [String: Any]
            if (self.taggedStudents.count > 0) { // Only adds number of tagged students if there are any
                data["numTaggedStudents"] = self.taggedStudents.count
            }
            postRef.setData(data, completion: { (error) in // Uploads data
                if let error = error { // Checks for error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else { // No error found
                    self.uploadTaggedStudents(postRef: postRef)
                    return
                }
            })
        } else {
            self.displayError(title: "Error", message: "Something went wrong. Please try again later")
        }
    }
    
    /*
     * Uploads all tagged students
     * Uses DispatchGroup to wait for all data to upload
     */
    func uploadTaggedStudents(postRef: DocumentReference) {
        let group = DispatchGroup()
        for student in self.taggedStudents { // Loops through all tagged students
            if let uid = student.getUID(), let ref = student.getRef() { // Ties to get student uid and student ref
                group.enter()
                postRef.collection("taggedStudents").document(uid).setData(["studentRef": ref], completion: { (_) in // Uploads student
                    group.leave()
                })
            }
        }
        group.notify(queue: .main) {
            self.addPostToUserProfile(postRef: postRef)
        }
    }
    
    /*
     * Uploads post reference to user's profile
     */
    func addPostToUserProfile(postRef: DocumentReference) {
        if let ref = thisUser?.ref as? DocumentReference { // Tries to get user ref
            ref.collection("posts").document(ref.documentID).setData(["postRef": postRef], completion: { (error) in // Uploads post reference
                if let error = error { // Checks for error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else { // No error found
                    self.success()
                }
            })
        }
    }
    
    /*
     * Removes progress HUD
     * Displays success banner
     * Dismisses vc
     */
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.displayBanner(title: "Success", subtitle: "Your post has been uploaded", style: .success)
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6), execute: {
        //            self.dismiss(animated: true, completion: nil)
        //        })
    }
    
    // MARK: UIPickerView
    /*
     * Returns number of components in the UIPickerView
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
     * Returns height for each component
     * Only one component
     */
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    
    /*
     * Returns number of rows in each component
     * Only one component
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courses.count
    }
    
    /*
     * Returns the title for the row (course name)
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let name = self.courses[row].getName() { // Tries to get course name
            return name
        } else { // Course name not found
            return "Error"
        }
    }
    
    /*
     * Handles a row being selected in the UIPickerView
     * Sets Course to be the selected Course
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.course = self.courses[row]
    }
    
    // MARK: Segue
    /*
     * Passes data to the segued vc
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "NewPostVCToTagStudentsTVCSegue") { // Segue is to TagStudentsTVC
            let navController = segue.destination as! UINavigationController
            let destVC = navController.topViewController as! TagStudentsTVC
            destVC.course = self.course
            destVC.selectedStudents = self.taggedStudents
            destVC.presentingVC = self
        }
    }
}
