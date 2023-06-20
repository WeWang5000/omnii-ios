//
//  KeyboardManager.swift
//  omnii
//
//  Created by huyang on 2023/5/25.
//

import UIKit

final class KeyboardManager {
    
    struct Info {
        let duration: TimeInterval
        let beginFrame: CGRect
        let endFrame: CGRect
    }
    
    enum Event {
        case willChangeFrame(Info)
        case willShow(Info)
        case didShow(Info)
        case willHide(Info)
        case didHide(Info)
    }
    
    var action: ((Event) -> Void)?
    
    func registerMonitor() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    func unregisterMonitor() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(_ node: Notification) {
        guard let info = node.userInfo else { return }
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let begin = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let end = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let item = Info(duration: duration, beginFrame: begin, endFrame: end)
        action?(.willChangeFrame(item))
    }
    
    @objc private func keyboardWillShow(_ node: Notification) {
        guard let info = node.userInfo else { return }
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let begin = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let end = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let item = Info(duration: duration, beginFrame: begin, endFrame: end)
        action?(.willShow(item))
    }
    
    @objc private func keyboardDidShow(_ node: Notification) {
        guard let info = node.userInfo else { return }
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let begin = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let end = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let item = Info(duration: duration, beginFrame: begin, endFrame: end)
        action?(.didShow(item))
    }
    
    @objc private func keyboardWillHide(_ node: Notification) {
        guard let info = node.userInfo else { return }
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let begin = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let end = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let item = Info(duration: duration, beginFrame: begin, endFrame: end)
        action?(.willHide(item))
    }
    
    @objc private func keyboardDidHide(_ node: Notification) {
        guard let info = node.userInfo else { return }
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let begin = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let end = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let item = Info(duration: duration, beginFrame: begin, endFrame: end)
        action?(.didHide(item))
    }
    
}
