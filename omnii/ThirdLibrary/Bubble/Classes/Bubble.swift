//
//  Bubble.swift
//  omnii
//
//  Created by huyang on 2023/5/11.
//

import UIKit


final public class Bubble {
    
    public enum ArrowDirection {
        case top        // 箭头指上
        case left       // 箭头指左
        case bottom     // 箭头指下
        case right      // 箭头指右
    }
    
    public enum OverlyTappedEvent {
        case invalid                // 拦截事件, bubble 不消失
        case dismiss                // 拦截事件, bubble 消失
        case propagate              // 传递事件, bubble 不消失
        case propagateAndDissmiss   // 传递事件, bubble 消失
    }
    
    public enum BackgroudStyle {
        case blur(Double)       // 毛玻璃 (半径)
        case color(UIColor)     // 纯色
    }
    
    public enum ActionEvent {
        case tapped             // 点击气泡
        case targetViewTapped   // 点击 targetView
        case willDismiss        // 消失, 动画前
        case didDismiss(Bool)   // 消失, 动画后
        case willShow           // 展示, 动画前
        case didShow            // 展示, 动画后
    }
    
    public struct Configuration {
        
        public var arrow = Arrow()
        public struct Arrow {
            public var height          = 7.0           // 箭头高度
            public var width           = 13.0          // 箭头宽度
            public var radius          = 3.0           // 箭头圆角
            public var bottomRadius    = 8.0           // 箭头底座圆角
            public var offset          = UIOffset.zero // 箭头偏移量
        }
        
        /// 气泡圆角
        public var radius          = Double.greatestFiniteMagnitude
        
        /// 气泡偏移量
        public var offset          = UIOffset(horizontal: .zero, vertical: -7.0)
        
        /// 气泡相对屏幕的最短距离
        public var edgeInsets      = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
       
        /// 气泡背景风格
        public var backgroudStyle  = BackgroudStyle.blur(4.0)
        
        /// 气泡阴影颜色
        public var shadowColor     = UIColor.black
        
        /// 气泡方向
        public var direction       = ArrowDirection.bottom
        
        /// 遮罩层颜色
        public var overlyColor     = UIColor.clear
        
        /// 非气泡区域点击事件
        public var overlyTappedEvent = OverlyTappedEvent.propagate
        
        public init() {}
    }
    
    public var actionEventHandler: ((Bubble.ActionEvent) -> Void)?
    
    private var bubbleView: BubbleView!
    
}


public extension Bubble {
    
    public convenience init(target targetView: UIView,
                     content contentView: UIView,
                     super superView: UIView,
                     config: Configuration = Configuration()) {
        self.init()
        
        bubbleView = BubbleView(targetView: targetView, contentView: contentView, superView: superView, config: config)
        bubbleView.actionEventHandler = actionEventHandler
    }
    
    func show(animated: Bool) {
        bubbleView.show(animated: animated)
    }
    
    func dismiss(animated: Bool, after time: TimeInterval = .zero) {
        bubbleView.dismiss(animated: animated, after: time)
    }
    
    func updateFrameIfNeeded() -> Bool {
        return bubbleView.updateFrameIfNeeded()
    }
    
}

public extension Bubble {
    
    public class func show(target targetView: UIView,
                    content contentView: UIView,
                    super superView: UIView,
                    config: Configuration = Configuration()) -> Bubble {
        let bubble = Bubble(target: targetView, content: contentView, super: superView, config: config)
        bubble.show(animated: true)
        return bubble
    }
    
}

// MARK: - text bubble
public extension Bubble {
    
    public struct TextConfiguration {
        public var bubble = Configuration()
        public var text = BubbleTextContentView.Configuration()
        
        public init() {}
    }
    
    public class func show(message: String,
                           target targetView: UIView,
                           super superView: UIView,
                           config: TextConfiguration = TextConfiguration()) -> Bubble {
        
        let contentView = BubbleTextContentView(message: message, config: config.text)
        let bubble = Bubble(target: targetView, content: contentView, super: superView, config: config.bubble)
        bubble.show(animated: true)
        return bubble
    }
    
}
