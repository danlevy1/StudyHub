//
//  InstructorCoursesTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/12/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class InstructorCoursesTVC: UITableViewController {
    
    // MARK: Variables
    var courses = [Course]()
    var selectedCourses = [Course]()
    var selectedIndexPaths = [Int]()
    var changesMade = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func nextBarButtinItemPressed(_ sender: Any) {
        if (self.changesMade == true) {
            self.selectedCourses.removeAll(keepingCapacity: false)
        }
        for indexPath in self.selectedIndexPaths {
            self.selectedCourses.append(self.courses[indexPath])
        }
        if (self.selectedCourses.count > 0) {
            self.changesMade = false
            self.performSegue(withIdentifier: "instructorCoursesTVCToInstructorRatingVCSegue", sender: self)
        } else {
            self.displayError(title: "Error", message: "Please select at least one course from the list before continuing")
        }
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpEmptyDataSetCellText() -> NSAttributedString {
        let info = NSMutableAttributedString()
        info.append(self.emptyDataSetString(string: "Instructor Courses", fontSize: 25, fontWeight: UIFontWeightMedium))
        info.append(self.emptyDataSetString(string: "There are no courses registered with this instructor. Add a course now!", fontSize: 25, fontWeight: UIFontWeightMedium))
        return info
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return self.courses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "instructorCourseInfoCell", for: indexPath) as! InstructorCourseInfoCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "instructorCoursesCourseCell", for: indexPath) as! InstructorCoursesCourseCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
            let course = courses[indexPath.row]
            self.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = course.selectCourseInfo
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.changesMade = true
        if (indexPath.section == 1) {
            let cell = tableView.cellForRow(at: indexPath) as! InstructorCoursesCourseCell
            if (cell.bgView.backgroundColor == .white) {
                cell.bgView.backgroundColor = studyHubGreen
                self.selectedIndexPaths.append(indexPath.row)
            } else {
                cell.bgView.backgroundColor = .white
                let position = self.selectedIndexPaths.index(of: indexPath.row)
                self.selectedIndexPaths.remove(at: position!)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "instructorCoursesTVCToInstructorRatingVCSegue") {
            let destVC = segue.destination as! InstructorRatingVC
            destVC.instructorUID = self.courses[0].instructorUID
            destVC.selectedCourses = self.selectedCourses
        }
    }

}
