//
//  BubbleView.swift
//  omnii
//
//  Created by huyang on 2023/5/11.
//

import UIKit
import Foundation
import CommonUtils
import DynamicBlurView

final class BubbleView: UIView {
    
    var actionEventHandler: ((Bubble.ActionEvent) -> Void)?
    
    private(set) var config: Bubble.Configuration!
    private(set) var contentView: UIView!

    private(set) var targetView: UIView?
    private var targetViewFrame: CGRect?
    private var shadowLayer: CALayer?
    private var backgroudView: UIView?
    
    private var dismissed: Bool = false
    private var isShowing: Bool = false
    private var isDismissing: Bool = false
    
    private var showAnimator: CAAnimationGroup?
    private var hideAnimator: CAAnimationGroup?
    
    required init(targetView: UIView,
                  contentView: UIView,
                  superView: UIView,
                  config: Bubble.Configuration = Bubble.Configuration()) {
        super.init(frame: superView.bounds)
        
        guard targetView.size != .zero,
              contentView.size != .zero,
              superView.size != .zero else {
            return
        }
        
        self.targetView = targetView
        self.contentView = contentView
        self.config = config
        
        self.config.radius = min(config.radius, contentView.height / 2.0)
                
        superView.addSubview(self)
        superView.bringSubviewToFront(self)
        
        setupBubbleView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(animated: Bool) {
        
        guard let targetViewFrame = targetViewFrame,
              let maskView = backgroudView,
              let targetView = targetView
        else { return }
        
        isHidden = false
        dismissed = false
        
        if let action = actionEventHandler { action(.willShow) }
        
        if !animated {
            if let action = actionEventHandler { action(.didShow) }
            return
        }
        
        // 动画锚点
        var arrowAnchor = 0.0
        
        switch config.direction {
        case .top:
            arrowAnchor = targetViewFrame.midX - maskView.x + config.offset.horizontal + config.arrow.offset.horizontal
            
            if let targetButton = targetView as? UIButton {
                if #available(iOS 15.0, *) {
                    arrowAnchor += Double(targetButton.configuration?.contentInsets.leading ?? .zero)
                } else {
                    arrowAnchor += targetButton.contentEdgeInsets.left
                }
            }
            
            let frame = maskView.frame
            maskView.layer.anchorPoint = CGPoint(x: arrowAnchor / frame.width, y: .zero)
            maskView.frame = frame
            
        case .left:
            arrowAnchor = targetViewFrame.midY - maskView.y + config.arrow.offset.vertical
            
            if let targetButton = targetView as? UIButton {
                if #available(iOS 15.0, *) {
                    arrowAnchor += Double(targetButton.configuration?.contentInsets.top ?? .zero)
                } else {
                    arrowAnchor += targetButton.contentEdgeInsets.top
                }
            }
            
            let frame = maskView.frame
            maskView.layer.anchorPoint = CGPoint(x: .zero, y: arrowAnchor / frame.height)
            maskView.frame = frame
            
        case .right:
            arrowAnchor = targetViewFrame.midY - maskView.y - config.arrow.offset.vertical
            
            if let targetButton = targetView as? UIButton {
                if #available(iOS 15.0, *) {
                    arrowAnchor += Double(targetButton.configuration?.contentInsets.top ?? .zero)
                } else {
                    arrowAnchor += targetButton.contentEdgeInsets.top
                }
            }
            
            let frame = maskView.frame
            maskView.layer.anchorPoint = CGPoint(x: 1.0, y: arrowAnchor / frame.height)
            maskView.frame = frame
            
        case .bottom:
            arrowAnchor = targetViewFrame.midX - maskView.x + config.offset.horizontal + config.arrow.offset.horizontal
            
