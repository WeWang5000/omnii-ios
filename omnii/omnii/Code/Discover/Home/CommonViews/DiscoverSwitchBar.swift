//
//  DiscoverSwitchBar.swift
//  omnii
//
//  Created by huyang on 2023/6/4.
//

import UIKit
import CommonUtils
import SwiftRichString

final class DiscoverSwitchBar: UIView {
    
    var action: ((String) -> Void)?
    
    private let titles: [String]
    private let fontSize: Double
    
    private var selectedButton: UIButton?
    
    required init(titles: [String], fontSize: Double) {
        self.titles = titles
        self.fontSize = fontSize
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectTitle(_ title: String) {
        for (index, str) in titles.enumerated() {
            guard title == str else { continue }
            guard let button = viewWithTag(index) as? UIButton else { return }
            guard !button.isSelected, let current = selectedButton else { return }
            current.isSelected = false
            button.isSelected = true
            selectedButton = button
        }
    }
    
    private func setupViews() {
        
        let diff = 15.rpx / 2.0
        let height = 20.rpx
        var width = diff

        for (index, title) in titles.enumerated() {
            
            let button = UIButton(type: .custom).then {
                $0.tag = index
                let style_normal = Style {
                    $0.color = Color(hexString: "#FFFFFF", transparency: 0.5)
                    $0.font = UIFont(type: .montserratRegular, size: self.fontSize)
                }
                let style_selected = Style {
                    $0.color = Color(hexString: "#FFFFFF")
                    $0.font = UIFont(type: .montserratBlod, size: self.fontSize)
                }
                let title_normal = title.set(style: style_normal)
                let title_selected = title.set(style: style_selected)
                $0.setAttributedTitle(title_normal, for: .normal)
                $0.setAttributedTitle(title_normal, for: [.normal, .highlighted])
                $0.setAttributedTitle(title_selected, for: .selected)
                $0.setAttributedTitle(title_selected, for: [.selected, .highlighted])
                
                let size = title_selected.size()
                let x = width
                let y = (height - size.height) / 2.0
                $0.frame = CGRect(x: x, y: y, size: size)
                
                width += (size.width + diff)
            }
            
            if title == titles.first {
                button.isSelected = true
                selectedButton = button
            }
            
            button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
            
            addSubview(button)
        }
        
        self.size = CGSize(width: width, height: height)
    }
    
    @objc private func click(_ sender: UIButton) {
        guard !sender.isSelected, let current = selectedButton else { return }
        current.isSelected = false
        sender.isSelected = true
        selectedButton = sender
        
        if let title = sender.attributedTitle(for: .normal) {
            action?(title.string)
        }
    }
    
}
