//
//  TransitionHandler.swift
//  PopupDialog
//
//  Created by huyang on 2023/5/29.
//

import Foundation

public class TransitionHandler {
    
    public enum State {
        case began
        case changed
        case cancelled
        case ended
    }
    
    public typealias handler = ((State) -> Void)
    
    public let present: handler?
    public let dismiss: handler?
    
    public init(present presentHandler: handler? = nil, dismiss dismissHandler: handler? = nil) {
        self.present = presentHandler
        self.dismiss = dismissHandler
    }
    
    
}
