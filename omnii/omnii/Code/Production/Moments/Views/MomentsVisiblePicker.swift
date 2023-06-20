//
//  MomentsVisiblePicker.swift
//  omnii
//
//  Created by huyang on 2023/5/17.
//

import UIKit
import CommonUtils

final class MomentsVisiblePicker: UIView {
    
    public enum PanGestureState {
        case began
        case changed(Double)
        case cancelled
        case ended
    }
    
    public enum VisibleState: String {
        case everyone       = "Everyone"
        case friendsOnly    = "Friends Only"
        case IncognitoMode  = "Incognito mode"
    }
    
    var pickHandler: ((VisibleState) -> Void)?
    var shareHandler: (() -> Void)?
    var panStateHandler: ((PanGestureState) -> Void)?
    
    var hasPanStarted = false
    var shouldPanFinish = false
    
    private var headerView: PickerHeaderView!
    private var selectedCell: MomentsVisiblePickerCell!
    private var friendsCell: MomentsVisiblePickerCell!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(hexString: "#151517")
        addPanGesture()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        self.y = ScreenHeight - self.height
    }
    
    func hide(progress: Double = 1.0) {
        let diff = self.height * (1 - progress)
        self.y = ScreenHeight - diff
    }
 
    func setFriendsCellSubTitle(to text: String?) {
        friendsCell.subTitle = text
    }
    
}


private extension MomentsVisiblePicker {
    
    func setupViews() {
        
        headerView = PickerHeaderView().then {
            $0.title = "Visible for 48hrs To"
            $0.titleLabel.font = UIFont(type: .montserratRegular, size: 18.rpx)
            let origin = CGPoint.zero
            let size = CGSize(width: ScreenWidth, height: 68.rpx)
            $0.frame = CGRect(origin: origin, size: size)
        }
        
        let everyCell = MomentsVisiblePickerCell().then {
            $0.title = VisibleState.everyone.rawValue
            $0.isSelected = true
            let y = headerView.frame.maxY
            let size = CGSize(width: ScreenWidth, height: 52.rpx)
            $0.frame = CGRect(origin: CGPoint(x: .zero, y: y), size: size)
        }
        
        selectedCell = everyCell
        
        friendsCell = MomentsVisiblePickerCell().then {
            $0.title = VisibleState.friendsOnly.rawValue
            let y = everyCell.frame.maxY
            let size = everyCell.size
            $0.frame = CGRect(origin: CGPoint(x: .zero, y: y), size: size)
        }
        
        let incognitoCell = MomentsVisiblePickerCell().then {
            $0.title = VisibleState.IncognitoMode.rawValue
            let y = friendsCell.frame.maxY
            let size = everyCell.size
            $0.frame = CGRect(origin: CGPoint(x: .zero, y: y), size: size)
        }
        
        let shareButton = UIButton(type: .custom).then {
            let size = CGSize(width: 320.rpx, height: 55.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = incognitoCell.frame.maxY + 10.rpx
            $0.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            $0.whiteBackgroundStyle(title: "Share")
        }
                
        everyCell.addTarget(self, action: #selector(pick), for: .touchUpInside)
        friendsCell.addTarget(self, action: #selector(pick), for: .touchUpInside)
        incognitoCell.addTarget(self, action: #selector(pick), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        addSubviews([headerView, everyCell, friendsCell, incognitoCell, shareButton])
    }
    
    @objc func pick(_ sender: MomentsVisiblePickerCell) {
        if selectedCell != sender {
            selectedCell.isSelected = false
            sender.isSelected = true
        }
        selectedCell = sender
        
        if let title = sender.title, let state = VisibleState(rawValue: title) {
            pickHandler?(state)
        }
    }
    
    @objc func click(_ sender: UIButton) {
        shareHandler?()
    }
    
}

// MARK: - pan gesture
private extension MomentsVisiblePicker {
    
    func addPanGesture() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let progress = calculateProgress(sender: sender) else { return }

        switch sender.state {
        case .began:
            hasPanStarted = true
            panStateHandler?(.began)
        case .changed:
            shouldPanFinish = progress > 0.3
            panStateHandler?(.changed(progress))
        case .cancelled:
            hasPanStarted = false
            panStateHandler?(.cancelled)
        case .ended:
            hasPanStarted = false
            shouldPanFinish ? panStateHandler?(.ended) : panStateHandler?(.cancelled)
        default:
            break
        }
    }
    
    func calculateProgress(sender: UIPanGestureRecognizer) -> CGFloat? {
        let translation = sender.translation(in: self)
        let verticalMovement = translation.y / self.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        return progress
    }
    
}