            if let targetButton = targetView as? UIButton {
                if #available(iOS 15.0, *) {
                    arrowAnchor += Double(targetButton.configuration?.contentInsets.leading ?? .zero)
                } else {
                    arrowAnchor += targetButton.contentEdgeInsets.left
                }
            }
            
            let frame = maskView.frame
            maskView.layer.anchorPoint = CGPoint(x: arrowAnchor / frame.width, y: 1.0)
            maskView.frame = frame
            
        }
        
        showAnimation()
    }
    
    func dismiss(animated: Bool, after time: TimeInterval = .zero) {
        let execute = {
            if let action = self.actionEventHandler {
                action(.willDismiss)
            }
            
            if let shadowLayer = self.shadowLayer {
                shadowLayer.removeFromSuperlayer()
            }
            
            if animated {
                self.hideAnimation()
            } else {
                if let action = self.actionEventHandler {
                    action(.didDismiss(true))
                }
                self.removeFromSuperview()
                self.dismissed = true
            }
        }
        
        if time > .zero {
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: execute)
        } else {
            execute()
        }
    }
    
    func updateFrameIfNeeded() -> Bool {
        
        let previousFrame = targetViewFrame
        
        if let targetView = targetView, let superview = self.superview {
            targetViewFrame = targetView.convert(targetView.bounds, to: superview)
        }
        
        guard let targetViewFrame = targetViewFrame else { return false }
        
        if let previousFrame = previousFrame, previousFrame == targetViewFrame { return false }
        
        let frame = fetchBubbleFrame()
        setupBubbleMaskView(frame: frame)
        setupContentView()
        drawBubbleMask()
        
        return true
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if isDismissing, self.superview != nil, newWindow == nil {
            isDismissing = false
            self.removeFromSuperview()
            if let action = actionEventHandler {
                action(.didDismiss(true))
            }
        }
    }
    
}


private extension BubbleView {
    
    func setupBubbleView() {
        isHidden = true
        backgroundColor = config.overlyColor
        
        targetViewFrame = fetchTargetViewFrameForSuperView()
        let bubbleframe = fetchBubbleFrame()
        setupBubbleMaskView(frame: bubbleframe)
        setupContentView()
        drawBubbleMask()
    }
    
    func fetchTargetViewFrameForSuperView() -> CGRect {
        if let frame = targetViewFrame, frame != .zero { return frame }
        guard let targetView = targetView else { return .zero }
        return targetView.convert(targetView.bounds, to: self.superview)
    }
    
    func fetchBubbleFrame() -> CGRect {
        guard let targetView = targetView, let targetFrame = targetViewFrame else { return .zero }
        
        let contentSize = contentView.size
        
        switch config.direction {
        case .top, .bottom:
            let targetViewMidX = targetFrame.midX
            let targetViewTop = targetFrame.minY
            let targetViewBottom = targetFrame.maxY
            
            // 计算 bubble frame x
            var x = targetViewMidX - contentSize.width / 2.0
            
            if let targetButton = targetView as? UIButton { // 按钮 content 偏移
                if #available(iOS 15.0, *) {
                    x += targetButton.configuration?.contentInsets.leading ?? 0.0
                } else {
                    x += targetButton.contentEdgeInsets.left
                }
            }
            
            x += config.offset.horizontal
            
            x = max(config.edgeInsets.left, x)
            
            let rightMargin = ScreenWidth - config.edgeInsets.right - contentSize.width // 右侧边缘最小值
            x = min(rightMargin, x)
            
            // 计算 bubble frame y
            var y = 0.0
            
            if config.direction == .top {
                y = targetViewBottom + config.offset.vertical
            } else {
                y = targetViewTop + config.offset.vertical - (contentSize.height + config.arrow.height)
            }
            
            return CGRect(x: x, y: y, width: contentSize.width, height: contentSize.height + config.arrow.height)
            
        case .left, .right:
            let targetViewMidY = targetFrame.midY
            let targetViewLeft = targetFrame.minX
            let targetViewRight = targetFrame.maxX
            
            // 计算 bubble frame y
            var y = targetViewMidY - contentSize.height / 2.0
            
            if let targetButton = targetView as? UIButton { // 按钮 content 偏移
                if #available(iOS 15.0, *) {
                    y += targetButton.configuration?.contentInsets.top ?? 0.0
                } else {
                    y += targetButton.contentEdgeInsets.top
                }
            }
            
            y += config.offset.vertical
            
            y = max(config.edgeInsets.top, y)
            
            let bottomMargin = ScreenWidth - config.edgeInsets.bottom - contentSize.height // 底部边缘最小值
            y = min(bottomMargin, y)
            
            // 计算 bubble frame x
            var x = 0.0
            if config.direction == .left {
                x = targetViewRight + config.offset.horizontal
            } else {
                x = targetViewLeft + config.offset.horizontal - (contentSize.width + config.arrow.height)
            }
            
