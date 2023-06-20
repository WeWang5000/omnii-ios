//
//  SignupPhoneView.swift
//  omnii
//
//  Created by huyang on 2023/4/24.
//

import UIKit
import CommonUtils
import Schedule
import SwiftRichString

enum SignupEditType: Int {
    case phone      = 0
    case code       = 1
    case name       = 2
    case birthday   = 3
    case gender     = 4
    
    func next() -> SignupEditType {
        guard self != .gender else { return .gender }
        let raw = self.rawValue + 1
        return SignupEditType.init(rawValue: raw)!
    }
    
    func prevous() -> SignupEditType {
        guard self != .phone else { return .phone }
        let raw = self.rawValue - 1
        return SignupEditType.init(rawValue: raw)!
    }
    
}


enum SignupClickType {
    case countryPick
    case resetTimer
}


class SignupEditView: UIView {
    
    // 输入回调
    var editChanged: ((SignupEditType, String?) -> Void)?
    
    // 按钮触发事件
    var clickHandler: ((SignupClickType) -> Void)?
    
    var type: SignupEditType {
        didSet {
            updateViews()
        }
    }
    
    // used to title
    private var dialCode: String?
    private var phone: String?
    
    fileprivate var titleLabel: UILabel!
    private(set) lazy var editViews: [UIView] = {
        return [UIView]()
    }()
    
