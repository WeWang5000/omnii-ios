//
//  MomentsInputMindController.swift
//  omnii
//
//  Created by huyang on 2023/5/21.
//

import UIKit
import CommonUtils

class MomentsInputMindController: UIViewController {
        
    private var navigataionBar: NavigationBar!
    private var textView: UITextView!
    private var placeholderLabel: UILabel!
    private var countLabel: UILabel!
    
    private var placeholder: String
    
    required init(placeholder: String = "") {
        self.placeholder = placeholder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        setupViews()
        
        navigataionBar.backAction = { [unowned self] in
            self.dismiss(animated: true)
        }
        
        navigataionBar.rightItemAction = { [unowned self] in
            self.doneAction()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }

    func doneAction() {
        if textView.text.isEmpty { return }
        textView.resignFirstResponder()
        self.navigationController?.pushViewController(MomentsEditingController(mind: textView.text))
    }
    
}

extension MomentsInputMindController: UITextViewDelegate {
    
    private func setupViews() {
        
        navigataionBar = NavigationBar().then {
            $0.backgroundColor = .black
            $0.updateRightButton(title: "Done")
        }
        
        textView = UITextView().then {
            $0.backgroundColor = .black
            $0.tintColor = UIColor(hexString: "#5367E2")
            $0.textColor = .white
            $0.font = UIFont(type: .montserratBlod, size: 25.rpx)
            $0.returnKeyType = .done
            $0.delegate = self
            let x = 22.rpx
            let y = navigataionBar.frame.maxY
            let width = ScreenWidth - x * 2
            let height = ScreenHeight - navigataionBar.height - 325.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        placeholderLabel = UILabel().then {
            $0.text = placeholder
            $0.textColor = .white.withAlphaComponent(0.3)
            let font = textView.font
            $0.font = font!
            $0.numberOfLines = 0
            $0.textAlignment = .left
            let origin = CGPoint(x: 5.rpx, y: 8.rpx)
            let width = textView.width
            let attrs: [NSAttributedString.Key : Any] = [.font: font!]
            let height = placeholder.height(attributes: attrs, containerWidth: width)
            $0.frame = CGRect(origin: origin, size: CGSize(width: width, height: height))
        }
        
        countLabel = UILabel().then {
            $0.text = "0/100"
            $0.textColor = .white
            $0.font = UIFont(type: .montserratRegular, size: 13)
            $0.textAlignment = .right
            let size = CGSize(width: 100.0, height: 15.0)
            let x = textView.width - size.width - 10.rpx
            let y = textView.height - size.height - 10.rpx
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        }
        
        view.addSubview(navigataionBar)
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        textView.addSubview(countLabel)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        countLabel.text = "\(textView.text.count)/100"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            doneAction()
            return false
        }
        
        if text.length > 0 {
            if textView.text.length + text.length > 100 {
                return false
            }
        }
        
        return true
    }
    
}
