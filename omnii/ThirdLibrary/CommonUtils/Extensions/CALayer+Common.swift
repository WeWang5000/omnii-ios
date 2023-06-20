//
//  CALayer+Common.swift
//  omnii
//
//  Created by huyang on 2023/4/23.
//

import UIKit
import QuartzCore

public extension CALayer {
    
    func setImage(_ image: UIImage?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contents = image?.cgImage
        contentsScale = UIScreen.main.scale
        contentsGravity = .resizeAspectFill
        CATransaction.commit()
    }
    
}