            return CGRect(x: x, y: y, width: contentSize.width + config.arrow.height, height: contentSize.height)
        }
    }
    
    func setupBubbleMaskView(frame: CGRect) {
        switch config.backgroudStyle {
        case .blur(let radius):
            
            backgroudView = DynamicBlurView(frame: frame).then {
                $0.blurRadius = radius
                $0.trackingMode = .none
                $0.isDeepRendering = true
                $0.blendColor = .white.withAlphaComponent(0.8)
            }
                        
        case .color(let color):
            
            backgroudView = UIView(frame: frame)
            backgroudView!.backgroundColor = color
            
        }
        
        self.addSubview(backgroudView!)
    }
    
    func setupContentView() {
        guard let maskView = backgroudView else { return }
        
        var origin = CGPoint.zero
        switch config.direction {
        case .top:
            origin = CGPoint(x: 0.0, y: config.arrow.height)
        case .left:
            origin = CGPoint(x: config.arrow.height, y: 0.0)
        case .right, .bottom:
            break
        }
        
        var frame = contentView.frame
        frame.origin = origin
        contentView.frame = frame
        
        maskView.addSubview(contentView)
    }
    
    func drawBubbleMask() {
        guard let maskView = backgroudView else { return }
        
        let arrowWidth = config.arrow.width
        let arrowHeight = config.arrow.height
        let arrowRadius = config.arrow.radius
        let arrowBottomRadius = config.arrow.bottomRadius
        let w = maskView.width
        let h = maskView.height
        let radius = config.radius
        
        let path = CGMutablePath()
        switch config.direction {
        case .top:
            
            let arrowMargin = arrowMargin()
            
            path.move(to: CGPoint(x: .zero, y: h - radius))
            path.addArc(tangent1End: CGPoint(x: .zero, y: h), tangent2End: CGPoint(x: radius, y: h), radius: radius)
            path.addLine(to: CGPoint(x: w - radius, y: h))
            path.addArc(tangent1End: CGPoint(x: w, y: h), tangent2End: CGPoint(x: w, y: h - radius), radius: radius)
            path.addLine(to: CGPoint(x: w, y: h + radius))
            path.addArc(tangent1End: CGPoint(x: w, y: h), tangent2End: CGPoint(x: w - radius, y: h), radius: radius)
            
            let p1 = CGPoint(x: w - arrowMargin, y: arrowHeight)
            let p2 = CGPoint(x: w - arrowMargin - arrowWidth / 2.0, y: .zero)
            let p3 = CGPoint(x: w - arrowMargin - arrowWidth, y: arrowHeight)
            
            if arrowRadius == .zero {
                
                path.addLine(to: p1)
                path.addLine(to: p2)
                path.addLine(to: p3)
                
            } else {
                
                path.addLine(to: CGPoint(x: p1.x + arrowBottomRadius, y: p1.y))
                path.addArc(tangent1End: p1, tangent2End: p2, radius: arrowBottomRadius)
                path.addArc(tangent1End: p2, tangent2End: p3, radius: arrowRadius)
                path.addArc(tangent1End: p3, tangent2End: CGPoint(x: p3.x - arrowBottomRadius / 2.0, y: p3.y), radius: arrowBottomRadius)
                
            }

            path.addLine(to: CGPoint(x: radius, y: arrowHeight))
            path.addArc(tangent1End: CGPoint(x: .zero, y: arrowHeight), tangent2End: CGPoint(x: .zero, y: arrowHeight + radius), radius: radius)
            path.closeSubpath()
            
        case .left:
            
            let arrowMargin = arrowMargin()

            let p1 = CGPoint(x: arrowHeight, y: arrowMargin)
            let p2 = CGPoint(x: .zero, y: arrowMargin + arrowWidth / 2.0)
            let p3 = CGPoint(x: arrowHeight, y: arrowMargin + arrowWidth)
            
            if arrowRadius == .zero {
                
                path.move(to: p1)
                path.addLine(to: p2)
                path.addLine(to: p3)
                
            } else {
                
                path.move(to: CGPoint(x: p1.x, y: p1.y - arrowBottomRadius / 2.0))
                path.addArc(tangent1End: p1, tangent2End: p2, radius: arrowBottomRadius)
                path.addArc(tangent1End: p2, tangent2End: p3, radius: arrowRadius)
                path.addArc(tangent1End: p3, tangent2End: CGPoint(x: p3.x, y: p3.y + arrowBottomRadius / 2.0), radius: arrowBottomRadius)

            }

            path.addLine(to: CGPoint(x: arrowHeight, y: h - radius))
            path.addArc(tangent1End: CGPoint(x: arrowHeight, y: h), tangent2End: CGPoint(x: arrowHeight + radius, y: h), radius: radius)
            path.addLine(to: CGPoint(x: w - radius, y: h))
            path.addArc(tangent1End: CGPoint(x: w, y: h), tangent2End: CGPoint(x: w, y: h - radius), radius: radius)
            path.addLine(to: CGPoint(x: w, y: radius))
            path.addArc(tangent1End: CGPoint(x: w, y: .zero), tangent2End: CGPoint(x: w - radius, y: .zero), radius: radius)
            path.addLine(to: CGPoint(x: arrowHeight + radius, y: .zero))
            path.addArc(tangent1End: CGPoint(x: arrowHeight, y: .zero), tangent2End: CGPoint(x: arrowHeight, y: radius), radius: radius)
            path.closeSubpath()
            
        case .right:
            
            let arrowMargin = arrowMargin()
            
            path.move(to: CGPoint(x: .zero, y: h - radius))
            path.addArc(tangent1End: CGPoint(x: .zero, y: h), tangent2End: CGPoint(x: radius, y: h), radius: radius)
            path.addLine(to: CGPoint(x: w - arrowHeight - radius, y: h))
            path.addArc(tangent1End: CGPoint(x: w - arrowHeight, y: h), tangent2End: CGPoint(x: w - arrowHeight, y: h - radius), radius: radius)
            
            let p1 = CGPoint(x: w - arrowHeight, y: h - arrowMargin - arrowWidth)
            let p2 = CGPoint(x: w, y: h - arrowMargin - arrowWidth / 2.0)
            let p3 = CGPoint(x: w - arrowHeight, y: h - arrowMargin)
            
            if arrowRadius == .zero {
                
                path.addLine(to: p1)
                path.addLine(to: p2)
                path.addLine(to: p3)
                
            } else {
                
                path.addLine(to: CGPoint(x: p1.x, y: p1.y - arrowBottomRadius / 2.0))
                path.addArc(tangent1End: p1, tangent2End: p2, radius: arrowBottomRadius)
                path.addArc(tangent1End: p2, tangent2End: p3, radius: arrowRadius)
                path.addArc(tangent1End: p3, tangent2End: CGPoint(x: p3.x, y: p3.y + arrowBottomRadius / 2.0), radius: arrowBottomRadius)

            }
            
            path.addLine(to: CGPoint(x: w - arrowHeight, y: radius))
            path.addArc(tangent1End: CGPoint(x: w - arrowHeight, y: .zero), tangent2End: CGPoint(x: w - arrowHeight - radius, y: .zero), radius: radius)
            path.addLine(to: CGPoint(x: radius, y: .zero))
            path.addArc(tangent1End: .zero, tangent2End: CGPoint(x: .zero, y: radius), radius: radius)
            path.closeSubpath()

        case .bottom:
            
            let arrowMargin = arrowMargin()

            path.move(to: CGPoint(x: .zero, y: h - arrowHeight - radius))
            path.addArc(tangent1End: CGPoint(x: .zero, y: h - arrowHeight), tangent2End: CGPoint(x: radius, y: h - arrowHeight), radius: radius)
            
            let p1 = CGPoint(x: w - arrowMargin - arrowWidth, y: h - arrowHeight)
            let p2 = CGPoint(x: w - arrowMargin - arrowWidth / 2.0, y: h)
            let p3 = CGPoint(x: w - arrowMargin, y: h - arrowHeight)
            
            if arrowRadius == .zero {
                
                path.addLine(to: p1)
                path.addLine(to: p2)
                path.addLine(to: p3)
                
            } else {
                
                path.addLine(to: CGPoint(x: p1.x - arrowBottomRadius / 2.0, y: p1.y))
                path.addArc(tangent1End: p1, tangent2End: p2, radius: arrowBottomRadius)
                path.addArc(tangent1End: p2, tangent2End: p3, radius: arrowRadius)
                path.addArc(tangent1End: p3, tangent2End: CGPoint(x: p3.x + arrowBottomRadius, y: p3.y), radius: arrowBottomRadius)
                
            }
            
            path.addLine(to: CGPoint(x: w - radius, y: h - arrowHeight))
            path.addArc(tangent1End: CGPoint(x: w, y: h - arrowHeight), tangent2End: CGPoint(x: w, y: h - arrowHeight - radius), radius: radius)
            path.addLine(to: CGPoint(x: w, y: radius))
            path.addArc(tangent1End: CGPoint(x: w, y: .zero), tangent2End: CGPoint(x: w - radius, y: .zero), radius: radius)
            path.addLine(to: CGPoint(x: radius, y: .zero))
            path.addArc(tangent1End: .zero, tangent2End: CGPoint(x: .zero, y: radius), radius: radius)
            path.closeSubpath()

        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskView.layer.mask = maskLayer
        maskView.layer.masksToBounds = true
        
        // 加阴影
        if let shadowLayer = shadowLayer { shadowLayer.removeFromSuperlayer() }
        shadowLayer = CALayer()
        shadowLayer?.shadowPath = path
        shadowLayer?.shadowOpacity = 0.2
        shadowLayer?.shadowOffset = CGSize(width: .zero, height: 2.0)
        shadowLayer?.shadowRadius = 6.0
        shadowLayer?.shadowColor = config.shadowColor.cgColor
        shadowLayer?.frame = maskView.frame
        self.layer.insertSublayer(shadowLayer!, at: 0)
    }
    
    func arrowMargin() -> Double {
        guard let maskView = backgroudView, let targetViewFrame = targetViewFrame else { return .zero }

        switch config.direction {
        case .top, .bottom:
            var margin = maskView.frame.maxX - targetViewFrame.midX - config.arrow.width / 2.0
           
            if let targetButton = targetView as? UIButton { // 按钮 content 偏移
                if #available(iOS 15.0, *) {
                    margin -= Double(targetButton.configuration?.contentInsets.leading ?? 0.0)
                } else {
                    margin -= targetButton.contentEdgeInsets.left
                }
            }
            
            margin -= (config.offset.horizontal + config.arrow.offset.horizontal)
            
            margin = min(maskView.width - config.radius, margin) // 左边距
            margin = max(config.radius, margin) // 右边距
            
            return margin

        case .left, .right:
            var margin = maskView.frame.maxY - targetViewFrame.midY - config.arrow.width / 2.0
            
            if let targetButton = targetView as? UIButton { // 按钮 content 偏移
                if #available(iOS 15.0, *) {
                    margin += Double(targetButton.configuration?.contentInsets.top ?? 0.0)
                } else {
                    margin -= targetButton.contentEdgeInsets.top
                }
            }
            
            margin += config.arrow.offset.vertical
            
            margin = min(maskView.height - config.radius, margin) // 上边距
            margin = max(config.radius, margin) // 下边距
            
            return margin
        }
    }
    
}

