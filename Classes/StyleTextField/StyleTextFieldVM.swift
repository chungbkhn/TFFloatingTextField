/*
//
//  StyleTextFieldVM.swift
//  Nordnet
//
//  Created by Luong Minh Hiep on 8/20/18.
//  Copyright © 2018 Nordnet. All rights reserved.
//

import Foundation

class StyleTextFieldVM {
    var title: String
    var text: String
    var errorMessage: String?
    var suffix: String
    var rightActionIcon: UIImage?
    var leftImage: UIImage?
    var inputType: RegexType?
    var maxCharacter: Int
    weak var delegate: StyleTextFieldDelegate?
    var customValidation: FloatingTextFieldValidationBlock?

    weak var presenter: StyleTextField?

    init(title: String, text: String = "", inputType: RegexType? = nil, errorMessage: String? = nil, suffix: String = "", rightActionIcon: UIImage? = nil, leftImage: UIImage? = nil, maxCharacter: Int = Int.max, delegate: StyleTextFieldDelegate?, customValidation: FloatingTextFieldValidationBlock?) {
        self.title = title
        self.text = text
        self.errorMessage = errorMessage
        self.inputType = inputType
        self.maxCharacter = maxCharacter
        self.delegate = delegate
        self.customValidation = customValidation
        self.suffix = suffix
        self.rightActionIcon = rightActionIcon
        self.leftImage = leftImage
    }

    func updateMessageError(errorMsg: String) {
        self.errorMessage = errorMsg
        presenter?.updateMessageError(errorMsg: errorMsg)
    }

    func updateContent(text: String) {
        presenter?.updateContent(text: text)
    }

    func updateTitle(title: String) {
        presenter?.updateTitle(title: title)
    }

    func info() -> (content: String, hasError: Bool, errorMessage: String)? {
       return presenter?.info()
    }

    func forceEndEditing() {
        presenter?.forceEndEditing()
    }

    func hasError() -> Bool {
        if let error = errorMessage, !error.isEmpty {
            return true
        }
        return false
    }
}
*/
