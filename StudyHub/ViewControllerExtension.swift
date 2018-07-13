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
    
    // MARK: Alert Controllers
    func displaySuccess(title: String, message: String) {
        SCLAlertView().showSuccess(title, subTitle: message, closeButtonTitle: "Ok", duration: 0.0, colorStyle: 0x32CD32, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayError(title: String, message: String) {
        SCLAlertView().showError(title, subTitle: message, closeButtonTitle: "Ok", duration: 0.0, colorStyle: 0xFF0000, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayErrorWithActionAndSegue(title: String, message: String, buttonTitle: String, segue: String) {
        let alert = SCLAlertView()
        alert.addButton(buttonTitle) {
            self.performSegue(withIdentifier: segue, sender: self)
        }
        alert.showError(title, subTitle: message, closeButtonTitle: "Ok", duration: 0.0, colorStyle: 0xFF0000, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayErrorWithTwoActions(title: String, message: String, buttonTitle1: String, buttonTitle2: String, action1: Void, action2: Void) {
        let alert = SCLAlertView()
        alert.addButton(buttonTitle1) {
            action1
        }
        alert.addButton(buttonTitle2) { 
            action2
        }
        alert.showError(title, subTitle: message, closeButtonTitle: nil, duration: 0.0, colorStyle: 0xFF0000, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayErrorWithActionAndCloseButton(title: String, message: String, buttonTitle: String, action: Void, closeButtonTitle: String) {
        let alert = SCLAlertView()
        alert.addButton(buttonTitle) {
            action
        }
        alert.showError(title, subTitle: message, closeButtonTitle: closeButtonTitle, duration: 0.0, colorStyle: 0xFF0000, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayNotice(title: String, message: String) {
        SCLAlertView().showNotice(title, subTitle: message, closeButtonTitle: "Ok", duration: 0.0, colorStyle: 0x0099CC, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayNoticeWithTwoActions(title: String, message: String, firstButtonTitle: String, closeButtonTitle: String, action: @escaping () -> Void) {
        let alert = SCLAlertView()
        alert.addButton(firstButtonTitle) {
            action()
        }
        alert.showInfo(title, subTitle: message, closeButtonTitle: closeButtonTitle, duration: 0.0, colorStyle: 0x0099CC, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    
    func displayWarning(title: String, message: String) {
        SCLAlertView().showWarning(title, subTitle: message, closeButtonTitle: "Ok", duration: 0.0, colorStyle: 0xFF9900, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayInfo(title: String, message: String) {
        SCLAlertView().showInfo(title, subTitle: message, closeButtonTitle: "Ok", duration: 0.0, colorStyle: 0x0000FF, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    func displayBanner(title: String, subtitle: String, style: BannerStyle) {
        DispatchQueue.main.async {
            let banner = NotificationBanner(title: title, subtitle: subtitle, style: style, colors: CustomBannerColors())
            banner.show()
        }
    }
    
    // MARK: Banners
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
    
    
    
    func checkUsername(username: String, completion: @escaping (Int) -> ()) {
        if (UserDefaults.standard.value(forKey: "username") as? String == username) {
            completion(1)
        } else {
            databaseReference.child("users").queryOrdered(byChild: "userDetails/username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snap) in
                if (snap.children.allObjects.count > 0) {
                    completion(2)
                } else {
                    completion(3)
                }
            }, withCancel: { (error) in
                completion(2)
            })
        }
    }
    
    func setUpProgressHUD() -> MBProgressHUD {
        var progressHUD = MBProgressHUD()
        progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.customView = self.customProgressHUDView()
        progressHUD.mode = .customView
        progressHUD.label.text = "Loading"
        progressHUD.customView = self.customProgressHUDView()
        return progressHUD
    }
    
    func customProgressHUDView() -> UIView {
        let frame = CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: 37, height: 37)
        )
        let view = NVActivityIndicatorView(frame: frame, type: .orbit, color: studyHubBlue)
        view.startAnimating()
        return view
    }
    
    func checkUserDetails(action: @escaping () -> Void) {
        if (networkIsReachable == false) {
            self.displayNoNetworkConnection()
        } else if (currentUser?.uid == nil) {
            print("******** User not logged in")
        } else {
            action()
        }
    }
    
    func emptyDataSetString(string: String, fontSize:CGFloat, fontWeight: UIFontWeight) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        attributedString.append(attributedString.newAttributedString(string: string, color: .black, stringAlignment: .center, fontSize: fontSize, fontWeight: fontWeight, paragraphSpacing: 0))
        return attributedString
    }
    
    func checkStrings(strings: [String]) -> Bool {
        for data in strings {
            return false
        }
        return true
    }
    
    // VC Customizations
    func setUpNavBar(navItem: UINavigationItem, navController: UINavigationController) {
        navItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        navController.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpNavBarTitle(navItem: UINavigationItem, title: String, fallbackTitle: String) {
        if (title.characters.count > 0) {
            self.navigationItem.title = title
        } else {
            self.navigationItem.title = fallbackTitle
        }
    }
    
    func setUpTableView(tableView: UITableView) {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
    }
    
    func checkInfo() -> Bool {
        if (networkIsReachable == false) {
            self.displayNoNetworkConnection()
            return false
        } else if (currentUser == nil) {
            print("**** NO USER")
            return false
        } else {
            return true
        }
    }
    
    func setUpTextView(textView: UITextView) {
        textView.isUserInteractionEnabled = false;
        textView.textContainerInset = UIEdgeInsets.zero
    }
    
    // MARK: TVC Customizations
    func courseInfoEmptyDataSet(tableView: UITableView, indexPath: IndexPath, title: String, description: String, image: UIImage) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoEmptyDataSetCell", for: indexPath) as! CourseInfoEmptyDataSetCell
        let text = NSMutableAttributedString()
        text.append(text.newAttributedString(string: title, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFontWeightMedium, paragraphSpacing: 15))
        text.append(text.newAttributedString(string: "\n" + description, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFontWeightRegular, paragraphSpacing: 0))
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = text
        cell.largeImageView.image = image
        return cell
    }
    
    func instructorInfoEmptyDataSet(tableView: UITableView, indexPath: IndexPath, title: String, description: String, image: UIImage) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "instructorInfoEmptyDataSetCell", for: indexPath) as! InstructorInfoEmptyDataSetCell
        let text = NSMutableAttributedString()
        text.append(text.newAttributedString(string: title, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFontWeightMedium, paragraphSpacing: 15))
        text.append(text.newAttributedString(string: "\n" + description, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFontWeightRegular, paragraphSpacing: 0))
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = text
        cell.largeImageView.image = image
        return cell
    }
    
    func accountEmptyDataSet(tableView: UITableView, indexPath: IndexPath, title: String, description: String, image: UIImage) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountEmptyDataSetCell", for: indexPath) as! AccountEmptyDataSetCell
        let text = NSMutableAttributedString()
        text.append(text.newAttributedString(string: title, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFontWeightMedium, paragraphSpacing: 15))
        text.append(text.newAttributedString(string: "\n" + description, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFontWeightRegular, paragraphSpacing: 0))
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = text
        cell.largeImageView.image = image
        return cell
    }
}
