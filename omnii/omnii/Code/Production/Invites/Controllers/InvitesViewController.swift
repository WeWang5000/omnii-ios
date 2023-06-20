//
//  InvitesViewController.swift
//  omnii
//
//  Created by huyang on 2023/5/22.
//

import UIKit
import CommonUtils
import Pageable

class InvitesViewController: UIViewController {
    
    var navigataionBar: NavigationBar!
    var exampleView: InvitesExampleCardView!
    var createButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupViews()
       
        navigataionBar.backAction = { [unowned self] in
            self.dismiss(animated: true)
        }
        
        navigataionBar.rightItemAction = { [unowned self] in
            self.presentInfo()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserCache.value(forKey: .invitesInfoOverlyView) == nil {
            presentInfo()
            UserCache.set("invitesInfoOverlyView", forKey: .invitesInfoOverlyView)
        }
    }

}


private extension InvitesViewController {
    
    private func setupViews() {
        
        navigataionBar = NavigationBar().then {
            $0.backgroundColor = .black
            $0.updateBackButton(imageName: "camera_close")
            $0.updateRightButton(imageName: "camera_info")
        }
        
        exampleView = InvitesExampleCardView(frame: CGRect(x: 20.rpx, y: 125.rpx, width: ScreenWidth - 40.rpx, height: 487.rpx)).then {
            $0.cornerRadius = 20.rpx
        }
        
        createButton = UIButton(type: .custom).then {
            $0.setBackgroundImage(UIImage(named: "welcome_btn"), for: .normal)
            $0.setTitleForAllStates("Creat Invite")
            $0.setTitleColorForAllStates(.white)
            $0.titleLabel?.font = UIFont(type: .montserratBlod, size: 18.rpx)
            let size = CGSize(width: 320.rpx, height: 55.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = exampleView.frame.maxY + 25.rpx
            $0.frame = CGRect(x: x, y: y, size: size)
        }
        
        createButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubview(navigataionBar)
        view.addSubview(exampleView)
        view.addSubview(createButton)
    }
    
    private func presentInfo() {
        self.present(CoverMessageController(message: "Invite other users to meet up in person and connect througn iSpace!"),
                     transionStyle: .fade)
    }
    
    @objc private func click(_ sender: UIButton) {
        let vc = InvitesEditingController()
        let navi = NavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.present(navi, animated: true)
    }
    
//    private func presentTimeNavi() {
//        let items = Date().invitesDateItems()
//        let vc = InvitesDatePickerController(style: .next, dateItems: items)
//        let navi = NavigationController(rootViewController: vc)
//        navi.modalPresentationStyle = .fullScreen
//        self.present(navi, animated: true)
//    }
    
}
