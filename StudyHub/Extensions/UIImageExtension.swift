//
//  UIImageExtension.swift
//  StudyHub
//
//  Created by Dan Levy on 3/12/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

extension UIImage
{
    var highQualityJPEGData: Data    {
        return UIImageJPEGRepresentation(self, 0.75)! as Data
    }
    var mediumQualityJPEGData: Data  {
        return UIImageJPEGRepresentation(self, 0.5)! as Data
    }
    var lowQualityJPEGData: Data     {
        return UIImageJPEGRepresentation(self, 0.25)! as Data
    }
}
