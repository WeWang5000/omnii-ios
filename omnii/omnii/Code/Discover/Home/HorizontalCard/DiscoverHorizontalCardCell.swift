//
//  DiscoverHorizontalCardCell.swift
//  omnii
//
//  Created by huyang on 2023/6/3.
//

import UIKit

final class DiscoverHorizontalCardCell<T: DiscoverCardView>: UICollectionViewCell {
    
    var tapHandler: ((DiscoverCardTapEvents) -> Void)? {
        didSet { cardView.tapHandler = tapHandler }
    }
    
    private var cardView: T!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: DiscoverRecordViewModel) {
        cardView.bindViewModel(viewModel)
    }
    
    private func setupViews() {
        cardView = T(scale: 190.0 / 355.0)
        addSubview(cardView)
    }
    
}
