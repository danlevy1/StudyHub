//
//  ChangePasswordVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/17/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import TextFieldEffects

class ChangePasswordVC: UIViewController {
    
    // MARK: Variables
    var progressHUD = MBProgressHUD()
    
    // MARK: Outlets
    @IBOutlet weak var passwordTextField: HoshiTextField!
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
