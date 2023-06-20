//
//  BubbleTextContentView.swift
//  omnii
//
//  Created by huyang on 2023/5/12.
//

import UIKit
import CommonUtils

final public class BubbleTextContentView: UIView {
    
    public struct Configuration {
                
        public var textColor = UIColor.black
        public var textFont = UIFont(type: .montserratMedium, size: 12.0)!
        public var numberOfLines = 1
        public var lineSpacing = 3.0
        public var textEdgeInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
        public var maxWidth = 192.0
        
    }
    
    private var message: String!
    private var config: Configuration!
    
    required init(message: String, config: Configuration) {
        super.init(frame: .zero)
        
        self.message = message
        self.config = config
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


private extension BubbleTextContentView {
    
    func setupViews() {
        
        let label = UILabel().then {
            $0.textColor = config.textColor
            $0.font = config.textFont
            $0.numberOfLines = config.numberOfLines
        
            let font = config.textFont
            let color = config.textColor
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            if config.lineSpacing > 0 {
                paragraphStyle.lineSpacing = config.lineSpacing
            }
            let attrs: [NSAttributedString.Key : Any] = [.font: font,
                                                         .foregroundColor: color,
                                                         .paragraphStyle: paragraphStyle]
            
            let attString = NSAttributedString(string: message, attributes: attrs)
            
            $0.attributedText = attString
            
            let maxWidth = config.maxWidth - config.textEdgeInsets.horizontal
            var size = attString.boundingRect(with: CGSize(width: maxWidth, height: ScreenHeight),
                                              options: [.usesLineFragmentOrigin, .usesFontLeading],
                                              context: nil).size
            
            if config.numberOfLines > 0 {
                var textHeight = config.textFont.lineHeight * Double(config.numberOfLines)
                if config.numberOfLines > 1, config.lineSpacing > 0 {
                    textHeight += config.lineSpacing * Double(config.numberOfLines - 1)
                }
                
                size.height = min(textHeight, size.height)
                
            }
            
            let origin = CGPoint(x: config.textEdgeInsets.left, y: config.textEdgeInsets.top)
            $0.frame = CGRect(origin: origin, size: size)
            
        }
        
        addSubview(label)
        
        let width = ceil(label.size.width + config.textEdgeInsets.horizontal)
        let height = ceil(label.size.height + config.textEdgeInsets.vertical)
        self.size = CGSize(width: width, height: height)
    }
    
}
