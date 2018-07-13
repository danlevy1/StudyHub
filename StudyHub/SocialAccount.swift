//
//  SocialAccount.swift
//  StudyHub
//
//  Created by Dan Levy on 7/13/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class SocialAccount {
    private var _bgColor: UIColor?
    private var _textColor: UIColor?
    private var _image: UIImage?
    private var _text: String?
    private var _link: URL?
    
    init(bgColor: UIColor?, textColor: UIColor?, image: UIImage?, text: String?, link: URL?) {
        self._bgColor = bgColor
        self._textColor = textColor
        self._image = image
        self._text = text
        self._link = link
    }
    
    func getBGColor() -> UIColor? {
        return self._bgColor
    }
    func getTextColor() -> UIColor? {
        return self._textColor
    }
    func getImage() -> UIImage? {
        return self._image
    }
    func getText() -> String? {
        return self._text
    }
    func getLink() -> URL? {
        return self._link
    }
}
