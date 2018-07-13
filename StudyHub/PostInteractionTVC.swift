//
//  PostInteractionTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/27/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

class PostInteractionTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var post: Post?
    var students = [Student]()
    var loading = Bool()
    var interaction = String()
    var currentRow = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        self.getData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        if (self.checkNetwork() == true) {
            if (self.interaction == "likes") {
                self.getLikes()
            } else {
                self.getTaggedStudents()
            }
        }
    }
    
    func getLikes() {
        self.loading = true
        self.tableView.reloadData()
        databaseReference.child("coursePostLikes").child(self.post!.schoolUID).child(self.post!.departmentUID).child(self.post!.courseUID).child(self.post!.instructorUID).child(self.post!.uid).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount > 0) {
                let children = snap.children.allObjects as! [DataSnapshot]
                var data = [String: String]()
                for child in children {
                    data = child.value as! [String: String]
                    data["uid"] = child.key
                    let student = Student(data: data)
                    self.students.append(student)
                }
            }
            self.reloadData()
            self.getProfileImages()
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData()
        }
    }
    
    func getTaggedStudents() {
        self.loading = true
        self.tableView.reloadData()
        databaseReference.child("coursePostTaggedStudents").child(self.post!.schoolUID).child(self.post!.departmentUID).child(self.post!.courseUID).child(self.post!.instructorUID).child(self.post!.uid).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount > 0) {
                let children = snap.children.allObjects as! [DataSnapshot]
                var data = [String: String]()
                for child in children {
                    data = child.value as! [String: String]
                    data["uid"] = child.key
                    let student = Student(data: data)
                    self.students.append(student)
                }
            }
            self.reloadData()
            self.getProfileImages()
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData()
        }
    }
    
    func getProfileImages() {
        var count = Int()
        for student in self.students {
            storageReference.child("users").child("profileImages").child(student.uid + "profileImage").getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if (data != nil) {
                    if let image = UIImage(data: data!) {
                        student.setProfileImage(image: image)
                    }
                    let row = self.students.index(of: student)
                    if let row = row {
                        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                    }
                }
                count += 1
            }
        }
    }
    
    func reloadData() {
        self.loading = false
        self.tableView.reloadData()
    }
    
    @objc func messageButtonPressed(sender: UIButton) {
        self.currentRow = sender.tag
//        self.performSegue(withIdentifier: "postInteractionTVCToMessagesTVCSegue", sender: self)
    }
    
    func studentInfo(student: Student) -> NSAttributedString {
        let info = NSMutableAttributedString()
        info.append(newAttributedString(string: student.fullName, color: .white, stringAlignment: .natural, fontSize: 19, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
        info.append(newAttributedString(string: "\n" + student.username, color: .white, stringAlignment: .natural, fontSize: 17, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        return info
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if (self.interaction == "likes") {
            return self.emptyDataSetString(string: "Likes", fontSize: 25, fontWeight: UIFont.Weight.medium)
        } else {
            return self.emptyDataSetString(string: "Tagged Students", fontSize: 25, fontWeight: UIFont.Weight.medium)
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if (self.interaction == "likes") {
            return self.emptyDataSetString(string: "This post doesn't have any likes", fontSize: 20, fontWeight: UIFont.Weight.regular)
        } else {
            return self.emptyDataSetString(string: "This post doesn't have any tagged students", fontSize: 20, fontWeight: UIFont.Weight.regular)
        }
        
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if (self.interaction == "likes") {
            return #imageLiteral(resourceName: "Likes")
        } else {
            return #imageLiteral(resourceName: "Shares")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loading == true) {
            return 1
        } else {
            return self.students.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loading == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postInteractionLoadingCell", for: indexPath) as! PostInteractionLoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postInteractionStudentCell", for: indexPath) as! PostInteractionStudentCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: studyHubBlue)
            let student = self.students[indexPath.row]
            self.setUpTextView(textView: cell.profileTextView)
            cell.profileTextView.attributedText = self.studentInfo(student: student)
            self.setUpTextView(textView: cell.bioTextView)
            cell.bioTextView.text = student.bio
            cell.profileImageView.image = student.profileImage
            cell.messageButton.tag = indexPath.row
            cell.messageButton.addTarget(self, action: #selector(self.messageButtonPressed(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "postInteractionTVCToStudentInfoTVCSegue", sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let indexPath = self.tableView.indexPathForSelectedRow
//        if (segue.identifier == "postInteractionTVCToStudentInfoTVCSegue") {
//            let destVC = segue.destination as! StudentInfoTVC
//            destVC.student = self.students[indexPath!.row]
//        }
//    }
}