extension BubbleView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animator = showAnimator, animator == anim {
            self.isShowing = false
            if let action = self.actionEventHandler {
                action(.didShow)
            }
        }
        
        if let animator = hideAnimator, animator == anim {
            if dismissed { return }
            if let action = self.actionEventHandler {
                action(.didDismiss(flag))
            }
            if flag {
                self.isDismissing = false
                self.removeFromSuperview()
                dismissed = true
            }
        }
    }
    
    private func showAnimation() {
        
        guard let animations = animations(isHidden: false),
              let maskView = backgroudView
        else { return }
        
        showAnimator = CAAnimationGroup()
        showAnimator!.animations = animations
        showAnimator!.duration = 0.3
        showAnimator!.delegate = self
        
        isShowing = true
        
//        contentView.layer.opacity = 1.0
//        contentView.layer.add(group, forKey: "showContent")
        
        maskView.layer.opacity = 1.0
        maskView.layer.add(showAnimator!, forKey: "showMask")
    }
    
    func hideAnimation() {
        
        guard let animations = animations(isHidden: true),
              let maskView = backgroudView
        else { return }
        
        hideAnimator = CAAnimationGroup()
        hideAnimator!.animations = animations
        hideAnimator!.duration = 0.24
        
        isDismissing = true
        
        maskView.layer.opacity = .zero
        maskView.layer.add(hideAnimator!, forKey: "hideMask")
        
//        contentView.layer.opacity = .zero
//        contentView.layer.add(opacity, forKey: "hideContent")
    }
    
    private func animations(isHidden: Bool) -> [CAAnimation]? {
        guard let maskView = backgroudView else { return nil }

        var animations = [CAAnimation]()
        
        let scale = CABasicAnimation(keyPath: "transform.scale").then {
            $0.fromValue = isHidden ? 1.0 : 0.8
            $0.toValue = isHidden ? 0.8 : 1.0
            $0.timingFunction = CAMediaTimingFunction(name: .easeOut)
        }
        animations.append(scale)
        
        let opacity = CABasicAnimation(keyPath: "opacity").then {
            $0.fromValue = isHidden ? 1.0 : 0.0
            $0.toValue = isHidden ? 0.0 : 1.0
            $0.timingFunction = CAMediaTimingFunction(name: .easeOut)
        }
        animations.append(opacity)
        
        switch config.direction {
        case .top:
            
            let position = CABasicAnimation(keyPath: "position.y").then {
                let v1 = maskView.layer.position.y - 6.5
                let v2 = maskView.layer.position.y
                $0.fromValue = isHidden ? v2 : v1
                $0.toValue = isHidden ? v1 : v2
                $0.timingFunction = CAMediaTimingFunction(name: .easeOut)
            }
            animations.append(position)
            
        case .left:
            
            let position = CABasicAnimation(keyPath: "position.x").then {
                let v1 = maskView.layer.position.x - 6.5
                let v2 = maskView.layer.position.x
                $0.fromValue = isHidden ? v2 : v1
                $0.toValue = isHidden ? v1 : v2
                $0.timingFunction = CAMediaTimingFunction(name: .easeOut)
            }
            animations.append(position)
            
        case .right:
            
            let position = CABasicAnimation(keyPath: "position.x").then {
                let v1 = maskView.layer.position.x + 6.5
                let v2 = maskView.layer.position.x
                $0.fromValue = isHidden ? v2 : v1
                $0.toValue = isHidden ? v1 : v2
                $0.timingFunction = CAMediaTimingFunction(name: .easeOut)
            }
            animations.append(position)
            
        case .bottom:
            
            let position = CABasicAnimation(keyPath: "position.y").then {
                let v1 = maskView.layer.position.y + 6.5
                let v2 = maskView.layer.position.y
                $0.fromValue = isHidden ? v2 : v1
                $0.toValue = isHidden ? v1 : v2
                $0.timingFunction = CAMediaTimingFunction(name: .easeOut)
            }
            animations.append(position)
            
        }
        
        return animations
    }
    
}

