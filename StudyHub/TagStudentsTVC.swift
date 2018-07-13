//
//  TagStudentsTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/24/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

/*
 * Allows user to select students to tag in their post
 * Tagged students only come from the same course and instructor as the post author
 */

class TagStudentsTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var course: Course2!
    var students = [Student2]()
    var isLoading = Bool()
    var selectedStudents = [Student2]()
    var presentingVC = UIViewController()
    
    // MARK: Actions
    /*
     * Dismisses the vc
     */
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Checks if students were tagged or un-tagged
     */
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        let destVC = self.presentingVC as! NewPostVC
        destVC.taggedStudents = self.selectedStudents
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Basics
    /*
     * Handles the initialization of the view controller
     * Checks if students have already been tagged
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        self.getStudents()
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Download Data
    /*
     * Gets student references from Firebase Firestore
     * Uses DispatchGroup to wait for data to be downloaded
     */
    func getStudents() {
        self.isLoading = true
        self.tableView.reloadData()
        if let instructorRef = self.course.getInstructor()?.getRef() { // Checks for instructor reference
            instructorRef.collection("students").getDocuments(completion: { (snap, error) in // Gets student references
                if let error = error {
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else {
                    self.students.removeAll(keepingCapacity: true) // Removes old students
                    let group = DispatchGroup()
                    for student in snap!.documents { // Loops through all students
                        print(student.data())
                        if let studentRef = student.data()["userRef"] as? DocumentReference, let uid = thisUser?.uid {
                            if (studentRef.documentID != uid) {
                                group.enter()
                                self.getStudent(studentRef: studentRef, group: group)
                            }
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.reloadData()
                        self.getProfileImages()
                    })
                }
            })
        } else { // Could not get student reference
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
    }
    
    /*
     * Gets student data
     * Creates a new Student and adds it to the students list
     */
    func getStudent(studentRef: DocumentReference, group: DispatchGroup) {
        studentRef.getDocument(completion: { (snap, error) in
            if (error == nil && snap!.exists) {
                self.students.append(Student2(uid: snap!.documentID, fullName: snap!.data()!["fullName"] as? String, username: snap!.data()!["username"] as? String, bio: snap!.data()!["bio"] as? String, facebook: snap!.data()!["facebookLink"] as? String, twitter: snap!.data()!["twitterLink"] as? String, instagram: snap!.data()!["instagramLink"] as? String, snapchat: snap!.data()!["snapchatLink"] as? String, ref: studentRef, school: School(city: nil, coordinates: nil, countryCode: nil, name: nil, postalCode: nil, state: nil, ref: snap!.data()!["schoolRef"] as? DocumentReference)))
            }
            group.leave()
        })
    }
    
    /*
     * Gets each student's profile image
     * Adds the image to the Student
     * Reloads the Student's cell
     * Uses DispatchGroup to wait for data to be downloaded
     */
    func getProfileImages() {
        let group = DispatchGroup()
        for student in self.students { // Loops through all students
            group.enter()
            if let studentUID = student.getUID() { // Tries to get studentUID
                storageReference.child("users").child("profileImages").child(studentUID).getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in // Gets profile image
                    if (error == nil && data != nil) {
                        if let image = UIImage(data: data!) { // Tries to turn data into image
                            student.setProfileImage(image: image)
                        }
                        if let row = self.students.index(of: student) { // Tries to get index of Student
                            self.tableView.reloadRows(at: [IndexPath(row: row, section: 1)], with: .none) // Reloads the cell
                        }
                    }
                    group.leave()
                })
            } else { // StudentUID not found
                group.leave()
            }
        }
    }
    
    // MARK: Empty Data Set
    /*
     * Returns image used for empty data set
     */
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Students")
    }
    
    /*
     * Returns title used for empty data set
     */
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "Tag Classmates", fontSize: 25, fontWeight: UIFont.Weight.medium)
    }
    
    /*
     * Returns description used for empty data set
     */
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "There aren't any other students in this course", fontSize: 20, fontWeight: UIFont.Weight.regular)
    }
    
    // MARK: UITableView Helper Methods
    /*
     * Sets isLoading to false
     * Reloads UITableView
     */
    func reloadData() {
        self.isLoading = false
        self.tableView.reloadData()
    }
    
    /*
     * Gets student full name and username
     */
    func studentInfo(student: Student2) -> NSAttributedString? {
        var infoAdded = Bool()
        let info = NSMutableAttributedString()
        if let fullName = student.getFullName() {
            info.append(newAttributedString(string: fullName, color: .white, stringAlignment: .natural, fontSize: 20, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
            infoAdded = true
        }
        if let username = student.getUsername() {
            info.append(newAttributedString(string: "\n" + username, color: .white, stringAlignment: .natural, fontSize: 15, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
            infoAdded = true
        }
        if (infoAdded) { // Checks that info was added
            return info
        } else { // Info was not added
            return nil
        }
    }
    
    // MARK: UITableView
    /*
     * Returns number of sections in UITableView
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.isLoading == true) {
            return 1
        } else {
            return 2
        }
    }
    
    /*
     * Returns number of rows in each section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isLoading == true || (self.students.count > 0 && section == 0)) {
            return 1
        } else {
            return self.students.count
        }
    }
    
    /*
     * Presents an info cell if there are Students
     * Presents a laoding cell if data is being downloaded
     * Presents students when they are downloaded
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.isLoading == true) { // Sets up TagStudentsLoadingCell
            return tableView.dequeueReusableCell(withIdentifier: "tagStudentsLoadingCell", for: indexPath) as! TagStudentsLoadingCell // Dequeues new cell
        } else if (indexPath.section == 0) { // Sets up TagStudentsInfoCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagStudentsInfoCell", for: indexPath) as! TagStudentsInfoCell // Dequeues new cell
            cell.textView.attributedText = newAttributedString(string: "Tap on students to tag them in your post", color: UIColor.black, stringAlignment: .natural, fontSize: 20, fontWeight: UIFont.Weight.medium, paragraphSpacing: 0)
            return cell
        } else { // Sets up TagStudentStudentCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagStudentsStudentCell", for: indexPath) as! TagStudentsStudentCell // Dequeues new cell
            let student = students[indexPath.row] // Gets student
            if (self.selectedStudents.index(of: student) != nil) { // Checks if Student is in selectedStudents list
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: studyHubGreen)
            } else { // Student is not in selectedStudents list
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: studyHubBlue)
            }
            // Sets up UITextView
            cell.setUpTextView(textView: cell.textView)
            if let studentInfo = self.studentInfo(student: student) { // Tries to get student info
                cell.textView.attributedText = studentInfo
            } else { // Student info not found
                cell.textView.attributedText = newAttributedString(string: "Error", color: .white, stringAlignment: .natural, fontSize: 20, fontWeight: .bold, paragraphSpacing: 0)
            }
            if let profileImage = student.getProfileImage() { // Tries to get profile image
                cell.studentProfileImageView.image = profileImage
            } else { // Could not get profile image
                cell.studentProfileImageView.image = #imageLiteral(resourceName: "Snapchat")
            }
            return cell
        }
    }
    
    /*
     * Sets changesMade to treu
     * Checks if the cell is currently selected or not
     * Adds or removes the Student from the selectedStudents list
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let student = self.students[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath) as! TagStudentsStudentCell
            if (cell.bgView.backgroundColor == studyHubBlue) { // Makes cell green and adds student from selectedStudents list
                cell.bgView.backgroundColor = studyHubGreen
                self.selectedStudents.append(student)
            } else { // Makes cell blue and removes student from selectedStudents list
                cell.bgView.backgroundColor = studyHubBlue
                if let index = self.selectedStudents.index(of: student) { // Tries to get index of Student
                    self.selectedStudents.remove(at: index)
                }
            }
        }
    }
}
