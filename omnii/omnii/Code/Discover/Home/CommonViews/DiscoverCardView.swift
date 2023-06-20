//
//  DiscoverCardView.swift
//  omnii
//
//  Created by huyang on 2023/6/12.
//

import UIKit
import Combine
import CombineExt
import CommonUtils
import SwifterSwift

enum DiscoverCardTapEvents {
    case user       // 点击用户头像
    case more       // 点击更多按钮
    case like       // 点击喜欢按钮
    case comment    // 点击评论按钮
    
    case inquires   // 点击提问按钮 (invite card)
    case attending  // 点击已加入头像 (invite card)
    case ispace     // 点击进入ispace按钮 (invite card)
}

protocol DiscoverCardView: UIView {
        
    init(scale: Double)
    
    func bindViewModel(_ viewModel: DiscoverRecordViewModel)
 
    var tapHandler: ((DiscoverCardTapEvents) -> Void)? { set get }

}

class DiscoverBaseCardView: UIView, DiscoverCardView {
    
    var tapHandler: ((DiscoverCardTapEvents) -> Void)?
    var cancellables = Set<AnyCancellable>()
    
    let scale: Double
    private let contentSize = CGSize(width: 355.rpx, height: 631.rpx)
        
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    required init(scale: Double) {
        self.scale = scale
        super.init(frame: CGRect(origin: .zero, size: contentSize * scale))

        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: DiscoverRecordViewModel) {
        fatalError("Must Override")
    }
    
    func setupViews() {
        fatalError("Must Override")
    }
    
}