extension BubbleView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden {
            return super.hitTest(point, with: event)
        }
        
        guard let maskView = backgroudView else {
            return super.hitTest(point, with: event)
        }
        
        let isBubbleArea = maskView.frame.contains(point)
        
        if isBubbleArea {
            bubbleTapped()
            return super.hitTest(point, with: event)
        }
                
        switch config.overlyTappedEvent {
        case .invalid:
            
            return super.hitTest(point, with: event)
            
        case .dismiss:
            
            self.dismiss(animated: true)
            return super.hitTest(point, with: event)
            
        case .propagate:
            
            tapped(on: point, dismiss: false)
            return nil
            
        case .propagateAndDissmiss:
            
            tapped(on: point, dismiss: true)
            return nil
            
        }
        
    }
    
    private func bubbleTapped() {
        if let action = actionEventHandler {
            action(.tapped)
        }
    }
    
    private func tapped(on point: CGPoint, dismiss: Bool) {
        if dismissed { return }
        
        if let maskView = backgroudView, maskView.frame.contains(point) {
            bubbleTapped()
        }
        
        if let targetView = targetView {
            let targetFrame = targetView.convert(targetView.bounds, to: self)
            if targetFrame.contains(point), let action = actionEventHandler {
                action(.targetViewTapped)
            }
        }
        
        if dismiss {
            self.dismiss(animated: true)
        }
    }
    
}
