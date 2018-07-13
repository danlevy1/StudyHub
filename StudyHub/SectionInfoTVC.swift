//
//  SectionInfoTVC.swift
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

class SectionInfoTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var course = Course(data: ["": ""])
    var section = Section(data: ["": ""])
    var posts = [Post]()
    var students = [Student]()
    var postDataIsDownloaded = Bool()
    var studentDataIsDownloaded = Bool()
    var loading = Bool()
    var segmentedControlValue = Int()
    var refreshController = UIRefreshControl()
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpTableView()
//        self.setUpRefreshControl()
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
        self.navigationItem.title = "Section " + section.number
    }
    
    func setUpTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
//    func setUpRefreshControl() {
//
//    }
    
    func chooseDataToDisplay() {
        if (self.segmentedControlValue == 0) {
            if (self.checkData(bool: self.postDataIsDownloaded) == true) {
                self.getPostData()
            }
        } else {
            if (self.checkData(bool: self.studentDataIsDownloaded) == true) {
                self.getStudentData()
            }
        }
    }
    
    func checkData(bool: Bool) -> Bool {
        if (bool == true) {
            self.tableView.reloadData()
            return false
        } else if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
            return false
        } else if (self.checkUser() == false) {
            print("**** NO USER")
            return false
        } else {
            return true
        }
    }
    
    func getPostData() {
        self.loading = true
        self.tableView.reloadData()
        databaseReference.child("courseSectionPosts").child(UserDefaults.standard.value(forKey: "schoolUID") as! String).child(course.departmentUID).child(course.uid).child(section.uid).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount >= 1) {
                let children = snap.children.allObjects as! [DataSnapshot]
                var postData = [String: String]()
                for child in children {
                    postData = child.value as! [String: String]
                    postData["postUID"] = child.key
                    let post = Post(data: postData)
                    self.posts.append(post)
                }
            }
            self.reloadData(dataType: "posts")
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData(dataType: "posts")
        }
    }
    
    func getStudentData() {
        self.loading = true
        self.tableView.reloadData()
        databaseReference.child("courseSectionStudents").child(UserDefaults.standard.value(forKey: "schoolUID") as! String).child(course.departmentUID).child(course.uid).child(section.uid).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount >= 1) {
                let children = snap.children.allObjects as! [DataSnapshot]
                var studentData = [String: String]()
                for child in children {
                    studentData = child.value as! [String: String]
                    studentData["uid"] = child.key
                    let student = Student(data: studentData)
                    self.students.append(student)
                }
            }
            self.reloadData(dataType: "students")
            self.getProfileImages()
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData(dataType: "students")
        }
    }
    
    func getProfileImages() {
        var count = Int()
        for student in self.students {
            storageReference.child("users").child("profileImages").child(student.uid + "profileImage").getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if (data != nil) {
                    student.setProfileImage(image: UIImage(data: data!)!)
                    self.tableView.reloadRows(at: [IndexPath(item: count, section: 1)], with: .none)
                }
                count += 1
            }
        }
        self.getHeaderImages()
    }
    
    func getHeaderImages() {
        for student in self.students {
            storageReference.child("users").child("headerImages").child(student.uid + "headerImage").getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if (data != nil) {
                    student.setHeaderImage(image: UIImage(data: data!)!)
                }
            }
        }
    }
    
    func reloadData(dataType: String) {
        if (self.refreshController.isRefreshing == true) {
            self.refreshController.endRefreshing()
        }
        self.loading = false
        if (dataType == "posts") {
            self.postDataIsDownloaded = true
        } else {
            self.studentDataIsDownloaded = true
        }
        self.tableView.reloadData()
    }
    
    func setUpTextView(textView: UITextView) {
        textView.isUserInteractionEnabled = false;
        textView.textContainerInset = UIEdgeInsets.zero
    }
    
    func sectionInfo() -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        attributedString.append(attributedString.newAttributedString(string: self.course.name, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFontWeightBold, paragraphSpacing: 15))
        attributedString.append(attributedString.newAttributedString(string: "\n" + self.section.instructorName, color: .black, stringAlignment: .center, fontSize: 23, fontWeight: UIFontWeightRegular, paragraphSpacing: 15))
        attributedString.append(attributedString.newAttributedString(string: "\n" + self.section.schedule, color: .black, stringAlignment: .center, fontSize: 21, fontWeight: UIFontWeightLight, paragraphSpacing: 15))
        return attributedString
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1) {
            let header = tableView.dequeueReusableCell(withIdentifier: "sectionInfoControlCell") as! SectionInfoControlCell
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loading == true) {
            return 1
        } else if (section == 0) {
            return 1
        } else if (self.segmentedControlValue == 0) {
            return self.posts.count
        } else {
            return self.students.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionInfoDetailsCell", for: indexPath) as! SectionInfoDetailsCell
            self.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = self.sectionInfo()
            return cell
        } else if (self.loading == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionInfoLoadingCell", for: indexPath) as! SectionInfoLoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        } else if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionInfoDetailsCell", for: indexPath) as! SectionInfoDetailsCell
            self.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = self.sectionInfo()
            return cell
        } else if (self.segmentedControlValue == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionInfoPostsCell", for: indexPath) as! SectionInfoPostsCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionInfoStudentsCell", for: indexPath) as! SectionInfoStudentsCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            let student = self.students[indexPath.row]
            self.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = student.sectionStudentInfo
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.layoutIfNeeded()
            cell.profileImageView.image = student.profileImage
//            let blurEffect = UIBlurEffect(style: .dark)
//            let blurView = UIVisualEffectView(effect: blurEffect)
//            cell.profileImageView.addSubview(blurView)
            return cell
        }
    }
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let student = self.students[indexPath.row]
            if (student.uid.characters.count >= 1) {
                self.performSegue(withIdentifier: "sectionInfoTVCToStudentProfileTVCSegue", sender: self)
            } else {
                self.displayBanner(title: "Student not Found", subtitle: "We couldn't find this student", style: .danger)
            }
        }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == "sectionInfoTVCToStudentProfileTVCSegue") {
                let indexPath = tableView.indexPathForSelectedRow
                let student = self.students[indexPath!.row]
                let destVC = segue.destination as! StudentInfoTVC
                destVC.student = student
            }
        }
}