    init(show type: SignupEditType, frame: CGRect) {
        self.type = type
        super.init(frame: frame)
        
        setupViews()
        updateViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCountryItem(to item: CountryItem) {
        guard let phoneEditView = editViews.first as? PhoneEditView else { return }
        dialCode = item.dialCode
        phoneEditView.setCountryItem(to: item)
    }
    
    func resetTimer() {
        guard let codeEditView = editViews[1] as? CodeEditView else { return }
        codeEditView.resetTimer()
    }
    
    func setWarningText(text: String) {
        guard let phoneEditView = editViews.first as? PhoneEditView else { return }
        phoneEditView.message = text
    }
    
    override func becomeFirstResponder() -> Bool {
        if type == .phone {
            return editViews.first!.becomeFirstResponder()
        }
        return super.becomeFirstResponder()
    }
    
    // MARK: - UI

    fileprivate func setupViews() {
        setupTitle()
        setupPhoneEditView()
        setupCodeEditView()
        setupSignupViews()
    }
    
    fileprivate func setupSignupViews() {
        setupNameEditView()
        setupBirthdayEditView()
        setupGenderEditView()
    }
    
    fileprivate func updateViews() {
        updateTitle()
        updateEditView()
    }
        
    private func setupTitle() {
        titleLabel = UILabel()
        titleLabel.textColor = UIColor(hexString: "#E6E9FF")
        titleLabel.font = UIFont(type: .montserratLight, size: 23.rpx)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.x = 20.rpx
        titleLabel.y = 26.rpx
        titleLabel.size = CGSize(width: 271.rpx, height: 103.rpx)
        addSubview(titleLabel)
    }
    
    private func updateTitle() {
        switch type {
        case .phone:
            titleLabel.text = "I Need Your Phone Number To ldentify You"
        case .code:
            if let phone = phone, let dia = dialCode {
                titleLabel.text = "Enter the code we sent to \(dia + " " + phone)"
            }
        case .name:
            titleLabel.text = "HI! \n What's your name?"
        case .birthday:
            titleLabel.text = "HI Jimmy \n When's your Birthday?"
        case .gender:
            titleLabel.text = "Which gender do you identify as?"
        }
    }
    
    private func editViewFrame() -> CGRect {
        let x = 0.0
        let y = titleLabel.frame.maxY
        let width = self.width
        let height = self.height - y
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func setupPhoneEditView() {
        let phoneEditView = PhoneEditView(frame: editViewFrame())
        phoneEditView.tag = SignupEditType.phone.rawValue
        addSubview(phoneEditView)
        editViews.append(phoneEditView)
        
        phoneEditView.textChanged = { [unowned self] text in
            phone = text
            if let handler = self.editChanged {
                handler(.phone, text)
            }
        }
        
        phoneEditView.pickCountryHandler = { [unowned self] in
            if let handler = self.clickHandler {
                handler(.countryPick)
            }
        }
    }
    
    private func setupCodeEditView() {
        let codeEditView = CodeEditView(frame: editViewFrame())
        codeEditView.tag = SignupEditType.code.rawValue
        addSubview(codeEditView)
        editViews.append(codeEditView)
        
        codeEditView.textChanged = { [unowned self] text in
            if let handler = self.editChanged {
                handler(.code, text)
            }
        }
        
        codeEditView.resetTimerHandler = { [unowned self] in
            if let handler = self.clickHandler {
                handler(.resetTimer)
            }
        }
    }
    
    private func setupNameEditView() {
        let nameEditView = NameEditView(frame: editViewFrame())
        nameEditView.tag = SignupEditType.name.rawValue
        nameEditView.isHidden = true
        addSubview(nameEditView)
        editViews.append(nameEditView)
        
        nameEditView.textChanged = { [unowned self] text in
            if let handler = self.editChanged {
                handler(.name, text)
            }
        }
    }
    
    private func setupBirthdayEditView() {
        let birthdayEditView = BirthdayEditView(frame: editViewFrame())
        birthdayEditView.tag = SignupEditType.birthday.rawValue
        birthdayEditView.isHidden = true
        addSubview(birthdayEditView)
        editViews.append(birthdayEditView)
        
        birthdayEditView.textChanged = { [unowned self] text in
            if let handler = self.editChanged {
                handler(.birthday, text)
            }
        }
    }
    
    private func setupGenderEditView() {
        let genderEditView = GenderEditView(frame: editViewFrame())
        genderEditView.tag = SignupEditType.gender.rawValue
        genderEditView.isHidden = true
        addSubview(genderEditView)
        editViews.append(genderEditView)
        
        genderEditView.textChanged = { [unowned self] text in
            if let handler = self.editChanged {
                handler(.gender, text)
            }
        }
    }
    
    private func updateEditView() {
        for editView in editViews {
            editView.isHidden = (editView.tag != type.rawValue)
        }
    }
    
}

// MARK: - 手机号输入页面
fileprivate class PhoneEditView: UIView, UITextFieldDelegate {
    
    fileprivate var textChanged: ((String?) -> Void)?
    fileprivate var pickCountryHandler: (() -> Void)?
    
    var message: String? {
        get { return messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    fileprivate var pickBtn: UIButton!
    fileprivate var editView: UITextField!
    fileprivate var messageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCountryPicker()
        setupEditView()
        setMessageLabel()
    }
    
    override var isHidden: Bool {
        didSet {
            if !isHidden {
                textFieldDidChangeSelection(editView)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        return editView.becomeFirstResponder()
    }
    
    private func setupCountryPicker() {
        pickBtn = UIButton(type: .custom)
        pickBtn.titleLabel?.font = UIFont(type: .montserratMedium, size: 15.rpx)
        let size = CGSize(width: 90.rpx, height: 50.rpx)
        let bg = UIImage(color: .white.withAlphaComponent(0.05), size: size)
        pickBtn.setBackgroundImage(bg, for: .normal)
        pickBtn.cornerRadius = size.height / 2.0
        pickBtn.frame = CGRect(origin: CGPoint(x: 15.rpx, y: 37.rpx), size: size)
        addSubview(pickBtn)
    }
    
    private func setupEditView() {
        editView = UITextField()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let font = UIFont(type: .montserratBlod, size: 25.rpx)
        let attr: [NSAttributedString.Key : Any] = [.font: font!,
                                                    .foregroundColor: UIColor.white.withAlphaComponent(0.3),
                                                    .paragraphStyle: paragraph]
        let attrString = NSMutableAttributedString(string: "Your phone")
        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        editView.attributedPlaceholder = attrString
        editView.keyboardType = .numberPad
        editView.keyboardAppearance = .dark
        editView.clearButtonMode = .whileEditing
        editView.textColor = .white
        editView.font = font
        editView.textAlignment = .left
        editView.tintColor = UIColor(hexString: "#5367E2")
        editView.delegate = self
        
        let x = pickBtn.frame.maxX + 20.rpx
        let y = pickBtn.y
        let width = ScreenWidth - x - 15.rpx
        let height = pickBtn.height
        editView.frame = CGRect(x: x, y: y, width: width, height: height)
        addSubview(editView)
        
        pickBtn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
    }
    
    @objc fileprivate func click(_ sender: UIButton) {
        if let handler = pickCountryHandler {
            handler()
        }
    }
    
    fileprivate func setCountryItem(to item: CountryItem) {
        let image = UIImage(named: item.code, in: Bundle.main, with: nil)?.scaled(toWidth: 15.rpx)
        pickBtn.setImageForAllStates(image!)
        pickBtn.setTitleForAllStates(item.dialCode)
        pickBtn.centerTextAndImage(spacing: 4.rpx)
    }
    
    fileprivate func setMessageLabel() {
        messageLabel = UILabel().then {
            $0.textColor = UIColor(hexString: "#FF552E")
            $0.font = UIFont(type: .montserratRegular, size: 13.rpx)
            $0.textAlignment = .center
            let height = String.singleLineHeight(font: $0.font)
            let x = 15.rpx
            let y = self.height - height - 20.rpx
            let width = self.width - x * 2
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        addSubview(messageLabel)
    }
    
    // MARK: - UITextFieldDelegate
    
    fileprivate func textFieldDidChangeSelection(_ textField: UITextField) {
        if let handler = textChanged {
            handler(textField.text)
        }
    }
    
}

// MARK: - 验证码输入页面
fileprivate class CodeEditView: UIView, UITextFieldDelegate {
    
    fileprivate var textChanged: ((String?) -> Void)?
    fileprivate var resetTimerHandler: (() -> Void)?

    fileprivate var timerbtn: UIButton!
    fileprivate var editViews: [UITextField]!
    fileprivate var timer: Task!
    
    private var currentEditView: UITextField!
    private let interval: Int = 60
    
    override var isHidden: Bool {
        didSet {
            if !isHidden {
                currentEditView.becomeFirstResponder()
                textFieldDidChangeSelection(currentEditView)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCodeViews(count: 4)
        setupTimerBtn()
    }
    
    deinit {
        if timer != nil {
            timer.removeFromTaskCenter()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCodeViews(count: Int) {
        editViews = [UITextField]()
        let spacing = 10.rpx
        let width = 76.rpx
        let height = 50.rpx
        let x = (self.width - width * Double(count) - spacing * Double(count - 1)) / 2.0
        let y = 38.rpx
        let moveX = width + spacing
        for i in 0..<count {
            let rx = x + moveX * i.double
            let view = textField(frame: CGRect(x: rx, y: y, width: width, height: height))
            view.tag = i
            addSubview(view)
            editViews.append(view)
        }
        currentEditView = editViews.first!
    }
    
    private func textField(frame: CGRect) -> UITextField {
        let textField = UITextField(frame: frame)
        textField.backgroundColor = .white.withAlphaComponent(0.05)
        textField.cornerRadius = textField.size.height / 2.0
        textField.keyboardType = .numberPad
        textField.keyboardAppearance = .dark
        textField.tintColor = .clear
        textField.textAlignment = .center
        textField.textColor = .white
        textField.font = UIFont(type: .montserratBlod, size: 25.rpx)
        textField.delegate = self
        return textField
    }
    
    private func setupTimerBtn() {
        timerbtn = UIButton(type: .custom)
        timerbtn.isEnabled = false
        setTimerTitle("Resend in \(interval)s", size: 12.rpx, color: .white.withAlphaComponent(0.5), state: .disabled)
        setTimerTitle("Resend", size: 14.rpx, color: .white, state: .normal)
        setTimerTitle("Resend", size: 14.rpx, color: .white.withAlphaComponent(0.5), state: .highlighted)
        timerbtn.x = editViews.first!.x
        timerbtn.y = editViews.first!.frame.maxY + 21.rpx
        timerbtn.height = 17.rpx
        timerbtn.width = timerbtn.attributedTitle(for: .disabled)!.width(containerHeight: timerbtn.height)
        addSubview(timerbtn)
        timerbtn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
    }
    
    fileprivate func resetTimer() {
        if timer != nil {
            timer.removeFromTaskCenter()
        }
        setTimerTitle("Resend in \(interval)s", size: 12.rpx, color: .white.withAlphaComponent(0.5), state: .disabled)
        timerbtn.isEnabled = false
        timerbtn.width = timerbtn.attributedTitle(for: .disabled)!.width(containerHeight: timerbtn.height)
        createTimer()
    }
    
    private func createTimer() {
        var seconds = interval
        let until = Date() + 61.seconds
        timer = Plan.every(1.second).until(until).do { [unowned self] in
            seconds -= 1
            self.timerbtn.isEnabled = (seconds == 0)
            setTimerTitle("Resend in \(seconds)s", size: 12.rpx, color: .white.withAlphaComponent(0.5), state: .disabled)
            let state: UIControl.State = self.timerbtn.isEnabled ? .normal : .disabled
            timerbtn.width = timerbtn.attributedTitle(for: state)!.width(containerHeight: timerbtn.height)
        }
    }
    
    private func setTimerTitle(_ title: String, size: Double, color: UIColor, state: UIControl.State) {
        let style = Style {
            $0.alignment = .left
            $0.font = UIFont(type: .montserratLight, size: size)
            $0.color = color
        }
        let title = title.set(style: style)
        timerbtn.setAttributedTitle(title, for: state)
    }
    
    @objc private func click(_ sender: UIButton) {
        if let handler = resetTimerHandler {
            handler()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    fileprivate func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 0 {
            if textField.isEmpty { return true }
            let index = textField.tag + 1
            if index >= editViews.count { return false }
            let next = editViews[index]
            next.text = string
            next.becomeFirstResponder()
            currentEditView = next
            return true
        }
        
        // delete
        textField.text = ""
        let index = textField.tag - 1
        if index < 0 { return false }
        let prevous = editViews[index]
        prevous.becomeFirstResponder()
        currentEditView = prevous
        return false
    }
    
    fileprivate func textFieldDidChangeSelection(_ textField: UITextField) {
        var code = ""
        for editView in editViews {
            guard let text = editView.text else { continue }
            code.append(text)
        }
        if let handler = textChanged { handler(code) }
    }
    
}

// MARK: - 用户姓名输入页面
fileprivate class NameEditView: UIView, UITextFieldDelegate {
    
    fileprivate var textChanged: ((String?) -> Void)?
    
    fileprivate var editView: UITextField!
    
    override var isHidden: Bool {
        didSet {
            if !isHidden {
                editView.becomeFirstResponder()
                textFieldDidChangeSelection(editView)
            }
        }
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupNameView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNameView() {
        editView = UITextField()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let font = UIFont(type: .montserratBlod, size: 25.rpx)
        let attr: [NSAttributedString.Key : Any] = [.font: font!,
                                                    .foregroundColor: UIColor.white.withAlphaComponent(0.3),
                                                    .paragraphStyle: paragraph]
        let attrString = NSMutableAttributedString(string: "Your name")
        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        editView.attributedPlaceholder = attrString
        editView.keyboardType = .namePhonePad
        editView.keyboardAppearance = .dark
        editView.clearButtonMode = .whileEditing
        editView.tintColor = UIColor(hexString: "#5367E2")
        editView.textAlignment = .left
        editView.textColor = .white
        editView.font = font
        editView.delegate = self
        
        let x = 22.rpx
        let y = 48.rpx
        let width = self.width - x * 2
        let height = 47.rpx
        editView.frame = CGRect(x: x, y: y, width: width, height: height)
        addSubview(editView)
    }
    
    // MARK: - UITextFieldDelegate
    
    fileprivate func textFieldDidChangeSelection(_ textField: UITextField) {
        if let handler = textChanged { handler(textField.text) }
    }
        
}

// MARK: - 用户生日输入页面
fileprivate class BirthdayEditView: UIView, UITextFieldDelegate {
        
    fileprivate var textChanged: ((String?) -> Void)?
    
    fileprivate var editViews: [SignupTextField]!

    private var currentEditView: SignupTextField!
    private lazy var attrs: [NSAttributedString.Key : Any] = {
        let font = UIFont(type: .montserratBlod, size: 25.rpx)
        let color = UIColor.white.withAlphaComponent(0.3)
        let attr: [NSAttributedString.Key : Any] = [.font: font!,
                                                    .foregroundColor: color]
        return attr
    }()

    override var isHidden: Bool {
        didSet {
            if !isHidden {
                currentEditView.becomeFirstResponder()
                textFieldDidChangeSelection(currentEditView)
            } else {
                currentEditView.resignFirstResponder()
            }
        }
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        editViews = [SignupTextField]()
        
        let year = "YYYY"
        let yearX = 20.rpx
        let yearY = 48.rpx
        let yearH = 35.rpx
        let yearW = year.width(attributes: attrs, containerHeight: yearH)
        let yearFrame = CGRect(x: yearX, y: yearY, width: yearW, height: yearH)
        let yearEditView = textField(frame: yearFrame, placeholder: year)
        yearEditView.tag = 0
        addSubview(yearEditView)
        editViews.append(yearEditView)
        
        let month = "MM"
        let monthX = yearEditView.frame.maxX + 5.rpx
        let monthY = yearEditView.y
        let monthH = yearEditView.height
        let monthW = month.width(attributes: attrs, containerHeight: monthH)
        let monthFrame = CGRect(x: monthX, y: monthY, width: monthW, height: monthH)
        let monthEditView = textField(frame: monthFrame, placeholder: month, offset: UIOffset(horizontal: 5, vertical: 0))
        monthEditView.tag = 1
        addSubview(monthEditView)
        editViews.append(monthEditView)
        
        let day = "DD"
        let dayX = monthEditView.frame.maxX + 5.rpx
        let dayY = yearEditView.y
        let dayH = yearEditView.height
        let dayW = day.width(attributes: attrs, containerHeight: dayH)
        let dayFrame = CGRect(x: dayX, y: dayY, width: dayW, height: dayH)
        let dayEditView = textField(frame: dayFrame, placeholder: day)
        dayEditView.tag = 2
        addSubview(dayEditView)
        editViews.append(dayEditView)
        
        currentEditView = yearEditView
    }
    
    private func textField(frame: CGRect, placeholder: String, offset: UIOffset = .zero) -> SignupTextField {
        let textField = SignupTextField(frame: frame, offset: offset)
        textField.keyboardType = .numberPad
        textField.keyboardAppearance = .dark
        textField.tintColor = UIColor(hexString: "#5367E2")
        textField.textAlignment = .left
        textField.textColor = .white
        textField.font = UIFont(type: .montserratBlod, size: 25.rpx)
        textField.delegate = self
        let attrString = NSMutableAttributedString(string: placeholder)
        attrString.addAttributes(attrs, range: NSRange(location: 0, length: attrString.length))
        textField.attributedPlaceholder = attrString
        return textField
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 0 {
            if textField.tag == 0, let text = textField.text, text.length < 4 { return true } // year
            if textField.tag == 1, let text = textField.text, text.length < 2 { return true } // month
            if textField.tag == 2, let text = textField.text, text.length < 2 { return true } // day

            let index = textField.tag + 1
            if index >= editViews.count { return false }
            
            let next = editViews[index]
            next.text = string
            next.becomeFirstResponder()
            currentEditView = next
            
            return true
        }
        
        // delete
        if let text = textField.text, text.length > 1 { return true }
        
        textField.text = ""
        
        let index = textField.tag - 1
        if index < 0 { return false }
        
        let prevous = editViews[index]
        prevous.becomeFirstResponder()
        currentEditView = prevous
        
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, text.length > 0 {
            textField.font =  UIFont(type: .montserratBlod, size: 27.rpx)
        } else {
            textField.font = UIFont(type: .montserratBlod, size: 25.rpx)
        }
                
        var birthday = ""
        for editView in editViews {
            guard let text = editView.text else { continue }
            if birthday.length > 0 {
                birthday.append("-")
            }
            birthday.append(text)
        }
        if let handler = textChanged { handler(birthday) }
        
    }
    
}

// MARK: - 用户性别输入页面
fileprivate class GenderEditView: UIView {
    
    fileprivate var textChanged: ((String?) -> Void)?
    
    fileprivate var maleBtn: UIButton!
    fileprivate var femaleBtn: UIButton!
    
    fileprivate var gender: String {
        didSet {
            if let handlder = textChanged {
                handlder(gender)
            }
        }
    }
    
    private let male = "Male"
    private let female = "Female"
 
    override init(frame: CGRect) {
        self.gender = male
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        let size = CGSize(width: 157.rpx, height: 60.rpx)
        
        maleBtn = genderBtn()
        maleBtn.isSelected = true
        let maleBtnX = (self.width - size.width * 2) / 3.0
        let maleBtnY = 35.rpx
        maleBtn.frame = CGRect(x: maleBtnX, y: maleBtnY, width: size.width, height: size.height)
        maleBtn.cornerRadius = size.height / 2.0
        maleBtn.setTitleForAllStates(male)
        addSubview(maleBtn)
        
        femaleBtn = genderBtn()
        femaleBtn.isSelected = false
        let femaleBtnX = maleBtn.frame.maxX + maleBtnX
        let femaleBtnY = maleBtnY
        femaleBtn.frame = CGRect(x: femaleBtnX, y: femaleBtnY, width: size.width, height: size.height)
        femaleBtn.cornerRadius = size.height / 2.0
        femaleBtn.setTitleForAllStates(female)
        addSubview(femaleBtn)
    }
    
    fileprivate func genderBtn() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "gender_btn_bg_normal"), for: .normal)
        btn.setBackgroundImage(UIImage(named: "gender_btn_bg_normal"), for: [.normal, .highlighted])
        btn.setBackgroundImage(UIImage(named: "gender_btn_bg_selected"), for: .selected)
        btn.setBackgroundImage(UIImage(named: "gender_btn_bg_selected"), for: [.selected, .highlighted])
        btn.setTitleColor(.white, for: .selected)
        btn.setTitleColor(.white, for: [.selected, .highlighted])
        btn.setTitleColor(UIColor(hexString: "#B383FF"), for: .normal)
        btn.setTitleColor(UIColor(hexString: "#B383FF"), for: [.normal, .highlighted])
        btn.titleLabel?.font = UIFont(type: .montserratBlod, size: 20.rpx)
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        return btn
    }
    
    @objc fileprivate func click(_ sender: UIButton) {
        maleBtn.isSelected.toggle()
        femaleBtn.isSelected.toggle()
        
        var text = ""
        if maleBtn.isSelected {
            text = maleBtn.titleForNormal!
        } else if femaleBtn.isSelected {
            text = femaleBtn.titleForNormal!
        }
        gender = text
    }
    
}
