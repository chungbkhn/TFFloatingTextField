//
//  TFFloatingTextField.swift
//  TFFloatingTextFieldExample
//
//  Created by Chung Duong on 12/3/18.
//  Copyright © 2018 Chung Duong. All rights reserved.
//

import UIKit

protocol FloatingTextFieldDelegate: class {
    
    func textFieldDidChangeHeight(textField: TFFloatingTextField)
}

extension FloatingTextFieldDelegate {
    
    func textFieldDidChangeHeight(textField: TFFloatingTextField) {}
}

/**
 A beautiful and flexible textfield implementation with support for title label, error message and placeholder.
 */
@IBDesignable
open class TFFloatingTextField: UITextField {
    
    weak var floatingDelegate: FloatingTextFieldDelegate?
    var autoClearErrorWhileEditting = true
    
    // MARK: - Animation timing
    
    /// The value of the title appearing duration
    open var titleFadeInDuration: TimeInterval = 0.2
    /// The value of the title disappearing duration
    open var titleFadeOutDuration: TimeInterval = 0.3
    
    // MARK: Placeholder
    
    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable open var placeholderColor: UIColor = UIColor.gray {
        didSet {
            self.updatePlaceholder()
        }
    }
    
    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable open var placeholderFont: UIFont? {
        didSet {
            self.updatePlaceholder()
        }
    }
    
