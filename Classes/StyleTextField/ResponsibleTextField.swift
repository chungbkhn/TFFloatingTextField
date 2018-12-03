/*
//
//  ResponsibleTextField.swift
//  Nordnet
//
//  Created by Duong Van Chung on 10/20/17.
//  Copyright © 2017 Nordnet. All rights reserved.
//

import UIKit

protocol ResponsibleTextFieldDelegate: class {

    func responsibleTextFieldChangeState(isEditing: Bool)
}

class ResponsibleTextField: UITextField {

    weak var responsibleDelegate: ResponsibleTextFieldDelegate?

    // MARK: Responder handling

    /**
     Attempt the control to become the first responder
     - returns: True when successfull becoming the first responder
     */
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        responsibleDelegate?.responsibleTextFieldChangeState(isEditing: true)
        return result
    }

    /**
     Attempt the control to resign being the first responder
     - returns: True when successfull resigning being the first responder
     */
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        let result =  super.resignFirstResponder()
        responsibleDelegate?.responsibleTextFieldChangeState(isEditing: false)
        return result
    }
}
*/
