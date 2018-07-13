//
//  ChangeSchoolVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/21/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import NVActivityIndicatorView
import SCLAlertView
import MapKit

class ChangeSchoolVC: UIViewController {
    
    // MARK: Variables
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var place: CLPlacemark?
    var numberOfSearches = Int()
    
    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: Actions
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if (searchBar.text!.characters.count > 0) {
            self.getLocation()
        } else {
            self.displayError(title: "Error", message: "Please search for your school using the search bar")
        }
    }
    
    func getLocation() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        CLGeocoder().geocodeAddressString(self.searchBar.text!) { (places, error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                let place = places?.first
                let annotation = MKPointAnnotation()
                annotation.coordinate = place!.location!.coordinate
                annotation.title = self.searchBar.text!
                let span = MKCoordinateSpanMake(0.005, 0.005)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                self.map.setRegion(region, animated: true)
                self.map.addAnnotation(annotation)
                self.map.selectAnnotation(annotation, animated: true)
                if (place != nil) {
                    self.place = place
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(4), execute: {
                        self.displayToUser()
                    })
                } else {
                    self.numberOfSearches += 1
                    self.schoolNotFound()
                }
            }
        }
    }
    
    func displayToUser() {
        var location = String()
        if let name = self.place!.name {
            location.append(name + " in ")
        }
        if let city = self.place!.locality {
            location.append(city + ", ")
        }
        if let state = self.place!.administrativeArea {
            location.append(state)
        }
        let appearance = SCLAlertView.SCLAppearance (
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Yes") {
            self.getSchool()
        }
        alert.addButton("No") {
            self.dismiss(animated: true, completion: nil)
            if (self.numberOfSearches > 2) {
                self.schoolNotFound()
            } else {
                if (self.numberOfSearches == 1) {
                    self.displayInfo(title: "Try Again", message: "Please try 1 more search")
                } else {
                    self.displayInfo(title: "Try Again", message: "Please try 2 more searches")
                }
                self.numberOfSearches += 1
            }
        }
        alert.showInfo("Is this Correct?", subTitle: location)
    }
    
    func schoolNotFound() {
        let appearance = SCLAlertView.SCLAppearance (
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Try Another Search") {
            self.getSchool()
        }
        alert.addButton("Send") {
            self.dismiss(animated: true, completion: nil)
        }
        alert.showEdit("Contact Support", subTitle: "Please type in your school's name, postal code, and country - then tap send. We will be in contact!")
    }
    
    func getSchool() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        databaseReference.child("schools").queryOrdered(byChild: "name").observeSingleEvent(of: .value, with: { (snap) in
            let childrenCount = snap.children.allObjects.count
            if (childrenCount > 1) {
                self.displayError(title: "Error", message: "Something went wrong. Support has been contacted and will get back to you!")
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else if (childrenCount > 0) {
                let child = snap.children.allObjects.first as! DataSnapshot
                let values = ["schoolName": child.children.value(forKey: "name"), "schoolUID": child.key]
                self.addSchoolToUser(values: values as! [String : String])
            } else {
                self.addSchoolToSchools()
            }
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        }
    }
    
    func addSchoolToSchools() {
        var values = [String: String]()
        if let name = self.place!.name {
            values["name"] = name
        }
        if let city = self.place!.locality {
            values["city"] = city
        }
        if let state = self.place!.administrativeArea {
            values["state"] = state
        }
        if let countryCode = self.place!.isoCountryCode {
            values["countryCode"] = countryCode
        }
        if let postalCode = self.place!.postalCode {
            values["postalCode"] = postalCode
        }
        if let latitude = self.place!.location?.coordinate.latitude {
            values["latitude"] = latitude
        }
        if let longitude = self.place!.location?.coordinate.longitude {
            values["longitude"] = longitude
        }
        databaseReference.child("schools").childByAutoId().updateChildValues(values) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                values["schoolName"] = values["name"]
                values["schoolUID"] = ref.key
                let keys = ["name", "city", "state", "countryCode", "postalCode"]
                for key in keys {
                    values.removeValue(forKey: key)
                }
                self.addSchoolToUser(values: values)
            }
        }
    }
    
    func addSchoolToUser(values: [String: String]) {
        if let uid = thisUser?.uid {
            databaseReference.child("users").child(uid).child("userDetails").updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else {
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                    self.displayBanner(title: "Success!", subtitle: "Your school has been changed", style: .success)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6), execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            })
        } else {
            self.displayError(title: "Error", message: "Something went wrong. Please try agian leter.")
        }
    }
}
