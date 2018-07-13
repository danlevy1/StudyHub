//
//  InstructorRatingVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/10/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import NVActivityIndicatorView

class InstructorRatingVC: UIViewController, UITextViewDelegate {
    
    // MARK: Variables
    var instructorUID = String()
    var selectedCourses = [Course]()
    var rating = "1"
    var chooseAgain = String()
    var progressHUD = MBProgressHUD()
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var reviewTextField: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var doneBatButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func ratingSliderValueDidChange(_ sender: Any) {
        self.changeStarColors()
    }
    
    @IBAction func yesButtonPressed(_ sender: Any) {
        self.chooseAgain = "true"
        self.buttonPressed(pressed: self.yesButton, changed: self.noButton)
    }
    
    @IBAction func noButtonPressed(_ sender: Any) {
        self.chooseAgain = "false"
        self.buttonPressed(pressed: self.noButton, changed: self.yesButton)
    }
    
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        self.checkData()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpTextView()
        self.setUpButton(button: self.yesButton)
        self.setUpButton(button: self.noButton)
        let starTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.ratingSliderTapped(gestureRecognizer:)))
        self.ratingSlider.addGestureRecognizer(starTapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpTextView() {
        self.reviewTextField.layer.cornerRadius = 10
        self.reviewTextField.clipsToBounds = true
        self.characterCountLabel.text = "500"
    }
    
    func setUpButton(button: UIButton) {
        button.layer.cornerRadius = button.frame.size.width / 2
        button.clipsToBounds = true
    }
    
    func ratingSliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        let positionOfSlider: CGPoint = self.ratingSlider.frame.origin
        let widthOfSlider: CGFloat = self.ratingSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(self.ratingSlider.maximumValue) / widthOfSlider)
        self.ratingSlider.setValue(Float(newValue), animated: false)
        self.changeStarColors()
    }
    
    func changeStarColors() {
        self.ratingSlider.value = ceilf(self.ratingSlider.value)
        if (self.ratingSlider.value < 1.5) {
            self.rating = "1"
            self.star1.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star2.image = #imageLiteral(resourceName: "Rating Star Inactive")
            self.star3.image = #imageLiteral(resourceName: "Rating Star Inactive")
            self.star4.image = #imageLiteral(resourceName: "Rating Star Inactive")
            self.star5.image = #imageLiteral(resourceName: "Rating Star Inactive")
        } else if (self.ratingSlider.value >= 1.5 && self.ratingSlider.value < 2.5) {
            self.rating = "2"
            self.star1.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star2.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star3.image = #imageLiteral(resourceName: "Rating Star Inactive")
            self.star4.image = #imageLiteral(resourceName: "Rating Star Inactive")
            self.star5.image = #imageLiteral(resourceName: "Rating Star Inactive")
        } else if (self.ratingSlider.value >= 2.5 && self.ratingSlider.value < 3.5) {
            self.rating = "3"
            self.star1.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star2.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star3.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star4.image = #imageLiteral(resourceName: "Rating Star Inactive")
            self.star5.image = #imageLiteral(resourceName: "Rating Star Inactive")
        } else if (self.ratingSlider.value >= 3.5 && self.ratingSlider.value < 4.5) {
            self.rating = "4"
            self.star1.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star2.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star3.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star4.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star5.image = #imageLiteral(resourceName: "Rating Star Inactive")
        } else {
            self.rating = "5"
            self.star1.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star2.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star3.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star4.image = #imageLiteral(resourceName: "Rating Star Active")
            self.star5.image = #imageLiteral(resourceName: "Rating Star Active")
        }
    }
    
    func buttonPressed(pressed: UIButton, changed: UIButton) {
        pressed.setTitleColor(studyHubGreen, for: .normal)
        pressed.layer.borderColor = studyHubGreen.cgColor
        pressed.layer.borderWidth = 3
        changed.setTitleColor(studyHubBlue, for: .normal)
        changed.layer.borderWidth = 0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = 500 - textView.text.characters.count
        if (count < 0) {
            self.characterCountLabel.textColor = .red
        } else {
            self.characterCountLabel.textColor = .white
        }
        self.characterCountLabel.text = String(count)
    }
    
    func checkData() {
        if (self.reviewTextField.text.characters.count > 500) {
            self.displayError(title: "Error", message: "Please limit your review to 500 characters or less")
        } else if (self.reviewTextField.text.characters.count < 10) {
            self.displayError(title: "Error", message: "Your review must be at least 10 characters long")
        } else if (self.chooseAgain.characters.count < 1) {
            self.displayError(title: "Error", message: "Please choose whether your would take this instructor again or not")
        } else {
            self.uploadReview()
        }
    }
    
    func uploadReview() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        var coursesTaken = String()
        var counter = Int()
        for course in self.selectedCourses {
            if (counter > 0) {
               coursesTaken.append(", " + course.id)
            } else {
                coursesTaken.append(course.id)
            }
            counter += 1
        }
//        let data = ["rating": self.rating, "review": self.reviewTextField.text, "chooseAgain": self.chooseAgain, "studentUID" : userData.uid, "coursesTaken": coursesTaken] as [String : Any]
        let data = ["rating": self.rating, "review": self.reviewTextField.text, "chooseAgain": self.chooseAgain, "coursesTaken": coursesTaken] as [String : Any]
        databaseReference.child("instructorRatings").child(thisUser!.schoolUID!).child(self.instructorUID).childByAutoId().updateChildValues(data) { (error, ref) in
            if (error != nil) {
                self.displayError(title: "Error", message: error!.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD, activityView: self.activityView!)
            } else {
                self.displayBanner(title: "Success!", subtitle: "Your rating has been uploaded", style: .success)
                self.stopProgressHUD(progressHUD: self.progressHUD, activityView: self.activityView!)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
