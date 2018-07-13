//
//  AddSchoolTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 1/1/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import MBProgressHUD
import ReachabilitySwift

class AddSchoolTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchBarDelegate {
    // MARK: Variables
    var schools = [Schools]()
    var loadingSchools = Bool()
    var fromVC = String()
    var dismissVC = Bool()
    var searchBarButtonPressed = Bool()
    var progressHUD = MBProgressHUD()
    var schoolSelected = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var skipBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: Actions
    @IBAction func skipBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "successfulSignUpFromAddSchoolVCSegue", sender: self)
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.dismissVC == true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSchools() {
        schools.removeAll(keepingCapacity: false)
        databaseReference.child("schools").queryOrdered(byChild: "schoolNameLC").queryStarting(atValue: self.searchBar.text!.lowercased()).observeSingleEvent(of: .value, with: { (snap) in
            self.loadingSchools = true
            self.tableView.reloadData()
            if (snap.exists() == true) {
                let children = snap.children.allObjects as! [DataSnapshot]
                for child in children {
                    var data = child.value as! [String : String]
                    data["schoolUID"] = child.key
                    let schools = Schools(data: data)
                    self.schools.append(schools)
                }
                let schools = Schools(data: ["schoolName": "Can't find your school?"])
                self.schools.append(schools)
            }
            self.loadingSchools = false
            self.tableView.reloadData()
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.loadingSchools = false
            self.tableView.reloadData()
        }
    }
    
    func checkSearchBarDetails() {
        if (self.searchBar.text!.characters.count >= 1) {
            if (self.checkNetwork() == false) {
                self.displayNoNetworkConnection()
            } else {
                self.getSchools()
            }
        } else {
            self.displayError(title: "Error", message: "Please enter your school's full name in the search bar")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarButtonPressed = true
        self.checkSearchBarDetails()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if (searchBar.text?.characters.count == 0) {
            schools.removeAll(keepingCapacity: false)
            self.tableView.reloadData()
        }
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if (self.loadingSchools == false && self.schools.count < 1) {
            return true
        } else {
            return false
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.darkGray]
        if (self.searchBarButtonPressed == false) {
            let text = "Add your school now!"
             return NSAttributedString(string: text, attributes: attributes)
        } else {
            let text = "We couldn't find a school starting with '\(self.searchBar.text!)'"
             return NSAttributedString(string: text, attributes: attributes)
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.darkGray]
        if (self.searchBarButtonPressed == false) {
            let text = "Search for your school's full name above."
            return NSAttributedString(string: text, attributes: attributes)
        } else {
            let text = "Make sure the school name you are entering is the FULL name of your school!"
            return NSAttributedString(string: text, attributes: attributes)
        }
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.darkGray]
        let text = "I can't find my school"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        if (self.searchBarButtonPressed == true) {
            self.performSegue(withIdentifier: "newSchoolFromAddSchoolVCSegue", sender: self)
        } else {
            self.displayNotice(title: "Wait!", message: "Try searching for your school's full name before adding a new school")
        }
    }
    
    func addSchoolToUserDatabase(schoolName: String, schoolUID: String) {
        self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progressHUD.label.text = "Loading"
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(["schoolName": schoolName, "schoolUID": schoolUID]) { (error, ref) in
            if let error = error {
                self.progressHUD.hide(animated: true)
                self.displayError(title: "Error", message: error.localizedDescription)
            } else if (self.fromVC == "signUp") {
                self.progressHUD.hide(animated: true)
                self.performSegue(withIdentifier: "successfulSignUpFromAddSchoolVCSegue", sender: self)
            } else {
                self.progressHUD.hide(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingSchools == true) {
            return 1
        } else {
            return schools.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loadingSchools == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingSchoolsCell", for: indexPath) as! LoadingSchoolDataTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "schoolsCell", for: indexPath) as! AddSchoolTableViewCell
            let school = self.schools[indexPath.row]
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            let attributedText = NSMutableAttributedString()
            if (school.schoolName.characters.count > 0) {
                attributedText.append(NSAttributedString(string: school.schoolName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black]))
            } else {
                attributedText.append(NSAttributedString(string: "School Name not Found", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black]))
            }
            if (school.schoolLocation.characters.count > 0) {
                attributedText.append(NSAttributedString(string: "\n" + school.schoolLocation, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 23), NSForegroundColorAttributeName: UIColor.gray]))
            }
            cell.schoolDataTextView.isUserInteractionEnabled = false;
            cell.schoolDataTextView.textContainerInset = UIEdgeInsets.zero
            cell.schoolDataTextView.attributedText = attributedText
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let school = self.schools[indexPath.row]
        if (school.schoolName == "Can't find your school?") {
            self.performSegue(withIdentifier: "newSchoolFromAddSchoolVCSegue", sender: self)
        } else if (school.schoolName.characters.count > 0 && school.schoolUID.characters.count > 0) {
            if (self.checkNetwork() == false) {
                self.displayNoNetworkConnection()
            } else {
               self.addSchoolToUserDatabase(schoolName: school.schoolName, schoolUID: school.schoolUID)
            }
        } else {
            self.displayError(title: "Error", message: "Please try searching for your school and selecting it again")
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newSchoolFromAddSchoolVCSegue") {
            let navCon = segue.destination as! UINavigationController
            let destVC = navCon.topViewController as! NewSchoolViewController
            destVC.fromVC = "signUp"
        }
    }
}
