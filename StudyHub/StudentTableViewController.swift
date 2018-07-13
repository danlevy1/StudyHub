//
//  StudentTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 1/6/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift
import FirebaseStorageUI

class StudentTableViewController: UITableViewController {
    
    // MARK: Variables
    var studentUID = String()
    var segmentedControlValue = Int()
    var studentInfo = [StudentInfo]()
    var studentPosts = [StudentPosts]()
    var studentCourses = [StudentCourses]()
    var loadingStudentData = Bool()
    var loadingTableViewData = Bool()
    var studentDataDownloaded = Bool()
    var postDataDownloaded = Bool()
    var courseDataDownloaded = Bool()
    var refreshController = UIRefreshControl()
    
    // MARK: Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageBgView: UIView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usersSchoolNameButton: UIButton!
    @IBOutlet weak var socialAccountsLabel: UILabel!
    @IBOutlet weak var facebookLinkButton: UIButton!
    @IBOutlet weak var twitterLinkButton: UIButton!
    @IBOutlet weak var instagramLinkButton: UIButton!
    @IBOutlet weak var vscoButton: UIButton!
    
    // MARK: Actions
    @IBAction func usersSchoolNameButtonPressed(_ sender: Any) {
        if (studentInfo[0].schoolUID.characters.count < 1) {
            self.displayError(title: "Error", message: "We can't get this school right now")
        } else {
            self.performSegue(withIdentifier: "getSchoolFromStudentVCSegue", sender: self)
        }
    }
    @IBAction func facebookLinkButtonPressed(_ sender: Any) {
        self.sendUserToSocialLink(socialAccountLink: "https://www.facebook.com/" + self.studentInfo[0].facebookLink)
    }
    @IBAction func twitterLinkButtonPressed(_ sender: Any) {
        self.sendUserToSocialLink(socialAccountLink: "https://www.twitter.com/" + self.studentInfo[0].twitterLink)
    }
    @IBAction func instagramLinkButtonPressed(_ sender: Any) {
        self.sendUserToSocialLink(socialAccountLink: "https://www.instagram.com/" + self.studentInfo[0].instagramLink)
    }
    @IBAction func vscoLinkButtonPressed(_ sender: Any) {
        self.sendUserToSocialLink(socialAccountLink: "https://www.vsco.com/" + self.studentInfo[0].vscoLink)
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
        
        // Set up table view
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 103
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set up profile image view
        self.profileImageBgView.layer.cornerRadius = self.profileImageBgView.frame.size.width / 2
        self.profileImageBgView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
        
        // Set up hidden objects
        self.socialAccountsLabel.isHidden = true
        self.facebookLinkButton.isHidden = true
        self.instagramLinkButton.isHidden = true
        self.twitterLinkButton.isHidden = true
        self.vscoButton.isHidden = true
        
        // Reachability
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityStatusChanged), name: ReachabilityChangedNotification, object: reachability)
        
        // Set up Refresh Control
        refreshController = UIRefreshControl()
        refreshController.tintColor = studyHubBlue
        refreshController.addTarget(self, action: #selector(self.getData), for: .valueChanged)
        self.tableView.refreshControl = self.refreshController
        
        self.getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        self.chooseDataToGet()
        self.getStudentData()
    }
    
    func getSegmentValue(sender: UISegmentedControl) {
        self.segmentedControlValue = sender.selectedSegmentIndex
        self.chooseDataToGet()
    }
    
    func sendUserToSocialLink(socialAccountLink: String) {
        if (socialAccountLink.characters.count >= 1) {
            if (UIApplication.shared.canOpenURL(URL(string: socialAccountLink)!) == true) {
                UIApplication.shared.open(URL(string: socialAccountLink)!, options: [:], completionHandler: nil)
            } else {
                self.displayError(title: "Error", message: "We can't open this link")
            }
        } else {
            self.displayError(title: "Error", message: "We can't open this link")
        }
    }
    
    func chooseDataToGet() {
        if (self.segmentedControlValue == 0) {
            if (self.postDataDownloaded == true && self.refreshController.isRefreshing == false) {
                self.tableView.reloadData()
            } else {
                self.checkUserDetails(action: {
                    self.studentPosts.removeAll(keepingCapacity: false)
                    self.getStudentPosts()
                })
            }
        } else {
            if (self.courseDataDownloaded == true && self.refreshController.isRefreshing == false) {
                self.tableView.reloadData()
            } else {
                self.checkUserDetails(action: {
                    self.studentCourses.removeAll(keepingCapacity: false)
                    self.getStudentCourses()
                })
            }
        }
    }
    
    func getStudentData() {
        self.studentInfo.removeAll(keepingCapacity: false)
        self.loadingStudentData = true
        checkUserDetails(action: {
            if (self.studentUID.characters.count >= 1) {
                databaseReference.child("users").child(self.studentUID).child("userDetails").observeSingleEvent(of: .value, with: { (snap) in
                    if (snap.exists() == true && snap.childrenCount >= 1) {
                        let children = snap.children.allObjects as! [DataSnapshot]
                        var data = [String: String]()
                        for child in children {
                            data[child.key] = child.value as? String
                        }
                        let studentInfo = StudentInfo(data: data)
                        self.studentInfo.append(studentInfo)
                        self.getStudentPictures()
                    }
                }, withCancel: { (error) in
                    self.displayError(title: "Error", message: error.localizedDescription)
                })
            } else {
                self.displayError(title: "Error", message: "Please go back and try selecting this student again later")
            }
        })
    }
    
    func getStudentPictures() {
        let student = self.studentInfo[0]
        if (student.headerPictureURL.characters.count >= 1 && self.studentUID.characters.count >= 1) {
            self.headerImageView.sd_setImage(with: storageReference.child("Users").child("HeaderImages").child(self.studentUID + "HeaderPicture"))
            self.profileImageView.sd_setImage(with: storageReference.child("Users").child("ProfilePictures").child(self.studentUID + "ProfilePicture"))
        }
        self.loadingStudentData = false
        self.studentDataDownloaded = true
        self.displayStudentData()
    }
    
    func displayStudentData() {
        let student = self.studentInfo[0]
        if (student.username.characters.count >= 1) {
            self.navigationItem.title = student.username
        } else {
            self.navigationItem.title = "Student."
        }
        self.usersNameLabel.text = student.fullName
        self.usersSchoolNameButton.setTitle(student.schoolName, for: .normal)
        self.socialAccountsLabel.isHidden = false
        if (student.facebookLink.characters.count >= 1) {
            self.facebookLinkButton.isHidden = false
        }
        if (student.twitterLink.characters.count >= 1) {
            self.twitterLinkButton.isHidden = false
        }
        if (student.instagramLink.characters.count >= 1) {
            self.instagramLinkButton.isHidden = false
        }
        if (student.vscoLink.characters.count >= 1) {
            self.vscoButton.isHidden = false
        }
    }
    
    func getStudentPosts() {
        self.loadingTableViewData = true
        self.tableView.reloadData()
        databaseReference.child("users").child(self.studentUID).child("posts").observeSingleEvent(of: .value, with: { (snap) in
            if (snap.exists() == true && snap.childrenCount >= 1) {
                let children = snap.children.allObjects as! [DataSnapshot]
                for child in children {
                    var postData = [String: String]()
                    postData["uid"] = child.key
                    let studentPosts = StudentPosts(data: postData)
                    self.studentPosts.append(studentPosts)
                }
            }
            self.reloadData(dataType: "posts")
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData(dataType: "posts")
        }
    }
    
    func getStudentCourses () {
        databaseReference.child("users").child(self.studentUID).child("currentCourses").observeSingleEvent(of: .value, with: { (snap) in
            if (snap.exists() == true && snap.childrenCount >= 1) {
                let children = snap.children.allObjects as! [DataSnapshot]
                for child in children {
                    var courseData = child.value as! [String: String]
                    courseData["courseUID"] = child.key
                    let studentCourses = StudentCourses(data: courseData)
                    self.studentCourses.append(studentCourses)
                }
                self.reloadData(dataType: "courses")
            }
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData(dataType: "courses")
        }
    }
    
    func reloadData(dataType: String) {
        if (self.refreshController.isRefreshing == true) {
            self.refreshController.endRefreshing()
        }
        if (dataType == "posts") {
            self.postDataDownloaded = true
        } else {
            self.courseDataDownloaded = true
        }
        self.loadingTableViewData = false
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "studentHeaderViewCell") as! StudentHeaderTableViewCell
        header.segmentedControl.selectedSegmentIndex = self.segmentedControlValue
        header.segmentedControl.addTarget(self, action: #selector(self.getSegmentValue(sender:)), for: .valueChanged)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingTableViewData == true) {
            return 1
        } else if (self.segmentedControlValue == 0) {
            return self.studentPosts.count
        } else {
            return self.studentCourses.count
        }
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attributedText = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 20
        if (self.loadingTableViewData == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentLoadingDataCell", for: indexPath) as! StudentDataLoadingTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else if (self.segmentedControlValue == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentPostsCell", for: indexPath) as! StudentPostsTableViewCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentCoursesCell", for: indexPath) as! StudentCoursesTableViewCell
            let course = self.studentCourses[indexPath.row]
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            if (course.courseIdAndName.characters.count > 0) {
                attributedText.append(NSAttributedString(string: course.courseIdAndName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black]))
            }
            if (course.instructorName.characters.count > 0) {
                attributedText.append(NSAttributedString(string: "\n\(course.instructorName)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 23), NSForegroundColorAttributeName: UIColor.gray]))
            }
            cell.coursesTextView.isUserInteractionEnabled = false
            cell.coursesTextView.attributedText = attributedText
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = self.studentCourses[indexPath.row]
        if (self.loadingTableViewData == true) {
            // Do Nothing
        } else if (self.segmentedControlValue == 0) {
//            self.performSegue(withIdentifier: "getPostFromStudentVCSegue", sender: self) // TODO: Set up segue
        } else {
            if (course.departmentCodeUID.characters.count < 1 || course.courseUID.characters.count < 1) {
                self.displayError(title: "Error", message: "We can't get this course right now")
            } else {
                self.performSegue(withIdentifier: "getCourseFromStudentVCSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "getSchoolFromStudentVCSegue") {
            let destVC = segue.destination as! SchoolTableViewController
            destVC.schoolUID = self.studentInfo[0].schoolUID
        } else if (segue.identifier == "getPostFromStudentVCSegue") {
            // TODO: Set this up
        } else {
            let indexPath = self.tableView.indexPathForSelectedRow
            let course = self.studentCourses[indexPath!.row]
            let destVC = segue.destination as! CourseInfoTVC
//            destVC.departmentCodeUID = course.departmentCodeUID
//            destVC.courseUID = course.courseUID
        }
    }
    
    func reachabilityStatusChanged() {
        if (networkIsReachable == true) {
            self.displayNetworkReconnection()
            self.checkUserDetails(action: {
                if (self.studentDataDownloaded == false) {
                    self.getStudentData()
                }
                if (self.segmentedControlValue == 0 && self.postDataDownloaded == false) {
                    self.studentPosts.removeAll(keepingCapacity: false)
                    self.getStudentPosts()
                } else if (self.courseDataDownloaded == false) {
                    self.studentCourses.removeAll(keepingCapacity: false)
                    self.getStudentCourses()
                }
            })
        } else {
            self.displayNoNetworkConnection()
        }
    }
}
