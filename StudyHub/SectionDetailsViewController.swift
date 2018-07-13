//
//  SectionDetailsViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift

class SectionDetailsViewController: UIViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Variables
    var headerData = [String: String]()
    var queryData = [String: String]()
    var sectionUID = String()
    var sectionPosts = [SectionPosts]()
    var sectionStudents = [SectionStudents]()
    var sectionStudentProfileImages = [SectionStudentProfileImages]()
    var getPostDataSuccessful = Bool()
    var getStudentDataSuccessful = Bool()
    var loadingData = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var courseIDAndNameLabel: UILabel!
    @IBOutlet weak var sectionNumberAndInstructorNameLabel: UILabel!
    @IBOutlet weak var tableViewSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func tableViewSegmentedControlValueChanged(_ sender: Any) {
        self.chooseDataToGet()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up header
        if (self.headerData["courseIDAndName"] != nil) {
            if (self.headerData["courseIDAndName"]!.characters.count >= 1) {
              self.courseIDAndNameLabel.text = self.headerData["courseIDAndName"]
            }
        }
        if (self.headerData["sectionNumberAndInstructorName"] != nil) {
            if (self.headerData["sectionNumberAndInstructorName"]!.characters.count >= 1) {
                self.sectionNumberAndInstructorNameLabel.text = self.headerData["sectionNumberAndInstructorName"]
            }
        }
        
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubColor
        
        // Set up table view
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Get data
        self.checkUserDetails(successMethod: self.getPostData())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func chooseDataToGet() {
        if (self.tableViewSegmentedControl.selectedSegmentIndex == 0) {
            if (getPostDataSuccessful == true) {
                self.tableView.reloadData()
            } else {
                self.checkUserDetails(successMethod: self.getPostData())
            }
        } else {
            if (getStudentDataSuccessful == true) {
                self.tableView.reloadData()
            } else {
                self.checkUserDetails(successMethod: self.getStudentData())
            }
        }
    }
    
    func getPostData() {
        self.loadingData = true
        self.tableView.reloadData()
        if (queryData["schoolUID"] != nil && queryData["departmentCodeUID"] != nil && queryData["courseUID"] != nil && queryData["sectionUID"] != nil) {
            if (queryData["schoolUID"]!.characters.count >= 1 && queryData["departmentCodeUID"]!.characters.count >= 1 && queryData["courseUID"]!.characters.count >= 1 && queryData["sectionUID"]!.characters.count >= 1) {
                databaseReference.child("CourseSectionPosts").child(queryData["schoolUID"]!).child(queryData["departmentCodeUID"]!).child(queryData["courseUID"]!).child(queryData["sectionUID"]!).observeSingleEvent(of: .value, with: { (snap) in
                    if (snap.exists() == true && snap.childrenCount >= 1) {
                        let children = snap.children.allObjects as! [FIRDataSnapshot]
                        for child in children {
                            var postData = [String: String]()
                            postData["postUID"] = child.key
                            postData = child.value as! [String: String]
                            let sectionPosts = SectionPosts(data: postData)
                            self.sectionPosts.append(sectionPosts)
                        }
                    }
                    self.reloadData(dataType: "posts")
                }) { (error) in
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.reloadData(dataType: "posts")
                }
            } else {
                self.displayError(title: "Error", message: "Please go back and try selecting this section lagain ater")
                self.reloadData(dataType: "posts")
                
            }
        } else {
            self.displayError(title: "Error", message: "Please go back and try selecting this section lagain ater")
            self.reloadData(dataType: "posts")
        }
    }
    
    func getStudentData() {
        if (queryData["schoolUID"] != nil && queryData["departmentCodeUID"] != nil && queryData["courseUID"] != nil && queryData["sectionUID"] != nil) {
            if (queryData["schoolUID"]!.characters.count >= 1 && queryData["departmentCodeUID"]!.characters.count >= 1 && queryData["courseUID"]!.characters.count >= 1 && queryData["sectionUID"]!.characters.count >= 1) {
                self.loadingData = true
                self.tableView.reloadData()
                databaseReference.child("CourseSectionStudents").child(queryData["schoolUID"]!).child(queryData["departmentCodeUID"]!).child(queryData["courseUID"]!).child(queryData["sectionUID"]!).observeSingleEvent(of: .value, with: { (snap) in
                    if (snap.exists() == true && snap.childrenCount >= 1) {
                        let children = snap.children.allObjects as! [FIRDataSnapshot]
                        for child in children {
                            if (child.key == currentUser!.uid) {
                                var studentData = [String: String]()
                                studentData = child.value as! [String: String]
                                studentData["studentUID"] = child.key
                                let sectionStudents = SectionStudents(data: studentData)
                                self.sectionStudents.append(sectionStudents)
                            }
                        }
                        for child in children {
                            if (child.key != currentUser!.uid) {
                                var studentData = [String: String]()
                                studentData = child.value as! [String: String]
                                studentData["studentUID"] = child.key
                                let sectionStudents = SectionStudents(data: studentData)
                                self.sectionStudents.append(sectionStudents)
                            }
                        }
                        self.getStudentProfileImages()
                    } else {
                        self.getStudentDataSuccessful = true
                        self.reloadData(dataType: "students")
                    }
                    
                }) { (error) in
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.reloadData(dataType: "students")
                }
            } else {
                self.displayError(title: "Error", message: "Please go back and try selecting this section lagain ater")
                self.reloadData(dataType: "students")
            }
        } else {
            self.displayError(title: "Error", message: "Please go back and try selecting this section lagain ater")
            self.reloadData(dataType: "students")
        }
    }
    
    func getStudentProfileImages() {
        var counter = Int()
        let counterMax = self.sectionStudents.count
        for student in self.sectionStudents {
            if (student.studentUID.characters.count >= 1) {
                storageReference.child("Users").child("ProfilePictures").child(student.studentUID + "ProfilePicture").data(withMaxSize: 1 * 256 * 256, completion: { (data, error) in
                    if (data != nil) {
                        let studentProfileImage = UIImage(data: data!)
                        let sectionStudentProfileImages = SectionStudentProfileImages(data: ["studentProfileImage": studentProfileImage!])
                        self.sectionStudentProfileImages.append(sectionStudentProfileImages)
                    } else {
                        let sectionStudentProfileImages = SectionStudentProfileImages(data: ["noStudentProfileImage": "true" as AnyObject])
                        self.sectionStudentProfileImages.append(sectionStudentProfileImages)
                    }
                    counter += 1
                    if (counter == counterMax) {
                        self.reloadData(dataType: "students")
                    }
                })
            }  else {
                let sectionStudentProfileImages = SectionStudentProfileImages(data: ["noStudentProfileImage": "true" as AnyObject])
                self.sectionStudentProfileImages.append(sectionStudentProfileImages)
                counter += 1
                if (counter == counterMax) {
                    self.reloadData(dataType: "students")
                }
            }
        }
    }
    
    func reloadData(dataType: String) {
        if (dataType == "posts") {
            self.getPostDataSuccessful = true
        } else {
            self.getStudentDataSuccessful = true
        }
        self.loadingData = false
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingData == true) {
            return 1
        } else if (self.tableViewSegmentedControl.selectedSegmentIndex == 0) {
            return self.sectionPosts.count
        } else {
            return min(self.sectionStudents.count, self.sectionStudentProfileImages.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (loadingData == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingDataCell", for: indexPath) as! LoadingSectionDataTableViewCell
            cell.loadingActivityIndicator.startAnimating()
            return cell
        } else if (self.tableViewSegmentedControl.selectedSegmentIndex == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postsCell", for: indexPath) as! SectionPostsTableViewCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            let post = self.sectionPosts[indexPath.row]
            if (post.postUID.characters.count >= 1) {
                cell.postUID = post.postUID
            }
            if (post.postDate.characters.count >= 1) {
                cell.postCreatedLabel.text = post.postDate
            }
            if (post.postText.characters.count >= 1) {
                cell.postTextLabel.text = post.postText
            }
            if (post.postUsernameAndName.characters.count >= 1) {
                cell.studentUsernameAndNameLabel.text = post.postUsernameAndName
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentsCell", for: indexPath) as! SectionStudentsTableViewCell
            let student = self.sectionStudents[indexPath.row]
            let studentProfileImage = self.sectionStudentProfileImages[indexPath.row]
            if (student.studentUID == currentUser!.uid) {
               cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: studyHubColor)
                cell.studentUsernameLabel.textColor = UIColor.white
                cell.studentNameLabel.textColor = UIColor.white
            } else {
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            }
            if (student.studentUsername.characters.count >= 1) {
                cell.studentUsernameLabel.text = student.studentUsername
            }
            if (student.studentName.characters.count >= 1) {
                cell.studentNameLabel.text = student.studentName
            }
            if (student.studentUID.characters.count >= 1) {
                cell.studentUID = student.studentUID
            }
            if (studentProfileImage.noImage != "true") {
                cell.studentProfileImageView.layer.cornerRadius = cell.studentProfileImageView.frame.size.width / 2
                cell.studentProfileImageView.layer.borderWidth = 0.7
                cell.studentProfileImageView.layer.borderColor = UIColor.white.cgColor
                cell.studentProfileImageView.clipsToBounds = true
                cell.studentProfileImageView.image = studentProfileImage.studentProfileImage
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
