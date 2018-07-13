//
//  SelectDepartmentTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/23/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift

class SelectDepartmentTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: Variables
    var departments = [Departments]()
    var loadingDepartments = Bool()
    var dataDownloaded = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpTableView()
        
        self.checkData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func checkData() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else if (self.checkUser() == false) {
            print("** NO USER")
        } else {
//            self.getDepartments()
            self.reloadData()
        }
    }
    
//    func getDepartments() {
//        self.loadingDepartments = true
//        self.tableView.reloadData()
//        self.departments.removeAll(keepingCapacity: false)
//        if let schoolUID = UserDefaults.standard.string(forKey: "schoolUID") {
//            databaseReference.child("schoolDepartments").child(schoolUID).observe(.value, with: { (snap) in
//                if (snap.childrenCount >= 1) {
//                    let children = snap.children.allObjects as! [DataSnapshot]
//                    for child in children {
//                        var data = [String : String]()
//                        data = child.value as! [String : String]
//                        data["departmentUID"] = child.key
//                        let departments = Departments(data: data)
//                        self.departments.append(departments)
//                    }
//                    let departments = Departments(data: ["departmentName" : "Can't find your department?"])
//                    self.departments.append(departments)
//                }
//                self.reloadData()
//            }) { (error) in
//                self.displayError(title: "Error", message: error.localizedDescription)
//                self.reloadData()
//            }
//        }
//    }
    
    func reloadData() {
        self.loadingDepartments = false
        self.dataDownloaded = true
        self.tableView.reloadData()
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Departments")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: studyHubBlue]
        if let schoolName = UserDefaults.standard.string(forKey: "schoolName") {
            return NSAttributedString(string: schoolName + " Departments", attributes: attributes)
        } else {
            return NSAttributedString(string: "Departmets", attributes: attributes)
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: studyHubGreen]
        let text = "It looks like your school doesn't have any departments registered on StudyHub. Let's add a department now!"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "Add Department Button")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.performSegue(withIdentifier: "newDepartmentSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingDepartments == true) {
            return 1
        } else {
            return self.departments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loadingDepartments == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingSelectDepartmentCell", for: indexPath) as! LoadingSelectDepartmentTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let attributedText = NSMutableAttributedString()
            let cell = tableView.dequeueReusableCell(withIdentifier: "departmentsCell", for: indexPath) as! DepartmentsTableViewCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            let department = self.departments[indexPath.row]
            if (department.departmentNameAndCode.characters.count >= 1) {
                attributedText.append(NSAttributedString(string: department.departmentNameAndCode, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20), NSForegroundColorAttributeName: UIColor.black]))
                cell.departmentTextView.isUserInteractionEnabled = false
                cell.departmentTextView.attributedText = attributedText
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let department = self.departments[indexPath.row]
        if (department.departmentNameAndCode == "Can't find your department?") {
            self.performSegue(withIdentifier: "newDepartmentSegue", sender: self)
        } else if (department.departmentUID.characters.count >= 1 && department.departmentNameAndCode.characters.count >= 1) {
            self.performSegue(withIdentifier: "selectCourseSegue", sender: self)
        } else {
            self.displayError(title: "Error", message: "We can't find this department")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectCourseSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            let department = self.departments[indexPath!.row]
            let destVC = segue.destination as! SelectCourseTableViewController
            destVC.departmentCodeUID = department.departmentUID
            destVC.departmentCode = department.departmentNameAndCode
        } else {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! NewCourseViewController
        }
    }
}
