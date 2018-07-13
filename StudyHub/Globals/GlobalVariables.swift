//
//  GlobalVariables.swift
//  StudyHub
//
//  Created by Dan Levy on 7/19/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import Reachability

// Firebase
var currentUser = Auth.auth().currentUser
let databaseReference = Database.database().reference()
let firestoreRef = Firestore.firestore()
let storageReference = Storage.storage().reference()

// Colors
let studyHubBlue = UIColor(red: 0/255.0, green: 153/255.0, blue: 204/255.0, alpha: 100)
let studyHubGreen = UIColor(red: 0/255.0, green: 186/255.0, blue: 36/255.0, alpha: 100)
let studyHubLightGreen = UIColor(red: 143/255.0, green: 220/255.0, blue: 158/255.0, alpha: 100)
let facebookColor = UIColor(red: 59/255.0, green: 89/255.0, blue: 152/255.0, alpha: 100)
let twitterColor = UIColor(red: 29/255.0, green: 161/255.0, blue: 242/255.0, alpha: 100)
let snapchatColor = UIColor(red: 255/255.0, green: 252/255.0, blue: 0/255.0, alpha: 100)

// Reachability
var networkIsReachable = Bool()
let reachability = Reachability()

// Current User
let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
var thisUser: ThisUser?
