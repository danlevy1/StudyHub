//
//  SectionDetailsTableViewController.swift
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

class SectionDetailsTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var course = Course(data: ["": ""])
    var section = Section(data: ["": ""])
    var posts = [Post]()
    var students = [Student]()
    var profileImages = [ProfileImage]()
    var postDataIsDownloaded = Bool()
    var studentDataIsDownloaded = Bool()
    var segmentedControlValue = Int()
    var refreshController = UIRefreshControl()
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpRefreshControl()
        self.chooseDataToDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSegmentValue(sender: UISegmentedControl) {
        self.segmentedControlValue = sender.selectedSegmentIndex
        self.chooseDataToDisplay()
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setUpRefreshControl() {
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func chooseDataToDisplay() {
        if (self.segmentedControlValue == 0) {
            if (self.postDataIsDownloaded == true) {
                self.tableView.reloadData()
            } else if (self.checkNetwork() == false) {
                self.displayNoNetworkConnection()
            } else if (self.checkUser() == false) {
                print("**** NO USER")
            } else {
                
            }
        } else {
            
        }
        
        
        
        
        
        
        
        if (self.segmentedControlValue == 0) {
            
            
            
            
            
            if (self.postDataDownloaded == true && self.refreshController.isRefreshing == false) {
                self.tableView.reloadData()
            } else {
                self.checkUserDetails(action: {
                    self.sectionPosts.removeAll(keepingCapacity: false)
                    self.getPostData()
                })
            }
        } else {
            if (self.studentDataDownloaded == true && self.refreshController.isRefreshing == false) {
                self.tableView.reloadData()
            } else {
                self.checkUserDetails(action: {
                    self.sectionStudents.removeAll(keepingCapacity: false)
                    self.getStudentData()
                })
            }
        }
    }
    
    func getPostData() {
        if (self.queryData["schoolUID"] != nil && self.queryData["departmentCodeUID"] != nil && self.queryData["courseUID"] != nil && self.queryData["sectionUID"] != nil) {
            if (self.queryData["schoolUID"]!.characters.count >= 1 && self.queryData["departmentCodeUID"]!.characters.count >= 1 && self.queryData["courseUID"]!.characters.count >= 1 && self.queryData["sectionUID"]!.characters.count >= 1) {
                self.loadingData = true
                self.tableView.reloadData()
                databaseReference.child("courseSectionPosts").child(self.queryData["schoolUID"]!).child(self.queryData["departmentCodeUID"]!).child(self.queryData["courseUID"]!).child(self.queryData["sectionUID"]!).observeSingleEvent(of: .value, with: { (snap) in
                    if (snap.exists() == true && snap.childrenCount >= 1) {
                        let children = snap.children.allObjects as! [DataSnapshot]
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
        if (self.queryData["schoolUID"] != nil && self.queryData["departmentCodeUID"] != nil && self.queryData["courseUID"] != nil && self.queryData["sectionUID"] != nil) {
            if (self.queryData["schoolUID"]!.characters.count >= 1 && self.queryData["departmentCodeUID"]!.characters.count >= 1 && self.queryData["courseUID"]!.characters.count >= 1 && self.queryData["sectionUID"]!.characters.count >= 1) {
                self.loadingData = true
                self.tableView.reloadData()
                databaseReference.child("courseSectionStudents").child(queryData["schoolUID"]!).child(queryData["departmentCodeUID"]!).child(queryData["courseUID"]!).child(queryData["sectionUID"]!).observeSingleEvent(of: .value, with: { (snap) in
                    if (snap.exists() == true && snap.childrenCount >= 1) {
                        let children = snap.children.allObjects as! [DataSnapshot]
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
                        self.studentDataDownloaded = true
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
            if (student.studentUID.characters.count >= 1) { // TODO: Use FirebaseUI to add image with less code
                storageReference.child("users").child("profilePictures").child(student.studentUID + "profilePicture").getData(maxSize: 1 * 256 * 256, completion: { (data, error) in
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
        if (self.refreshController.isRefreshing == true) {
            self.refreshController.endRefreshing()
        }
        self.loadingData = false
        if (dataType == "posts") {
            self.postDataDownloaded = true
        } else {
            self.studentDataDownloaded = true
        }
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1;
        } else {
            if (self.loadingData == true) {
                return 1
            } else if (self.segmentedControlValue == 0) {
                return self.sectionPosts.count
            } else {
                return min(self.sectionStudents.count, self.sectionStudentProfileImages.count)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1) {
            let header = tableView.dequeueReusableCell(withIdentifier: "sectionDetailsHeaderView") as! SectionDetailsHeaderTableViewCell
            header.segmentedControl.selectedSegmentIndex = self.segmentedControlValue
            header.segmentedControl.addTarget(self, action: #selector(self.getSegmentValue(sender:)), for: .valueChanged)
            return header
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        } else {
            return 45
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attributedText = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 15
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionOverviewCell", for: indexPath) as! SectionOverviewTableViewCell
            paragraphStyle.alignment = .center
            if (self.headerData["courseIDAndName"] != nil) {
                if (self.headerData["courseIDAndName"]!.characters.count >= 1) {
                    attributedText.append(NSAttributedString(string: self.headerData["courseIDAndName"]!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.black]))
                }
            }
            if (self.headerData["sectionNumberAndInstructorName"] != nil) {
                if (self.headerData["sectionNumberAndInstructorName"]!.characters.count >= 1) {
                    attributedText.append(NSAttributedString(string: "\n\(self.headerData["sectionNumberAndInstructorName"]!)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 23, weight: UIFontWeightLight),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.gray]))
                }
            }
            if (attributedText.length > 0) {
                cell.sectionOverviewTextView.attributedText = attributedText
            } else {
                cell.sectionOverviewTextView.text = "Sorry, no data found"
            }
            cell.sectionOverviewTextView.isUserInteractionEnabled = false
            return cell
        } else {
            if (loadingData == true) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingSectionDetailsCell", for: indexPath) as! LoadingSectionDataTableViewCell
                cell.loadingActivityIndicator.startAnimating()
                return cell
            } else if (self.segmentedControlValue == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sectionPostsCell", for: indexPath) as! SectionPostsTableViewCell
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
                let post = self.sectionPosts[indexPath.row]
                if (post.postUID.characters.count >= 1) {
                     attributedText.append(NSAttributedString(string: "\(post.postUID)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.black]))
                }
                if (post.postDate.characters.count >= 1) {
                    paragraphStyle.alignment = .left
                    attributedText.append(NSAttributedString(string: "\n\(post.postDate)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight), NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.lightGray]))
                }
                if (post.postText.characters.count >= 1) {
                    attributedText.append(NSAttributedString(string: "\n\(post.postText)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.gray]))
                }
                if (post.postUsernameAndName.characters.count >= 1) {
                    attributedText.append(NSAttributedString(string: post.postUsernameAndName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.gray]))
                }
                cell.postTextView.attributedText = attributedText
                cell.postTextView.isUserInteractionEnabled = false
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sectionStudentsCell", for: indexPath) as! SectionStudentsTableViewCell
                let student = self.sectionStudents[indexPath.row]
                let studentProfileImage = self.sectionStudentProfileImages[indexPath.row]
                if (student.studentUID == currentUser!.uid) {
                    cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: studyHubBlue)
                    if (student.studentName.characters.count >= 1) {
                        attributedText.append(NSAttributedString(string: student.studentName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.white]))
                    }
                    if (student.studentUsername.characters.count >= 1) {
                        attributedText.append(NSAttributedString(string: " • " + student.studentUsername, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 23, weight: UIFontWeightLight),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.white]))
                    }
                } else {
                    cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
                    if (student.studentName.characters.count >= 1) {
                        attributedText.append(NSAttributedString(string: student.studentName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.black]))
                    }
                    if (student.studentUsername.characters.count >= 1) {
                        attributedText.append(NSAttributedString(string: " • " + student.studentUsername, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 23, weight: UIFontWeightLight),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.gray]))
                    }
                }
                cell.studentInfoTextView.attributedText = attributedText
                if (student.studentUID.characters.count >= 1) {
                    cell.studentUID = student.studentUID
                }
                cell.studentProfileImageView.layer.cornerRadius = cell.studentProfileImageView.frame.size.width / 2
                cell.studentProfileImageView.layer.borderWidth = 1.0
                cell.studentProfileImageView.layer.borderColor = UIColor.white.cgColor
                cell.studentProfileImageView.clipsToBounds = true
                if (studentProfileImage.noImage != "true") {
                    cell.studentProfileImageView.image = studentProfileImage.studentProfileImage
                } else {
                    cell.studentProfileImageView.backgroundColor = UIColor.white
                }
                cell.studentInfoTextView.isUserInteractionEnabled = false
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = self.sectionStudents[indexPath.row]
        if (student.studentUID.characters.count >= 1) {
            self.performSegue(withIdentifier: "studentFromSectionDetailsVCSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "studentFromSectionDetailsVCSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            let student = self.sectionStudents[indexPath!.row]
            let destVC = segue.destination as! StudentTableViewController
            destVC.studentUID = student.studentUID
        }
    }
}
