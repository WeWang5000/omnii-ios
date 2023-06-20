//
//  CountryCodeCell.swift
//  omnii
//
//  Created by huyang on 2023/4/23.
//

import UIKit

fileprivate struct Layout {
    
    fileprivate let image = Image()
    struct Image {
        let x = 16.rpx
        let width = 28.rpx
        let height = 22.rpx
    }
    
    fileprivate let name = Name()
    struct Name {
        let width = 225.rpx
        let height = 22.rpx
        let leftMargin = 10.rpx
    }
    
    fileprivate let code = Code()
    struct Code {
        let height = 22.rpx
        let rightMargin = 18.rpx
    }
    
    fileprivate let separator = Separator()
    struct Separator {
        let height = 0.5
    }
    
}

final class CountryCodeCell: UICollectionViewCell {
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var name: String? {
        get { return nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    var code: String? {
        get { return codeLabel.text }
        set { codeLabel.text = newValue }
    }
    
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var codeLabel: UILabel!
    
    private let layout = Layout()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor(hexString: "#747480")?.withAlphaComponent(0.18)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        let y = (self.height - layout.image.height) / 2.0
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: layout.image.x, y: y, width: layout.image.width, height: layout.image.height)
        
        let separator = UIView()
        separator.backgroundColor = UIColor(hexString: "#38383A")
        separator.frame = CGRect(x: 0, y: self.height - layout.separator.height, width: self.width, height:  layout.separator.height)
        
        nameLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 17.rpx)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.frame = CGRect(x: imageView.frame.maxX + layout.name.leftMargin, y: y, width: layout.name.width, height: layout.name.height)
        
        codeLabel = UILabel()
        codeLabel.textAlignment = .right
        codeLabel.adjustsFontSizeToFitWidth = true
        codeLabel.textColor = .white.withAlphaComponent(0.6)
        codeLabel.font = UIFont.systemFont(ofSize: 17.rpx)
        codeLabel.frame = CGRect(x: nameLabel.frame.maxX, y: y, width: self.width - nameLabel.frame.maxX - layout.code.rightMargin, height: layout.code.height)
        
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(codeLabel)
        addSubview(separator)
    }
    
}