    private func updatePlaceholder() {
        if let
            placeholder = self.placeholder,
            let font = self.placeholderFont ?? self.font {
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor,
                                                                                              NSAttributedString.Key.font: font])
        }
    }
    
    // MARK: - Toogle Password Icon
    
    private let iconPasswordOff = UIImage(named: "ic_eye_off")
    private let iconPasswordOn = UIImage(named: "ic_eye")
    
    @IBInspectable
    var showTogglePasswordIcon: Bool = false {
        didSet {
            updateControl(false)
        }
    }
    
    private var togglePasswordButton: UIButton!
    
    // MARK: - Suffix
    
    @IBInspectable
    var suffix: String? = nil {
        didSet {
            updateControl(false)
        }
    }
    
    private var suffixLabel: UILabel!
    
    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable open var suffixColor: UIColor = UIColor.gray {
        didSet {
            self.updateStyleSuffix()
        }
    }
    
    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable open var suffixFont: UIFont? {
        didSet {
            self.updateStyleSuffix()
        }
    }
    
    private func updateStyleSuffix() {
        if let
            suffix = self.suffix,
            let font = self.suffixFont ?? self.font {
            self.attributedPlaceholder = NSAttributedString(string: suffix,
                                                            attributes: [NSAttributedString.Key.foregroundColor: suffixColor,
                                                                                         NSAttributedString.Key.font: font])
        }
    }
    
    // MARK: - Title
    /// A UIColor value that determines the text color of the title label when in the normal state
    @IBInspectable open var titleColor: UIColor = UIColor.black {
        didSet {
            self.updateTitleColor()
        }
    }
    
    /// A UIColor value that determines the text color of the title label when in the selected state
    @IBInspectable open var selectedTitleColor: UIColor = UIColor.black {
        didSet {
            self.updateTitleColor()
        }
    }
    
    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable open var titleFont: UIFont? {
        didSet {
            self.updateTitleColor()
        }
    }
    
    // MARK: - Bottom line
    
    /// A UIColor value that determines the color of the bottom line when in the normal state
    @IBInspectable open var lineColor: UIColor = UIColor.gray {
        didSet {
            self.updateLineView()
        }
    }
    
    /// A UIColor value that determines the color used for the Error label and the line when the error message is not `nil`
    @IBInspectable open var errorColor: UIColor = UIColor.red {
        didSet {
            self.updateColors()
        }
    }
    
    /// A UIColor value that determines the color of the line in a selected state
    @IBInspectable open var selectedLineColor: UIColor = UIColor.green {
        didSet {
            self.updateLineView()
        }
    }
    
    /// A CGFloat value that determines the height for the bottom line when the control is in the normal state
    @IBInspectable open var lineHeight: CGFloat = 0.5 {
        didSet {
            self.updateLineView()
            self.setNeedsDisplay()
        }
    }
    
    /// A CGFloat value that determines the height for the bottom line when the control is in a selected state
    @IBInspectable open var selectedLineHeight: CGFloat = 1.0 {
        didSet {
            self.updateLineView()
            self.setNeedsDisplay()
        }
    }
    
    // MARK: View components
    
    /// The internal `UIView` to display the line below the text input.
    open var lineView: UIView!
    
    /// The internal `UILabel` that displays the selected, deselected title message based on the current state.
    open var titleLabel: UILabel!
    
    /// The internal `UILabel` that displays the error message based on the current state.
    open var errorLabel: UILabel!
    
    // MARK: Properties
    
    /**
     Identifies whether the text object should hide the text being entered.
     */
    override open var isSecureTextEntry: Bool {
        set {
            super.isSecureTextEntry = newValue
            self.fixCaretPosition()
            if let togglePasswordButton = self.togglePasswordButton {
                if isSecureTextEntry {
                    togglePasswordButton.setImage(iconPasswordOff, for: .normal)
                } else {
                    togglePasswordButton.setImage(iconPasswordOn, for: .normal)
                }
            }
        }
        get {
            return super.isSecureTextEntry
        }
    }
    
    /// A String value for the error message to display.
    fileprivate var _errorMessage: String?
    var errorMessage: String? {
        return _errorMessage
    }
    
    func setErrorMessage(errorMessage: String?, animation: Bool) {
        _errorMessage = errorMessage
        self.errorLabel.text = _errorMessage
        self.updateControl(animation)
    }
    
    @IBInspectable
    var leftImage: UIImage? = nil {
        didSet {
            if leftImage != nil {
                leftImageView.image = leftImage
                self.leftViewMode = .always
            } else {
                self.leftViewMode = .never
            }
        }
    }
    fileprivate var leftImageView: UIImageView!
    
    /// The backing property for the highlighted property
    fileprivate var _highlighted = false
    
    //    /// A Boolean value that determines whether the receiver is highlighted. When changing this value, highlighting will be done with animation
    //    override open var isHighlighted: Bool {
    //        get {
    //            return _highlighted
    //        }
    //        set {
    //            _highlighted = newValue
    //            self.updateTitleColor()
    //            self.updateLineView()
    //        }
    //    }
    
    /// A Boolean value that determines whether the textfield is being edited or is selected.
    open var editingOrSelected: Bool {
        return super.isEditing || self.isSelected
    }
    
    /// A Boolean value that determines whether the receiver has an error message.
    open var hasErrorMessage: Bool {
        return self._errorMessage != nil && self._errorMessage != ""
    }
    
    fileprivate var _renderingInInterfaceBuilder: Bool = false
    
    /// The text content of the textfield
    @IBInspectable
    override open var text: String? {
        didSet {
            self.updateControl(false)
        }
    }
    
    /**
     The String to display when the input field is empty.
     The placeholder can also appear in the title label when both `title` `selectedTitle` and are `nil`.
     */
    @IBInspectable
    override open var placeholder: String? {
        didSet {
            self.setNeedsDisplay()
            self.updatePlaceholder()
            self.updateTitleLabel()
        }
    }
    
    /// The String to display when the textfield is editing and the input is not empty.
    @IBInspectable open var selectedTitle: String? {
        didSet {
            self.updateControl()
        }
    }
    
    /// The String to display when the textfield is not editing and the input is not empty.
    @IBInspectable open var title: String? {
        didSet {
            self.updateControl()
        }
    }
    
    // Determines whether the field is selected. When selected, the title floats above the textbox.
    open override var isSelected: Bool {
        didSet {
            self.updateControl(true)
        }
    }
    
    // MARK: - Initializers
    
    /**
     Initializes the control
     - parameter frame the frame of the control
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupComponents()
    }
    
    /**
     Intialzies the control by deserializing it
     - parameter coder the object to deserialize the control from
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupComponents()
    }
    
    fileprivate final func setupComponents() {
        self.borderStyle = .none
        self.font = Font.body1
        self.createTitleLabel()
        self.createErrorLabel()
        self.createLineView()
        self.createLeftImageView()
        self.createTogglePasswordButton()
        self.createSuffixLabel()
        self.updateColors()
        self.addEditingChangedObserver()
        registerNotification()
    }
    
    private func registerNotification() {
        Util.Notification.handleDidBecomeActiveNotification(observer: self, selector: #selector(appBecomeActive))
        Util.Notification.handleDidChangeStatusBarOrientationNotification(observer: self, selector: #selector(statusBarOrientationDidChange))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func appBecomeActive() {
        updateTogglePasswordButton()
    }
    
    @objc dynamic func statusBarOrientationDidChange() {
        updateTogglePasswordButton()
    }
    
    fileprivate func addEditingChangedObserver() {
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    /**
     Invoked when the editing state of the textfield changes. Override to respond to this change.
     */
    @objc open func editingChanged() {
        if autoClearErrorWhileEditting {
            setErrorMessage(errorMessage: "", animation: false)
        }
        floatingDelegate?.textFieldDidChangeContent(textField: self)
    }
    
    // MARK: create components
    
    fileprivate func createTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        titleLabel.font = Font.body1
        titleLabel.alpha = 0.0
        titleLabel.textColor = self.titleColor
        self.addSubview(titleLabel)
        self.titleLabel = titleLabel
    }
    
    fileprivate func createErrorLabel() {
        let errorLabel = UILabel()
        errorLabel.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        errorLabel.font = StyleType.subBody.font
        errorLabel.alpha = 0.0
        errorLabel.textColor = self.errorColor
        errorLabel.numberOfLines = 0
        self.addSubview(errorLabel)
        self.errorLabel = errorLabel
    }
    
    fileprivate func createLineView() {
        
        if self.lineView == nil {
            let lineView = UIView()
            lineView.isUserInteractionEnabled = false
            self.lineView = lineView
            self.configureDefaultLineHeight()
        }
        lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.addSubview(lineView)
    }
    
    fileprivate func createLeftImageView() {
        let imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        imageView.contentMode = .scaleAspectFit
        self.leftView = imageView
        self.leftImageView = imageView
    }
    
    fileprivate func createTogglePasswordButton() {
        let toggleButton = UIButton(type: .custom)
        toggleButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        toggleButton.addTarget(self, action: #selector(onClickTogglePasswordButton), for: .touchUpInside)
        if isSecureTextEntry {
            toggleButton.setImage(eyeOffImage, for: .normal)
        } else {
            toggleButton.setImage(eyeOnImage, for: .normal)
        }
        self.addSubview(toggleButton)
        self.togglePasswordButton = toggleButton
    }
    
    fileprivate func createSuffixLabel() {
        let suffixLabel = UILabel()
        
        suffixLabel.font = Font.info1
        suffixLabel.textColor = Constant.Color.info1
        suffixLabel.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        self.addSubview(suffixLabel)
        self.suffixLabel = suffixLabel
    }
    
    @objc func onClickTogglePasswordButton() {
        self.isSecureTextEntry = !self.isSecureTextEntry
    }
    
    fileprivate func configureDefaultLineHeight() {
        let onePixel: CGFloat = 1.0 / UIScreen.main.scale
        self.lineHeight = 2.0 * onePixel
        self.selectedLineHeight = 2.0 * self.lineHeight
    }
    
    // MARK: Responder handling
    
    /**
     Attempt the control to become the first responder
     - returns: True when successfull becoming the first responder
     */
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        self.updateControl(true)
        return result
    }
    
    /**
     Attempt the control to resign being the first responder
     - returns: True when successfull resigning being the first responder
     */
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        let result =  super.resignFirstResponder()
        if autoValidation {
            self.validateAndUpdateUI()
        } else {
            self.updateControl(true)
        }
        return result
    }
    
    // MARK: - View updates
    
    fileprivate func updateControl(_ animated: Bool = false) {
        if isBatchUpdating { return }
        let currentHeight = self.frame.size.height
        
        self.updateColors()
        self.updateLineView()
        self.updateTogglePasswordButton()
        self.updateSuffixLabel()
        
        self.updateTitleLabelAndErrorLabel(animated) { [weak self] (_) in
            guard let `self` = self else { return }
            
            if currentHeight != self.frame.size.height {
                self.floatingDelegate?.textFieldDidChangeHeight(textField: self)
            }
        }
    }
    
    fileprivate func updateLineView() {
        if let lineView = self.lineView {
            lineView.frame = self.lineViewRectForBounds(self.bounds, editing: self.editingOrSelected)
        }
        self.updateLineColor()
    }
    
    // MARK: - Color updates
    
    /// Update the colors for the control. Override to customize colors.
    open func updateColors() {
        self.updateLineColor()
        self.updateTitleColor()
        self.updateErrorColor()
    }
    
    fileprivate func updateLineColor() {
        if self.hasErrorMessage {
            self.lineView.backgroundColor = self.errorColor
        } else {
            self.lineView.backgroundColor = self.editingOrSelected ? self.selectedLineColor : self.lineColor
        }
    }
    
    fileprivate func updateTitleColor() {
        //        if self.editingOrSelected || self.isHighlighted {
        if self.editingOrSelected {
            self.titleLabel.textColor = self.selectedTitleColor
        } else {
            self.titleLabel.textColor = self.titleColor
        }
    }
    
    fileprivate func updateErrorColor() {
        self.errorLabel.textColor = self.errorColor
    }
    
    fileprivate func updateTogglePasswordButton() {
        self.togglePasswordButton.isHidden = !showTogglePasswordIcon
        self.togglePasswordButton.frame = self.togglePasswordButtonRectForBounds(self.bounds)
        if let parentView = self.superview {
            self.invalidateIntrinsicContentSize()
            parentView.setNeedsLayout()
            parentView.layoutIfNeeded()
        }
    }
    
    fileprivate func updateSuffixLabel() {
        self.suffixLabel.isHidden = !self.showSuffixLabel
        self.suffixLabel.text = suffix
        self.suffixLabel.frame = self.suffixRectForBounds(self.bounds)
        if let parentView = self.superview {
            self.invalidateIntrinsicContentSize()
            parentView.setNeedsLayout()
            parentView.layoutIfNeeded()
        }
    }
    
    fileprivate var isBatchUpdating: Bool = false
    func batchUpdate(block: () -> Void ) {
        isBatchUpdating = true
        block()
        isBatchUpdating = false
        updateControl()
        floatingDelegate?.textFieldDidChangeHeight(textField: self)
    }
    
    // MARK: - Title handling
    
    fileprivate func updateTitleLabelAndErrorLabel(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        
        var titleText: String?
        if self.editingOrSelected {
            titleText = self.selectedTitleOrTitlePlaceholder()
            if titleText == nil {
                titleText = self.titleOrPlaceholder()
            }
        } else {
            titleText = self.titleOrPlaceholder()
        }
        self.titleLabel.text = titleText
        
        let alphaTitle: CGFloat = self.isTitleVisible() ? 1.0 : 0.0
        let frameTitle: CGRect = self.titleLabelRectForBounds(self.bounds, editing: self.isTitleVisible())
        let alphaError: CGFloat = self.isErrorVisible() ? 1.0 : 0.0
        let frameError: CGRect = self.errorLabelRectForBounds(self.bounds, editing: self.isErrorVisible())
        let updateBlock = { () -> Void in
            self.titleLabel.alpha = alphaTitle
            self.titleLabel.frame = frameTitle
            self.errorLabel.alpha = alphaError
            self.errorLabel.frame = frameError
            if let parentView = self.superview {
                self.invalidateIntrinsicContentSize()
                parentView.setNeedsLayout()
                parentView.layoutIfNeeded()
            }
        }
        if animated {
            let animationOptions: UIView.AnimationOptions = .curveEaseOut
            let duration = self.isTitleVisible() ? titleFadeInDuration : titleFadeOutDuration
            
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: { () -> Void in
                updateBlock()
            }, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }
    
    fileprivate func updateTitleLabel(_ animated: Bool = false) {
        
        var titleText: String?
        if self.editingOrSelected {
            titleText = self.selectedTitleOrTitlePlaceholder()
            if titleText == nil {
                titleText = self.titleOrPlaceholder()
            }
        } else {
            titleText = self.titleOrPlaceholder()
        }
        self.titleLabel.text = titleText
        
        self.updateTitleVisibility(animated)
    }
    
    fileprivate var _titleVisible = false
    
    /*
     *   Set this value to make the title visible
     */
    open func setTitleVisible(_ titleVisible: Bool, animated: Bool = false, animationCompletion: ((_ completed: Bool) -> Void)? = nil) {
        if _titleVisible == titleVisible {
            return
        }
        _titleVisible = titleVisible
        self.updateTitleColor()
        self.updateTitleVisibility(animated, completion: animationCompletion)
    }
    
    /**
     Returns whether the title is being displayed on the control.
     - returns: True if the title is displayed on the control, false otherwise.
     */
    open func isTitleVisible() -> Bool {
        return self.hasText || _titleVisible
    }
    
    fileprivate func updateTitleVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        let alpha: CGFloat = self.isTitleVisible() ? 1.0 : 0.0
        let frame: CGRect = self.titleLabelRectForBounds(self.bounds, editing: self.isTitleVisible())
        let updateBlock = { () -> Void in
            self.titleLabel.alpha = alpha
            self.titleLabel.frame = frame
            if let parentView = self.superview {
                self.invalidateIntrinsicContentSize()
                parentView.setNeedsLayout()
                parentView.layoutIfNeeded()
            }
        }
        if animated {
            let animationOptions: UIView.AnimationOptions = .curveEaseOut
            let duration = self.isTitleVisible() ? titleFadeInDuration : titleFadeOutDuration
            
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: { () -> Void in
                updateBlock()
            }, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }
    
    // MARK: - Error handling
    
    fileprivate func updateErrorLabel(_ animated: Bool = false) {
        self.updateErrorVisibility(animated)
    }
    
    fileprivate var _errorVisible = false
    
    /*
     *   Set this value to make the title visible
     */
    open func setErrorVisible(_ errorVisible: Bool, animated: Bool = false, animationCompletion: ((_ completed: Bool) -> Void)? = nil) {
        if _errorVisible == errorVisible {
            return
        }
        _errorVisible = errorVisible
        self.updateErrorColor()
        self.updateErrorVisibility(animated, completion: animationCompletion)
    }
    
    /**
     Returns whether the title is being displayed on the control.
     - returns: True if the title is displayed on the control, false otherwise.
     */
    open func isErrorVisible() -> Bool {
        return self.hasErrorMessage || _errorVisible
    }
    
    fileprivate func updateErrorVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        let alpha: CGFloat = self.isErrorVisible() ? 1.0 : 0.0
        let frame: CGRect = self.errorLabelRectForBounds(self.bounds, editing: self.isErrorVisible())
        let updateBlock = { () -> Void in
            self.errorLabel.alpha = alpha
            self.errorLabel.frame = frame
            if let parentView = self.superview {
                self.invalidateIntrinsicContentSize()
                parentView.setNeedsLayout()
                parentView.layoutIfNeeded()
            }
        }
        if animated {
            let animationOptions: UIView.AnimationOptions = .curveEaseIn
            let duration = self.isErrorVisible() ? titleFadeInDuration : titleFadeOutDuration
            
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: { () -> Void in
                updateBlock()
            }, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }
    
    // MARK: - UITextField text/placeholder positioning overrides
    
    /**
     Calculate the rectangle for the textfield when it is not being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        let titleHeight = self.titleHeight()
        let errorHeight = self.errorHeight()
        let lineHeight = self.selectedLineHeight
        var paddingRight = CGFloat(0)
        if showTogglePasswordIcon {
            paddingRight += self.togglePasswordButtonRectForBounds(bounds).width + 8
        }
        if showSuffixLabel {
            paddingRight += self.suffixRectForBounds(bounds).width + 12
        }
        
        if showTogglePasswordIcon || showSuffixLabel {
            paddingRight += 6
        }
        
        var paddingLeft = CGFloat(0)
        if self.leftViewMode == .always {
            paddingLeft = 32
        }
        
        let rect = CGRect(x: paddingLeft, y: titleHeight, width: bounds.size.width - paddingRight - paddingLeft, height: bounds.size.height - titleHeight - lineHeight - errorHeight)
        return rect
    }
    
    /**
     Calculate the rectangle for the textfield when it is being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let titleHeight = self.titleHeight()
        let errorHeight = self.errorHeight()
        let lineHeight = self.selectedLineHeight
        
        var paddingRight = CGFloat(0)
        if showTogglePasswordIcon {
            paddingRight += self.togglePasswordButtonRectForBounds(bounds).width + 8
        }
        if showSuffixLabel {
            paddingRight += self.suffixRectForBounds(bounds).width + 12
        }
        
        if showTogglePasswordIcon || showSuffixLabel {
            paddingRight += 6
        } else {
            paddingRight = 15
        }
        
        var paddingX = CGFloat(0)
        if self.leftViewMode == .always {
            paddingX = 32
        }
        
        let rect = CGRect(x: paddingX, y: titleHeight, width: bounds.size.width - paddingRight - paddingX, height: bounds.size.height - titleHeight - lineHeight - errorHeight)
        return rect
    }
    
    /**
     Calculate the rectangle for the placeholder
     - parameter bounds: The current bounds of the placeholder
     - returns: The rectangle that the placeholder should render in
     */
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let titleHeight = self.titleHeight()
        let errorHeight = self.errorHeight()
        let lineHeight = self.selectedLineHeight
        
        var paddingRight = CGFloat(0)
        if showTogglePasswordIcon {
            paddingRight += self.togglePasswordButtonRectForBounds(bounds).width + 8
        }
        if showSuffixLabel {
            paddingRight += self.suffixRectForBounds(bounds).width + 12
        }
        
        if showTogglePasswordIcon || showSuffixLabel {
            paddingRight += 6
        } else {
            paddingRight = 15
        }
        
        var paddingX = CGFloat(0)
        if self.leftViewMode == .always {
            paddingX = 32
        }
        
        let rect = CGRect(x: paddingX, y: titleHeight, width: bounds.size.width - paddingRight - paddingX, height: bounds.size.height - titleHeight - lineHeight - errorHeight)
        return rect
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let titleHeight = self.titleHeight()
        let errorHeight = self.errorHeight()
        let lineHeight = self.selectedLineHeight
        
        var paddingRight = CGFloat(0)
        if showTogglePasswordIcon {
            paddingRight += self.togglePasswordButtonRectForBounds(bounds).width + 8
        }
        if showSuffixLabel {
            paddingRight += self.suffixRectForBounds(bounds).width + 12
        }
        
        if showTogglePasswordIcon || showSuffixLabel {
            paddingRight += 6
        } else {
            paddingRight = 15
        }
        
        let rect = CGRect(x: bounds.size.width - paddingRight, y: titleHeight, width: 15, height: bounds.size.height - titleHeight - lineHeight - errorHeight)
        return rect
    }
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let titleHeight = self.titleHeight()
        let rect = CGRect(x: 0, y: titleHeight + 6, width: 24, height: 24)
        return rect
    }
    
    // MARK: - Positioning Overrides
    
    /**
     Calculate the bounds for the title label. Override to create a custom size title field.
     - parameter bounds: The current bounds of the title
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the title label should render in
     */
    open func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let titleHeight = self.titleHeight()
        
        var paddingX = CGFloat(0)
        if self.leftViewMode == .always {
            paddingX = 32
        }
        
        if editing {
            return CGRect(x: paddingX, y: 0, width: bounds.size.width - paddingX, height: titleHeight)
        }
        return CGRect(x: paddingX, y: titleHeight, width: bounds.size.width - paddingX, height: titleHeight)
    }
    
    /**
     Calculate the bounds for the toggle password button. Override to create a custom size toggle button.
     - parameter bounds: The current bounds of the button
     - returns: The rectangle that the toggle password button should render in
     */
    open func togglePasswordButtonRectForBounds(_ bounds: CGRect) -> CGRect {
        let titleHeight = self.titleHeight()
        return CGRect(x: bounds.size.width - 40, y: titleHeight - 5, width: 40, height: 40)
    }
    
    /**
     Calculate the bounds for the suffix label. Override to create a custom size title field.
     - parameter bounds: The current bounds of the label
     - returns: The rectangle that the suffix label should render in
     */
    open func suffixRectForBounds(_ bounds: CGRect) -> CGRect {
        let size = suffixLabel.sizeThatFits(CGSize(width: CGFloat(MAXFLOAT), height: suffixLabel.frame.size.height))
        let titleHeight = self.titleHeight()
        
        var paddingRight = CGFloat(0)
        if showTogglePasswordIcon {
            paddingRight = togglePasswordButton.frame.size.width + 8
        }
        
        return CGRect(x: bounds.size.width - size.width - paddingRight, y: titleHeight, width: size.width, height: 30)
    }
    
    /**
     Calculate the bounds for the error label. Override to create a custom size error field.
     - parameter bounds: The current bounds of the error
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the error label should render in
     */
    open func errorLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let errorHeight = self.errorHeight()
        
        var paddingX = CGFloat(0)
        if self.leftViewMode == .always {
            paddingX = 32
        }
        
        if editing {
            return CGRect(x: paddingX, y: bounds.size.height - errorHeight, width: bounds.size.width - paddingX, height: errorHeight)
        } else {
            return CGRect(x: paddingX, y: bounds.size.height - 1.5 * errorHeight, width: bounds.size.width - paddingX, height: errorHeight)
        }
    }
    
    /**
     Calculate the bounds for the bottom line of the control. Override to create a custom size bottom line in the textbox.
     - parameter bounds: The current bounds of the line
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the line bar should render in
     */
    open func lineViewRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let lineHeight: CGFloat = editing ? CGFloat(self.selectedLineHeight) : CGFloat(self.lineHeight)
        let errorHeight: CGFloat = self.errorHeight()
        var widthTogglePassword = CGFloat(0)
        if showTogglePasswordIcon {
            widthTogglePassword = self.togglePasswordButtonRectForBounds(bounds).width
        }
        
        var paddingX = CGFloat(0)
        if self.leftViewMode == .always {
            paddingX = 32
        }
        
        return CGRect(x: paddingX, y: bounds.size.height - lineHeight - errorHeight, width: bounds.size.width - widthTogglePassword - paddingX, height: lineHeight)
    }
    
    /**
     Calculate the height of the title label.
     -returns: the calculated height of the title label. Override to size the title with a different height
     */
    open func titleHeight() -> CGFloat {
        if isTitleVisible() {
            if let titleLabel = self.titleLabel,
                let font = titleLabel.font {
                return font.lineHeight
            }
            return 15.0
        } else {
            return 0
        }
    }
    
    /**
     Calculate the height of the error label.
     -returns: the calculated height of the error label. Override to size the error with a different height
     */
    open func errorHeight() -> CGFloat {
        if let errorLabel = self.errorLabel {
            let size = errorLabel.sizeThatFits(CGSize(width: errorLabel.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
            return size.height
        } else {
            return 0
        }
    }
    
    /**
     Calcualte the height of the textfield.
     -returns: the calculated height of the textfield. Override to size the textfield with a different height
     */
    open func textHeight() -> CGFloat {
        return self.font!.lineHeight + 7.0
    }
    
    // MARK: - Layout
    
    /// Invoked when the interface builder renders the control
    override open func prepareForInterfaceBuilder() {
        if #available(iOS 8.0, *) {
            super.prepareForInterfaceBuilder()
        }
        
        self.borderStyle = .none
        
        self.isSelected = true
        _renderingInInterfaceBuilder = true
        self.updateControl(false)
        self.invalidateIntrinsicContentSize()
    }
    
    /// Invoked by layoutIfNeeded automatically
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.frame = self.titleLabelRectForBounds(self.bounds, editing: self.isTitleVisible() || _renderingInInterfaceBuilder)
        self.lineView.frame = self.lineViewRectForBounds(self.bounds, editing: self.editingOrSelected || _renderingInInterfaceBuilder)
        self.errorLabel.frame = self.errorLabelRectForBounds(self.bounds, editing: self.isErrorVisible() || _renderingInInterfaceBuilder)
        self.togglePasswordButton.frame = self.togglePasswordButtonRectForBounds(self.bounds)
        self.suffixLabel.frame = self.suffixRectForBounds(self.bounds)
    }
    
    /**
     Calculate the content size for auto layout
     
     - returns: the content size to be used for auto layout
     */
    override open var intrinsicContentSize: CGSize {
        //        return CGSize(width: self.bounds.size.width, height: self.titleHeight() + self.textHeight() + self.errorHeight())
        return CGSize(width: self.bounds.size.width, height: self.titleHeight() + 30 + self.errorHeight())
    }
    
    // MARK: - Helpers
    
    fileprivate func titleOrPlaceholder() -> String? {
        if let title = self.title ?? self.placeholder {
            return title
        }
        return nil
    }
    
    fileprivate func selectedTitleOrTitlePlaceholder() -> String? {
        if let title = self.selectedTitle ?? self.title ?? self.placeholder {
            return title
        }
        return nil
    }
}
