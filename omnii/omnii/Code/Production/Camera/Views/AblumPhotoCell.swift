//
//  AblumPhotoCell.swift
//  omnii
//
//  Created by huyang on 2023/5/9.
//

import UIKit

class AblumPhotoCell: UICollectionViewCell {
    
    private(set) var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        imageView = UIImageView().then{
            $0.contentMode = .scaleAspectFill
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            $0.cornerRadius = 4.0
        }
        
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    
    func bindModel(_ model: PhotoModel) {
        model.loadThumbnail(size: CGSize(width: size.width * 2, height: size.height * 2)) { [unowned self] image in
            if let image = image {
                self.imageView.image = image
            } else {
                self.clear()
            }
        }
    }
    
    func clear() {
        imageView.image = nil
    }
    
}
