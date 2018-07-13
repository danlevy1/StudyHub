//
//  CourseInformation.swift
//  StudyHub
//
//  Created by Dan Levy on 12/27/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import Foundation

class CourseInformation {
    private var _courseName = String()
    private var _courseID = String()
    private var _numberOfSectionsAndInstructors = String()
    private var _courseUpdatedOn = String()
    
    var courseName: String {
        return self._courseName
    }
    var courseID: String {
        return self._courseID
    }
    var numberOfSectionsAndInstructors: String {
        return self._numberOfSectionsAndInstructors
    }
    var courseUpdatedOn: String {
        return self._courseUpdatedOn
    }
    
    init(data: [String : String]) {
        if let courseName = data["courseName"] {
            return self._courseName
        }
        if let courseID = data["courseID"] {
            return self._courseID
        }
        if let numberOfInstructors = data["numberOfInstructors"] {
            if (numberOfInstructors.characters.count >= 1) {
                if (numberOfSectionsAndInstructors.characters.count >= 1) {
                    if (numberOfInstructors == "1") {
                        numberOfSectionsAndInstructors = numberOfSectionsAndInstructors + " • " + numberOfInstructors + " Instructor"
                    } else {
                        numberOfSectionsAndInstructors = numberOfSectionsAndInstructors + " • " + numberOfInstructors + " Instructors"
                    }
                } else {
                    if (numberOfSectionsAndInstructors == "1") {
                      numberOfSectionsAndInstructors = numberOfInstructors + " Instructor"
                    } else {
                        numberOfSectionsAndInstructors = numberOfInstructors + " Instructors"
                    }
                }
            }
        }
        self._numberOfSectionsAndInstructors = numberOfSectionsAndInstructors
        if let courseUpdatedOn = data["courseUpdatedOn"] {
            self._courseUpdatedOn = courseUpdatedOn
        }
    }
}
