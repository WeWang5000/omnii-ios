//
//  StartedViewController.swift
//  omnii
//
//  Created by huyang on 2023/5/4.
//

import UIKit

class StartedViewController: UIViewController {
    
    var startView: StartedView! {
        return view as? StartedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChatManager.connectSendbirdChat()
        
        LocationManager.shared.didUpdateLocation()

        view = StartedView(frame: UIScreen.main.bounds)
        
        startView.actionHandler = { [unowned self] in
            self.camera()
        }
        
        let logout = UIButton(frame: CGRect(x: 20, y: 60, width: 60, height: 40)).then {
            $0.setTitleForAllStates("Logout")
            $0.setTitleColorForAllStates(.orange)
        }
        view.addSubview(logout)
        logout.addTarget(self, action: #selector(click), for: .touchUpInside)
        
    }
    
    @objc private func click() {
        let login = NavigationController(rootViewController: LoginViewController())
        present(login, transionStyle: .fade)
    }
    
    private func camera() {
        if LocationManager.shared.status == .authorizedAlways ||
           LocationManager.shared.status == .authorizedWhenInUse {
            pushCamera()
        }
    }
    
    private func pushCamera() {
        let vc = HomeViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}
