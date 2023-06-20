//
//  LoadingPlugin.swift
//  omnii
//
//  Created by huyang on 2023/5/2.
//

import Foundation
import Moya
import PKHUD

final class LoadingPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        guard let api = target as? Api else { return }

        if api.useDefaultHUD {
            showHUD()
        }
        
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        
        guard let api = target as? Api else { return }

        if api.useDefaultHUD {
            hideHUD()
        }
        
    }
    
    // MARK: - private
            
    private func showHUD() {
        DispatchQueue.main.async {
            HUD.show(.systemActivity)
        }
    }
    
    private func hideHUD() {
        DispatchQueue.main.async {
            HUD.hide()
        }
    }
    
}
