//
//  InvitesEditingController.swift
//  omnii
//
//  Created by huyang on 2023/5/25.
//

import UIKit
import Combine
import CommonUtils

class InvitesEditingController: UIViewController {
    
    private var navigationBar: NavigationBar!
    private var editingView: InvitesEditingView!
    private var nextButton: UIButton!
    private var cardView: UIView!
    
    private var picker: PickerSheetController?
    
    private let keyboard = KeyboardManager()
    private let viewModel = InvitesViewModel()
    
    private lazy var shareFriendsController: FriendsPickerController = {
        let vc = FriendsPickerController(style: .invites)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    private lazy var locationController: InvitesLocationController = {
       let vc = InvitesLocationController(showProgressView: false)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    private lazy var limitController: InvitesLimitController = {
        let vc = InvitesLimitController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    // combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        setupViews()
        addObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard.registerMonitor()
        editingView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboard.unregisterMonitor()
        editingView.resignFirstResponder()
    }
    
    func update(date: Date, location: GeoModel) {
        editingView.update(date: date, location: location)
        viewModel.input.updateDate(date)
        viewModel.input.updateLocation(location)
    }

    private func setupViews() {
                
        cardView = UIView().then {
            $0.isHidden = true
            let x = 60.rpx
            let y = 54.rpx
            let width = ScreenWidth - x * 2
            let height = 450.rpx
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
            $0.backgroundColor = .blackVerticalGradient(size: $0.size)
            $0.cornerRadius = 15.rpx
        }
        
        navigationBar = NavigationBar().then {
            $0.backgroundColor = .black
            $0.updateBackButton(imageName: "camera_close")
        }
        
        let editFrame = CGRect(x: 0,
                               y: navigationBar.height,
                               width: ScreenWidth,
                               height: ScreenHeight - navigationBar.height)
        editingView = InvitesEditingView(frame: editFrame)
        
        nextButton = UIButton(type: .custom).then {
            $0.isEnabled = false
            let x = 28.rpx
            let width = ScreenWidth - x * 2
            let height = 55.rpx
            let y = ScreenHeight - ScreenFit.safeBottomHeight - height
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
            $0.whiteBackgroundStyle(title: "Next")
        }
        
        nextButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubview(cardView)
        view.addSubview(navigationBar)
        view.addSubview(editingView)
        view.addSubview(nextButton)
    }
    
    private func addObserver() {
        
        keyboard.action = { [unowned self] event in
            switch event {
            case .willShow(let info):
                let y = info.endFrame.origin.y
                UIView.animate(withDuration: info.duration) {
                    self.nextButton.y = y - self.nextButton.height - 10.rpx
                }
            case .willHide(let info):
                UIView.animate(withDuration: info.duration) {
                    self.nextButton.y = ScreenHeight - ScreenFit.safeBottomHeight - self.nextButton.height
                }
            default:
                break
            }
        }
        
        navigationBar.backAction = { [unowned self] in
            self.dismiss(animated: true)
        }
        
        editingView.textDidChange = { [unowned self] text in
            self.viewModel.input.updateContent(text)
            self.updateNextButton(with: text)
        }
        
        editingView.editAction = { [unowned self] event in
            switch event {
            case .touchTime:
                self.presentDatePicker()
            case .touchLocation:
                self.presentLocationVC()
            case .touchTimeAndLocation:
                self.pushDatePicker()
            }
        }
        
        shareFriendsController.dismissHandler = { [unowned self] friends in
            if let friends = friends {
                self.viewModel.input.updateUserIds(friends.map { $0.userId })
            } else {
                self.viewModel.input.updateUserIds([String]())
            }
        }
        
        viewModel.output.createIvitesResult
            .sink { [unowned self] success in
                if success {
                    self.dismiss(to: HomeViewController.self)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.warningAlertResult
            .sink { [unowned self] message in
                if let parant = self.picker {
                    parant.warningAlert(title: "Warning", message: message)
                }
            }
            .store(in: &cancellables)
        
        self.limitController.complete = { [unowned self] count in
            self.viewModel.input.updateLimitNum(count)
            self.viewModel.requestInvites()
        }
        
    }
    
    @objc private func click(_ sender: UIButton) {
        navigationBar.isHidden = true
        editingView.resignFirstResponder()
        presentVisiablePicker()
    }
    
    private func presentVisiablePicker() {
        if picker == nil {
            let items = [PickerEntity(title: "Everyone", isPicked: true),
                         PickerEntity(title: "Invite Only")]
            
            picker = pickerSheet(items: items, height: 285.rpx, title: "Open to", buttonTitle: "Share") { [unowned self] state in
                switch state {
                case .select(let item):
                    if item.title == items.last?.title {
                        self.picker!.present(self.shareFriendsController, animated: true)
                        self.viewModel.input.updateShareType(.friend)
                    } else {
                        self.viewModel.input.updateShareType(.everyone)
                    }
                case .confirm(_):
                    self.createInvite()
                }
            }
        }
        
        guard let picker = picker else { return }
        presentSheet(picker, tapGestureDismissal: true) { [unowned self] state in
            switch state {
            case .began:
                self.editingView.isEnabled = false
                self.editingView.setTimeAndLocationButtonHidden(true)
            case .changed:
                self.editingView.scale(by: CGPoint(x: 0.67, y: 0.67))
                self.editingView.y = self.cardView.y + 80.rpx
            case .ended:
                self.cardView.isHidden = false
            default:
                break
            }
            
        } dismissHandler: { [unowned self] state in
            switch state {
            case .began:
                self.cardView.isHidden = true
            case .changed:
                self.editingView.scale(by: CGPoint(x: 1.48, y: 1.48))
                self.editingView.y = self.navigationBar.height
            case .ended:
                self.editingView.isEnabled = true
                self.navigationBar.isHidden = false
                self.editingView.setTimeAndLocationButtonHidden(false)
            case .cancelled:
                self.cardView.isHidden = false
            }
        }
        
    }
    
    private func createInvite() {
        if viewModel.output.inviteData.shareScopeType == InvitesViewModel.ShareScopeType.everyone.rawValue {
            presentLimitController()
        } else {
            viewModel.input.requestInvites()
        }
    }
    
    private func presentLimitController() {
        self.picker!.present(limitController, animated: true)
    }
    
    private func pushDatePicker() {
        let items = Date().invitesDateItems()
        let vc = InvitesDatePickerController(style: .next, dateItems: items, showProgressView: true)
        vc.popHandler = {  [unowned self] date, location in
            self.update(date: date, location: location)
        }
        self.navigationController?.pushViewController(vc)
    }
    
    private func presentDatePicker() {
        let items = Date().invitesDateItems()
        let vc = InvitesDatePickerController(style: .done, dateItems: items, showProgressView: false)
        vc.modalPresentationStyle = .fullScreen
        vc.selectedHandler = { [unowned self] date in
            self.editingView.updateTime(date)
            self.viewModel.input.updateDate(date)
        }
        present(vc, animated: true)
    }
    
    private func presentLocationVC() {
        locationController.selectedHandler = { [unowned self] geo in
            self.editingView.updateLocation(geo)
            self.viewModel.input.updateLocation(geo)
        }
        present(locationController, animated: true)
    }
    
    private func updateNextButton(with text: String?) {
        if let text = text, !text.isEmpty {
            self.nextButton.isEnabled = true
            return
        }
        self.nextButton.isEnabled = false
    }

}
