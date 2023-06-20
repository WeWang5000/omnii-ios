//
//  PopupDialogView.swift
//
//  Copyright (c) 2016 Orderella Ltd. (http://orderella.co.uk)
//  Author - Martin Wildfeuer (http://www.mwfire.de)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

/// The main view of the popup dialog
final public class PopupDialogDefaultView: UIView {

    // MARK: - Views

    /// The view that will contain the image, if set
    internal lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.cornerRadius = 15.rpx
        return imageView
    }()

    /// The title label of the dialog
    internal lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(type: .montserratBlod, size: 20.rpx)
        return titleLabel
    }()

    /// The message label of the dialog
    internal lazy var messageLabel: UILabel = {
        let messageLabel = UILabel(frame: .zero)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.font = UIFont(type: .montserratLight, size: 14.rpx)
        return messageLabel
    }()
    
    /// The height constraint of the image view, 0 by default
    internal var imageHiddenConstraints: [NSLayoutConstraint]?
    internal var imageVisibleConstraints: [NSLayoutConstraint]?

    // MARK: - Initializers

    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    internal func setupViews() {

        backgroundColor = UIColor(hexString: "#252627")!
        
        // Self setup
        translatesAutoresizingMaskIntoConstraints = false

        // Add views
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(messageLabel)

        // Layout views
        let views = ["titleLabel": titleLabel, "messageLabel": messageLabel, "imageView": imageView] as [String: Any]
        var constraints = [NSLayoutConstraint]()

        let metrics = ["textMarginH": 27.rpx,
                       "imageMarginH": 20.rpx,
                       "imageHeight": 202.rpx,
                       "V1": 23.rpx,    // titile top marigin
                       "V2": 13.rpx,    // title and messsage space
                       "V3": 20.rpx,    // message and image space
                       "V4": 20.rpx]    // image bottom margin

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==textMarginH@500)-[titleLabel]-(==textMarginH@500)-|", options: [], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==textMarginH@500)-[messageLabel]-(==textMarginH@500)-|", options: [], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==imageMarginH@500)-[imageView]-(==imageMarginH@500)-|", options: [], metrics: metrics, views: views)
        
        imageHiddenConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==V1@500)-[titleLabel]-(==V2@500)-[messageLabel]-(==V3@500)-|", options: [], metrics: metrics, views: views)
        
        imageVisibleConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==V1@500)-[titleLabel]-(==V2@500)-[messageLabel]-(==V3@500)-[imageView(imageHeight)]-(==V4@500)-|", options: [], metrics: metrics, views: views)
        
        // Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
    
    func updateImageConstraints() {
        
        guard let visibleConstraints = imageVisibleConstraints, let hiddenConstraints = imageHiddenConstraints else { return }
        
        if let _ = imageView.image {
            NSLayoutConstraint.activate(visibleConstraints)
            NSLayoutConstraint.deactivate(hiddenConstraints)
        } else {
            NSLayoutConstraint.activate(hiddenConstraints)
            NSLayoutConstraint.deactivate(visibleConstraints)
        }
        
    }
    
}
