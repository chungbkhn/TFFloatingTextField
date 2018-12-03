/*
//
//  StyleTextField.swift
//  Nordnet
//
//  Created by Duong Van Chung on 10/20/17.
//  Copyright © 2017 Nordnet. All rights reserved.
//

import UIKit

protocol StyleTextFieldDelegate: StyleViewDelegate {

    func styleTextFieldDidChangeContent(view: StyleTextField, text: String)
    func textfieldFinishEditting(view: StyleTextField)
}

@IBDesignable
class StyleTextField: StyleView {

    var viewModel: StyleTextFieldVM?

    // MARK: - UI

    @IBOutlet fileprivate weak var contentStackView: UIStackView!
    @IBOutlet fileprivate weak var textField: ResponsibleTextField!
    @IBOutlet fileprivate weak var textStackView: UIStackView!
    @IBOutlet fileprivate weak var textOutSideStackView: UIStackView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var underLineView: UIView!
    @IBOutlet fileprivate weak var errorLabel: UILabel!
    @IBOutlet fileprivate weak var leftImageView: UIImageView!
    @IBOutlet fileprivate weak var suffixLabel: UILabel!
    @IBOutlet fileprivate weak var toggleButton: UIButton!
    @IBOutlet fileprivate weak var titleLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var errorLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var underLineViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var underLineViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var underLineViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var rightActionButton: UIButton!

    // MARK: - Config Color

    fileprivate let activeColor = Constant.Color.textFieldTitleActive
    fileprivate let inactiveColor = Constant.Color.gray500
    fileprivate let errorColor = Constant.Color.red500

    override init(frame: CGRect) {
        super.init(frame: frame)

        configDefaultUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Property
    @IBInspectable var title: String = "" {
        didSet {
            guard isInitializedUI else { return }

            titleLabel.text = title
            textField.placeholder = title
            updateTitlePosition()
        }
    }

    @IBInspectable var text: String = "" {
        didSet {
            guard isInitializedUI else { return }

            textField.text = text
            updateTitlePosition()
        }
    }

    @IBInspectable var suffix: String = "" {
        didSet {
            guard isInitializedUI else { return }

            suffixLabel.text = suffix
            textStackView.arrangedSubviews[2].isHidden = suffix.isEmpty
        }
    }

    @IBInspectable var rightActionIcon: UIImage? = nil {
        didSet {
            guard isInitializedUI else { return }

            rightActionButton.setImage(rightActionIcon, for: .normal)
            let hasRightActionIcon = rightActionIcon != nil
            contentStackView.arrangedSubviews[1].isHidden = !hasRightActionIcon
        }
    }

    @IBInspectable var leftImage: UIImage? = nil {
        didSet {
            guard isInitializedUI else { return }

            leftImageView.image = leftImage
            hasLeftImage = leftImage != nil
            textStackView.arrangedSubviews[0].isHidden = !hasLeftImage
            updateUnderLinePaddings()
            updateTitleAndErrorPaddings()
        }
    }

    fileprivate var inputType: RegexType? = nil {
        didSet {
            guard isInitializedUI else { return }

            guard let `inputType` = inputType else { return }

            switch inputType {
            case .zipCode, .phone, .phoneFrench, .phoneFrenchFix, .phoneFrenchAndInternational, .phoneInternational, .phoneFrenchShort, .phoneFrenchAndShort, .phoneFrenchAndInternationalAndShort:
                textField.keyboardType = .phonePad
            case .simNumber:
                textField.keyboardType = .numberPad
            case .password:
                textField.autocorrectionType = .no
                textField.isSecureTextEntry = true
                textField.fixCaretPosition()
                toggleButton.isSelected = !textField.isSecureTextEntry
            case .email, .emailAntiSpam:
                textField.keyboardType = .emailAddress
            case .invoiceNumber:
                textField.keyboardType = .decimalPad
            default:
                break
            }

            textStackView.arrangedSubviews[3].isHidden = !hasToggleButton
            updateUnderLinePaddings()
        }
    }

    fileprivate var hasToggleButton: Bool {
        return inputType == .password
    }

    fileprivate var hasError: Bool {
        return !errorMessage.isEmpty
    }

    fileprivate var isEditing: Bool = false {
        didSet {
            guard isInitializedUI else { return }

            if isEditing {
                titleLabel.textColor = activeColor
            } else {
                titleLabel.textColor = inactiveColor
            }
            updateUnderLineState()
        }
    }

    fileprivate var errorMessage: String = "" {
        didSet {
            guard isInitializedUI else { return }

            errorLabel.text = errorMessage
            updateUnderLineState()
            textOutSideStackView.arrangedSubviews[3].isHidden = errorMessage.isEmpty
        }
    }

    fileprivate var customValidation: FloatingTextFieldValidationBlock?
    fileprivate weak var delegate: StyleTextFieldDelegate?
    fileprivate var maxCharacter: Int = Int.max

    fileprivate func updateUnderLineState() {
        if isEditing {
            underLineViewHeightConstraint.constant = 1.0
            underLineView.backgroundColor = activeColor
        } else {
            underLineViewHeightConstraint.constant = 0.5
            underLineView.backgroundColor = inactiveColor
        }
        if hasError {
            underLineView.backgroundColor = errorColor
        }
    }

    fileprivate func updateUnderLinePaddings() {
        if hasLeftImage {
            underLineViewLeadingConstraint.constant = 32
        } else {
            underLineViewLeadingConstraint.constant = 0
        }

        if hasToggleButton {
            underLineViewTrailingConstraint.constant = 40
        } else {
            underLineViewTrailingConstraint.constant = 0
        }
    }

    fileprivate func updateTitleAndErrorPaddings() {
        if hasLeftImage {
            titleLabelLeadingConstraint.constant = 32
            errorLabelLeadingConstraint.constant = 32
        } else {
            titleLabelLeadingConstraint.constant = 0
            errorLabelLeadingConstraint.constant = 0
        }
    }

    fileprivate func updateTitlePosition() {
        if let contentText = textField.text, !contentText.isEmpty, !title.isEmpty {
            textOutSideStackView.arrangedSubviews[0].isHidden = false
        } else {
            textOutSideStackView.arrangedSubviews[0].isHidden = true
        }
    }

    @IBAction fileprivate func toggleButton_TouchUpInside(_ sender: UIButton) {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
        textField.fixCaretPosition()
        toggleButton.isSelected = !textField.isSecureTextEntry
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configDefaultUI()
    }

    private func configDefaultUI() {
        textField.responsibleDelegate = self
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)

        titleLabel.text = title.localized
        textField.placeholder = title.localized

        textField.text = text
        updateTitlePosition()

        suffixLabel.text = suffix
        textStackView.arrangedSubviews[2].isHidden = suffix.isEmpty

        rightActionButton.setImage(rightActionIcon, for: .normal)
        let hasRightActionIcon = rightActionIcon != nil
        contentStackView.arrangedSubviews[1].isHidden = !hasRightActionIcon

        leftImageView.image = leftImage
        hasLeftImage = leftImage != nil
        textStackView.arrangedSubviews[0].isHidden = !hasLeftImage
        updateTitleAndErrorPaddings()

        if let `inputType` = inputType {
            switch inputType {
            case .phone, .zipCode, .phoneInternational, .phoneFrenchAndInternational, .phoneFrench:
                textField.keyboardType = .phonePad
            case .simNumber:
                textField.keyboardType = .numberPad
            case .password:
                textField.autocorrectionType = .no
                textField.isSecureTextEntry = true
                textField.fixCaretPosition()
                toggleButton.isSelected = !textField.isSecureTextEntry
            case .email:
                textField.keyboardType = .emailAddress
            case .invoiceNumber:
                textField.keyboardType = .decimalPad
            default:
                break
            }
        }

        textStackView.arrangedSubviews[3].isHidden = !hasToggleButton
        updateUnderLinePaddings()

        if isEditing {
            titleLabel.textColor = activeColor
        } else {
            titleLabel.textColor = inactiveColor
        }

        errorLabel.text = errorMessage
        updateUnderLineState()
        textOutSideStackView.arrangedSubviews[3].isHidden = errorMessage.isEmpty
    }

    @objc fileprivate func editingChanged() {
        var content = ""
        if let text = textField.text {
            content = text
        }
        updateTitlePosition()
        if !errorMessage.isEmpty {
            errorMessage = ""
            viewModel?.errorMessage = ""
        }
        Constant.mainQueue.asyncAfter(deadline: .now() + 0.05) {
            IQKeyboardManager.shared.reloadLayoutIfNeeded()
        }
        self.delegate?.styleTextFieldDidChangeContent(view: self, text: content)
    }

    fileprivate func validateContent() -> (isValid: Bool, message: String) {
        var content = ""
        if let text = textField.text {
            content = text
        }
        content = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if let `customValidation` = customValidation {
            return customValidation(content)
        }

        guard let regexType = inputType else { return (true, "") }

        return Util.validate(content: content, regexType: regexType)
    }
}

extension StyleTextField: ResponsibleTextFieldDelegate {

    func responsibleTextFieldChangeState(isEditing: Bool) {
        self.isEditing = isEditing

        if !isEditing {
            errorMessage = validateContent().message
            viewModel?.errorMessage = validateContent().message
            IQKeyboardManager.shared.reloadLayoutIfNeeded()
            delegate?.textfieldFinishEditting(view: self)
        }
    }
}

extension StyleTextField: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = string
        if let oldString = textField.text {
            newString = NSString(string: oldString).replacingCharacters(in: range, with: string)
        }
        return newString.count <= maxCharacter
    }
}

// MARK: - Public API

extension StyleTextField {

    func setReturnKeyType(_ returnKeyType: UIReturnKeyType) {
        self.textField.returnKeyType = returnKeyType
    }

    func updateMessageError(errorMsg: String) {
        self.errorMessage = errorMsg
        if let msg = viewModel?.errorMessage, msg != errorMsg {
            viewModel?.errorMessage = errorMsg
        }
    }

    func updateContent(text: String) {
        self.text = text
    }

    func updateTitle(title: String) {
        self.title = title
    }

    func configUI(inputType: RegexType?, maxCharacter: Int = Int.max, delegate: StyleTextFieldDelegate?, customValidation: FloatingTextFieldValidationBlock?) {
        self.inputType = inputType
        self.customValidation = customValidation
        self.delegate = delegate
        self.maxCharacter = maxCharacter
    }

    func info() -> (content: String, hasError: Bool, errorMessage: String) {
        var content = ""
        if let text = textField.text {
            content = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        return (content, hasError, errorMessage)
    }

    func forceEndEditing() {
        textField.resignFirstResponder()
    }

    func forceValidate() {
        textField.resignFirstResponder()
        responsibleTextFieldChangeState(isEditing: false)
    }

    func config(viewModel: StyleTextFieldVM) {

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.title = viewModel.title
            self.text = viewModel.text
            self.suffix = viewModel.suffix
            self.rightActionIcon = viewModel.rightActionIcon
            self.leftImage = viewModel.leftImage
            self.errorMessage = viewModel.errorMessage ?? ""
            self.inputType = viewModel.inputType
            self.customValidation = viewModel.customValidation
            self.delegate = viewModel.delegate
            self.maxCharacter = viewModel.maxCharacter

            viewModel.presenter = self
            self.viewModel = viewModel
            self.topSeparator = 0
            self.bottomSeparator = 0
        }
    }
}
*/
