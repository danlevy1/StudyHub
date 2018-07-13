//
//  ViewControllerExtension.swift
//  StudyHub
//
//  Created by Dan Levy on 11/5/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import NVActivityIndicatorView
import NotificationBannerSwift

extension UIViewController {
    
    // MARK: Custom Alerts
    func displayError(title: String, message: String) {
        SCLAlertView().showError(title, subTitle: message, closeButtonTitle: "Ok", colorStyle: 0xFF0000, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayNotice(title: String, message: String) {
        SCLAlertView().showNotice(title, subTitle: message, closeButtonTitle: "Ok", colorStyle: 0x0099CC, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayInfo(title: String, message: String) {
        SCLAlertView().showInfo(title, subTitle: message, closeButtonTitle: "Ok", colorStyle: 0x0000FF, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    // MARK: Custom Banners
    func displayBanner(title: String, subtitle: String, style: BannerStyle) {
        DispatchQueue.main.async {
            let banner = NotificationBanner(title: title, subtitle: subtitle, style: style, colors: CustomBannerColors())
            banner.show()
        }
    }
    
    func displayNoNetworkConnection() {
        DispatchQueue.main.async {
            let banner = NotificationBanner(title: "Internet Connection", subtitle: "Please reconnect to the internet", style: .warning, colors: CustomBannerColors())
            banner.show()
        }
    }
    
    func displayNetworkReconnection() {
        DispatchQueue.main.async {
            let banner = NotificationBanner(title: "Internet Connection", subtitle: "You have been reconnected to the internet", style: .success)
            banner.show()
        }
    }
    
    func checkNetwork() -> Bool {
        if (networkIsReachable == false) {
            return false
        } else {
            return true
        }
    }
    
    func checkUser() -> Bool {
        if (currentUser == nil) {
            return false
        } else {
            return true
        }
    }
    
    // MARK: Check if user exists
    func userExists(completion: @escaping (Int) -> ()) {
        firestoreRef.collection("users").document(currentUser!.uid).getDocument { (snap, error) in
            if (error != nil) {
                completion(-1)
            } else if (snap!.exists) {
                completion(0)
            } else {
                completion(1)
            }
        }
    }
    
    // MARK: SignUp
//    func checkUsername(username: String, completion: @escaping (Bool) -> ()){
//        databaseReference.child("users").queryOrdered(byChild: "userDetails/username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snap) in
//            print(snap)
//            if (snap.children.allObjects.count > 0) {
//                print("CALL")
//                self.displayError(title: "Error", message: "This username already exists. Please try a different one.")
//                completion(false)
//            } else {
//                completion(true)
//            }
//        }, withCancel: { (error) in
//            self.displayError(title: "Error", message: "Soemthing went wrong. Please add your username another time.")
//            completion(false)
//        })
//    }
    
    // MARK: Custom Progress HUD
    func startProgressHUD(activityView: NVActivityIndicatorView, view: UIView) -> MBProgressHUD {
        let progHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progHUD.show(animated: true)
        progHUD.customView = activityView
        progHUD.mode = .customView
        progHUD.label.text = "Loading"
        activityView.startAnimating()
        return progHUD
    }
    
    func customProgressHUDView() -> NVActivityIndicatorView {
        let frame = CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: 37, height: 37)
        )
        let activityView = NVActivityIndicatorView(frame: frame, type: .ballSpinFadeLoader, color: studyHubBlue, padding: 0)
        activityView.frame = frame
        activityView.color = studyHubBlue
        return activityView
    }
    
    func stopProgressHUD(progressHUD: MBProgressHUD, activityView: NVActivityIndicatorView) {
        activityView.stopAnimating()
        progressHUD.hide(animated: true)
    }
    
    // MARK: Check User Details
    func checkInfo() -> Bool {
        if (networkIsReachable == false) {
            self.displayNoNetworkConnection()
            return false
        } else if (currentUser?.uid == nil) {
            print("******** User not logged in")
            return false
        } else {
            return true
        }
    }
    
    // MARK: Custom NSAttributedString
    func emptyDataSetString(string: String, fontSize:CGFloat, fontWeight: UIFont.Weight) -> NSAttributedString {
        return newAttributedString(string: string, color: .black, stringAlignment: .center, fontSize: fontSize, fontWeight: fontWeight, paragraphSpacing: 0)
    }
    
    // String
    func trimString(string: String) -> String {
        return string.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    // VC Customizations
    func setUpNavBar(navItem: UINavigationItem, navController: UINavigationController) {
        navItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        navController.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpTableView(tableView: UITableView) {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
    }
    
    func setUpTextView(textView: UITextView) {
        textView.isUserInteractionEnabled = false;
        textView.textContainerInset = UIEdgeInsets.init(top: 1, left: 0, bottom: 1, right: 0)
    }
}
