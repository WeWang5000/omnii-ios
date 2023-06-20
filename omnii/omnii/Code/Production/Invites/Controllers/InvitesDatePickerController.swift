//
//  InvitesDatePickerController.swift
//  omnii
//
//  Created by huyang on 2023/5/25.
//

import UIKit
import CommonUtils

class InvitesDatePickerController: UIViewController {
    
    var popHandler: ((Date, GeoModel) -> Void)?
    
    enum DatePickerStyle {
        case done
        case next
    }
    
    var selectedHandler: ((Date) -> Void)?
    
    private var navigationBar: NavigationBar!
    private var pickerView: InvitesDatePicker!
    
    private let dateItems: [InvitesDateItem]
    private let style: DatePickerStyle
    private let isShowProgressView: Bool
    
    required init(style: DatePickerStyle, dateItems: [InvitesDateItem], showProgressView: Bool = true) {
        self.style = style
        self.dateItems = dateItems
        self.isShowProgressView = showProgressView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        setupViews()
        
        navigationBar.backAction = { [unowned self] in
            if self.style == .done {
                self.dismiss(animated: true)
            } else {
                self.navigationController?.popViewController()
            }
        }
        
    }
    
    private func setupViews() {
        
        navigationBar = NavigationBar().then {
            $0.backgroundColor = .black
            $0.backStyle = (style == .done) ? .close : .back
        }
        
        let progressView1 = UIView().then {
            $0.isHidden = !self.isShowProgressView
            $0.backgroundColor = .white
            let width = 80.rpx
            let height = 4.0
            let x = (ScreenWidth - width * 2 - 5.rpx) / 2.0
            let y = (navigationBar.height - ScreenFit.statusBarHeight - height) / 2.0 + ScreenFit.statusBarHeight
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        let progressView2 = UIView().then {
            $0.isHidden = !self.isShowProgressView
            $0.backgroundColor = .white.withAlphaComponent(0.2)
            let size = progressView1.size
            let x = progressView1.frame.maxX + 5.rpx
            let y = progressView1.y
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        let titleLabel = UILabel().then {
            $0.isHidden = !self.isShowProgressView
            $0.text = "Set Start Time"
            $0.textColor = .white
            $0.font = UIFont(type: .montserratExtraBold, size: 32.rpx)
            let x = 20.rpx
            let y = navigationBar.frame.maxY
            let size = $0.text!.size(font: $0.font)
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        pickerView = InvitesDatePicker(items: dateItems).then {
            let x = 0.0
            let y = titleLabel.frame.maxY + 10.rpx
            $0.frame = CGRect(x: x, y: y, width: ScreenWidth, height: 300.rpx)
        }
        
        let nextButton = UIButton(type: .custom).then {
            let size = CGSize(width: 320.rpx, height: 55.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = ScreenHeight - ScreenFit.safeBottomHeight - size.height
            $0.frame = CGRect(x: x, y: y, size: size)
            if style == .done {
                $0.whiteBackgroundStyle(title: "Done")
            } else {
                $0.whiteBackgroundStyle(title: "Next")
            }
        }
        
        nextButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubview(navigationBar)
        view.addSubview(titleLabel)
        view.addSubview(pickerView)
        view.addSubview(nextButton)
        navigationBar.addSubviews([progressView1, progressView2])
    }

    @objc private func click(_ sender: UIButton) {
        let dateEntity = pickerView.selectedDate
        let dateStr = "\(dateEntity.year)-\(dateEntity.month)-\(dateEntity.day) \(dateEntity.hour):\(dateEntity.minute)"
        let date = dateStr.date(with: "yyyy-MM-dd HH:mm")!
        
        switch style {
        case .done:
            selectedHandler?(date)
            self.dismiss(animated: true)
        case .next:
            pushLocationController(time: date)
        }
        
    }
    
    private func pushLocationController(time: Date) {
        let vc = InvitesLocationController(date: time)
        vc.popHandler = popHandler
        self.navigationController?.pushViewController(vc)
    }
    
}



