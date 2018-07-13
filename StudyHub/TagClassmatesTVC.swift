//
//  TagClassmatesTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/24/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

class TagClassmatesTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var course = Course2?
    var students = [Student2]()
    var loading = Bool()
    var selectedIndexPaths = [IndexPath]()
    var selectedStudents = [Student]()
    var changesMade = Bool()
    var presentingVC = UIViewController()
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        if (self.changesMade == true) {
            self.selectedStudents.removeAll(keepingCapacity: false)
        }
        for indexPath in self.selectedIndexPaths {
            self.selectedStudents.append(self.students[indexPath.row])
        }
        self.changesMade = false
        let destVC = self.presentingVC as! NewPostVC
        destVC.taggedStudentIndexPaths = self.selectedIndexPaths
        destVC.taggedStudents = self.selectedStudents
        destVC.students = self.students
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        if (self.students.count < 1) {
            self.getStudents()
        } else {
            self.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getStudents() {
        self.loading = true
        self.tableView.reloadData()
        self.students.removeAll(keepingCapacity: false)
        if (course!.departmentUID.count > 0 && course!.uid.count > 0 && course!.instructorUID.count > 0) {
            databaseReference.child("courseStudents").child("_").child(course!.departmentUID).child(course!.uid).child(course!.instructorUID).observeSingleEvent(of: .value, with: { (snap) in
                if (snap.childrenCount >= 1) {
                    let children = snap.children.allObjects as! [DataSnapshot]
                    for child in children {
                        var data = child.value as! [String : String]
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
        } else {
            self.reloadData()
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
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
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
                }
                count += 1
            }
        }
        //        self.getHeaderImages()
    }
    
    func reloadData() {
        self.loading = false
        self.tableView.reloadData()
        self.selectTaggedStudents()
    }
    
    func selectTaggedStudents() {
        for indexPath in self.selectedIndexPaths {
            let cell = tableView.cellForRow(at: indexPath) as! TagClassmatesClassmateCell
            cell.bgView.backgroundColor = studyHubGreen
        }
    }
    
    func studentInfo(student: Student) -> NSAttributedString {
        let info = NSMutableAttributedString()
        info.append(newAttributedString(string: student.fullName, color: .white, stringAlignment: .natural, fontSize: 19, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
        info.append(newAttributedString(string: "\n" + student.username, color: .white, stringAlignment: .natural, fontSize: 17, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        return info
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "Tag Classmates", fontSize: 25, fontWeight: UIFont.Weight.medium)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "There aren't any other students registered in \(self.course!.name)", fontSize: 20, fontWeight: UIFont.Weight.regular)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Students")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.loading == true) {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loading == true || (self.students.count > 0 && section == 0)) {
            return 1
        } else {
            return self.students.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagClassmatesInfoCell", for: indexPath) as! TagClassmatesInfoCell
            cell.textView.attributedText = newAttributedString(string: "Select any of your classmates to tag", color: UIColor.black, stringAlignment: .natural, fontSize: 20, fontWeight: UIFont.Weight.medium, paragraphSpacing: 0)
            return cell
        } else if (self.loading == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagClassmatesLoadingCell", for: indexPath) as! TagClassmatesLoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagClassmatesClassmateCell", for: indexPath) as! TagClassmatesClassmateCell
            let student = students[indexPath.row]
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: studyHubBlue)
            cell.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = self.studentInfo(student: student)
            cell.studentProfileImageView.image = student.profileImage
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.changesMade = true
        if (indexPath.section == 1) {
            let cell = tableView.cellForRow(at: indexPath) as! TagClassmatesClassmateCell
            if (cell.bgView.backgroundColor == studyHubBlue) {
                cell.bgView.backgroundColor = studyHubGreen
                self.selectedIndexPaths.append(indexPath)
            } else {
                cell.bgView.backgroundColor = studyHubBlue
                let position = self.selectedIndexPaths.index(of: indexPath)
                self.selectedIndexPaths.remove(at: position!)
            }
        }
    }
}
