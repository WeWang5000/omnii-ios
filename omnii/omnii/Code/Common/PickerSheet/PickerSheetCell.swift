//
//  PickerSheetCell.swift
//  omnii
//
//  Created by huyang on 2023/5/29.
//

import UIKit
import Combine
import CombineExt
import CommonUtils

final class PickerSheetCell: UICollectionViewCell {
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var subTitle: String? {
        get { return subTitlelabel.text }
        set { subTitlelabel.text = newValue }
    }
    
    private var isPicked: Bool {
        get { return checkButton.isSelected }
        set { checkButton.isSelected = newValue }
    }
    
    override var isHighlighted: Bool {
        didSet {
            checkButton.isHighlighted = isHighlighted
            titleLabel.alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    private var checkButton: UIButton!
    private var titleLabel: UILabel!
    private var subTitlelabel: UILabel!
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewModel(_ viewModel: PickerViewModel) {
        title = viewModel.entity.title
        subTitle = viewModel.entity.subTitle
        isPicked = viewModel.entity.isPicked
        
        viewModel.pickPublisher.assign(to: \.isPicked, on: self, ownership: .weak).store(in: &cancellables)
    }
    
    private func setupViews() {
        
        checkButton = UIButton(imageName: "moments_check").then {
            $0.isUserInteractionEnabled = false
            let size = CGSize(width: 22.rpx, height: 22.rpx)
            let x = ScreenWidth - 31.rpx - size.width
            let y = (52.rpx - size.height) / 2.0
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        titleLabel = UILabel().then {
            let font = UIFont(type: .montserratRegular, size: 17.rpx)
            $0.textColor = .white
            $0.font = font
            $0.textAlignment = .left
            let x = 31.rpx
            let width = 150.rpx
            let height = String.singleLineHeight(font: font!)
            let y = (52.rpx - height) / 2.0
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        subTitlelabel = UILabel().then {
            let font = UIFont(type: .montserratRegular, size: 12.rpx)
            $0.textColor = .white.withAlphaComponent(0.4)
            $0.font = font
            $0.textAlignment = .right
            let x = titleLabel.frame.maxX
            let width = ScreenWidth - x - 56.rpx
            let height = String.singleLineHeight(font: font!)
            let y = (52.rpx - height) / 2.0
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
                
        addSubviews([checkButton, titleLabel, subTitlelabel])
    }
    
}
