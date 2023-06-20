//
//  UIButton+Common.swift
//  omnii
//
//  Created by huyang on 2023/5/9.
//

import UIKit


public extension UIButton {
    
    enum ImageAlign {
        case left(Double)
        case right(Double)
        case top(Double)
        case bottom(Double)
    }
    
    convenience init(imageName: String) {
        self.init(type: .custom)
        setStateImage(with: imageName)
    }
    
    func setStateImage(with imageName: String) {
        if let image = UIImage(named: "\(imageName)_normal") {
            self.setImage(image, for: .normal)
        }
        if let image = UIImage(named: "\(imageName)_highlight") {
            self.setImage(image, for: [.normal, .highlighted])
        } else {
            if let image = UIImage(named: "\(imageName)_normal")?.alpha(0.7) {
                self.setImage(image, for: [.normal, .highlighted])
            }
        }
        if let image = UIImage(named: "\(imageName)_selected") {
            self.setImage(image, for: .selected)
        }
        if let image = UIImage(named: "\(imageName)_selected_highlight") {
            self.setImage(image, for: [.selected, .highlighted])
        } else {
            if let image = UIImage(named: "\(imageName)_selected")?.alpha(0.7) {
                self.setImage(image, for: [.selected, .highlighted])
            }
        }
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func removeImageForAllStates() {
        [.normal, .selected, .highlighted, .disabled].forEach {
            setImage(nil, for: $0)
        }
    }
    
    func removeTitleForAllStates() {
        [.normal, .selected, .highlighted, .disabled].forEach {
            setTitle(nil, for: $0)
        }
    }
    
    func setImageAlign(to align: ImageAlign) {
        switch align {
        case .left(let spacing):
            alignHorizontal(spacing: spacing)
        case .right(let spacing):
            alignHorizontal(imageLeft: false, spacing: spacing)
        case .top(let spacing):
            alignVertical(spacing: spacing)
        case .bottom(let spacing):
            alignVertical(imageTop: false, spacing: spacing)
        }
    }
    
    private func alignHorizontal(imageLeft: Bool = true, spacing: CGFloat) {
        
        guard let imageSize = imageView?.image?.size,
              let text = titleLabel?.text,
              let font = titleLabel?.font
        else { return }
        
        let titleSize = text.size(withAttributes: [.font: font])
        
        if imageLeft {
            
            let edgeOffset = spacing / 2.0
            titleEdgeInsets = UIEdgeInsets(top: .zero, left: edgeOffset, bottom: .zero, right: -edgeOffset)
            imageEdgeInsets = UIEdgeInsets(top: .zero, left: -edgeOffset, bottom: .zero, right: edgeOffset)
            contentEdgeInsets = UIEdgeInsets(top: .zero, left: -edgeOffset, bottom: .zero, right: -edgeOffset)
            
        } else {
            
            let titleOffset = imageSize.width + spacing / 2.0
            titleEdgeInsets = UIEdgeInsets(top: .zero, left: -titleOffset, bottom: .zero, right: titleOffset)

            let imageOffset = titleSize.width + spacing / 2.0
            imageEdgeInsets = UIEdgeInsets(top: .zero, left: imageOffset, bottom: .zero, right: -imageOffset)

            let edgeOffset = spacing / 2.0
            contentEdgeInsets = UIEdgeInsets(top: .zero, left: edgeOffset, bottom: .zero, right: edgeOffset)
            
        }
        
        
    }
    
    private func alignVertical(imageTop: Bool = true, spacing: CGFloat) {
        
        guard let imageSize = imageView?.image?.size,
              let text = titleLabel?.text,
              let font = titleLabel?.font
        else { return }
        
        let titleSize = text.size(withAttributes: [.font: font])
        
        if imageTop  {
            
            let titleOffset = imageSize.height + spacing
            titleEdgeInsets = UIEdgeInsets(top: titleOffset, left: -imageSize.width, bottom: .zero, right: .zero)

            let imageOffset = titleSize.height + spacing
            imageEdgeInsets = UIEdgeInsets(top: -imageOffset, left: .zero, bottom: .zero, right: -titleSize.width)

            let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
            contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: .zero, bottom: edgeOffset, right: .zero)
            
        } else {
            
            let titleOffset = imageSize.height + spacing
            titleEdgeInsets = UIEdgeInsets(top: -titleOffset, left: -imageSize.width, bottom: .zero, right: .zero)

            let imageOffset = titleSize.height + spacing
            imageEdgeInsets = UIEdgeInsets(top: imageOffset, left: .zero, bottom: .zero, right: -titleSize.width)

            let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
            contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: .zero, bottom: edgeOffset, right: .zero)
            
        }
        
    }
    
}
