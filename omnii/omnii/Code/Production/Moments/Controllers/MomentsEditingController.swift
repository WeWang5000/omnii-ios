//
//  MomentsEditController.swift
//  omnii
//
//  Created by huyang on 2023/5/11.
//

import UIKit
import CommonUtils
import Combine
import PopupDialog

final class MomentsEditingController: UIViewController {
    
    private lazy var visiblePicker: MomentsVisiblePicker = {
        let frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 340.rpx)
        let picker = MomentsVisiblePicker(frame: frame)
        picker.isHidden = true
        picker.roundCorners([.topLeft, .topRight], radius: 30.rpx)
        return picker
    }()
    
    private let viewModel = MomentsEditViewModel()
    
    // MARK: - edit photo
    private var wordView: MomentsWordInputView?
    private var editPhotoView: MomentsEditPhotoView?
    private var photoModel: PhotoModel?
    private var image: UIImage?
    
    // MARK: - edit mind
    private var editMindView: MomentsEditMindView?
    
    // MARK: - location picker
    private var locationPicker: MomentsLocationPicker?
    
    // MARK: - friends picker
    private var friendsPicker: FriendsPickerController?
    
    // MARK: - combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - life cycle
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    init(photo: PhotoModel) {
        self.photoModel = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    init(mind: String) {
        super.init(nibName: nil, bundle: nil)
        viewModel.input.updateContent(mind)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        addEditViewCallback()
        addCancellable()
        
        if let photo = photoModel {
            viewModel.input.setPhotoModel(photo)
        } else {
            if let image = image, let photoView = editPhotoView {
                photoView.updateImage(image)
            }
            viewModel.input.requestGeoReverse(with: nil, showHud: false)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: visiblePicker)
        guard !visiblePicker.point(inside: point, with: nil) else { return }
        hideVisiblePickerWithAnimation()
    }

}

extension MomentsEditingController {
    
    private func setupViews() {
        
        if let image = image {
            editPhotoView = MomentsEditPhotoView(image: image)
            wordView = MomentsWordInputView(frame: UIScreen.main.bounds)
            view.addSubview(editPhotoView!)
            view.addSubview(wordView!)
            
        } else if let photo = photoModel {
            
            let image = photo.image ?? photo.thumbnail
            editPhotoView = MomentsEditPhotoView(image: image)
            wordView = MomentsWordInputView(frame: UIScreen.main.bounds)
            view.addSubview(editPhotoView!)
            view.addSubview(wordView!)
            
        } else if let mind = viewModel.output.momentsSource.content {
            
            editMindView = MomentsEditMindView(mind: mind)
            view.addSubview(editMindView!)
        }
        
        view.addSubview(visiblePicker)
    }
    
    private func addEditViewCallback() {
        
        self.editPhotoView?.actionEvent = { [unowned self] state in
            switch state {
            case .back:
                self.goToBack()
            case .word:
                self.editPhotoView!.isBackHidden = true
                self.wordView!.isHidden = false
            case .location:
                self.editPhotoView!.isBackHidden = true
                self.presentLocationPickerIfNeeded()
            case .next:
                showVisiblePickerWithAnimation()
            }
        }
        
        self.wordView?.completion = { [unowned self] text in
            self.editPhotoView!.isBackHidden = false
            self.editPhotoView!.updateWord(text)
            self.viewModel.input.updateContent(text)
        }
        
        self.editMindView?.actionEvent = { [unowned self] state in
            switch state {
            case .back:
                self.navigationController?.popViewController(animated: true)
            case .location:
                self.editMindView!.isBackHidden = true
                self.presentLocationPickerIfNeeded()
            case .next:
                showVisiblePickerWithAnimation()
            }
        }
        
    }
    
    private func addCancellable() {
        
        viewModel.imageResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] image in
                self.editPhotoView!.updateImage(image)
            }).store(in: &cancellables)
        
        viewModel.locationsResult
            .sink { [unowned self] locations in
                self.presentLocationPicker(with: locations)
            }
            .store(in: &cancellables)
        
        viewModel.createMomentsResult
            .sink { [unowned self] success in
                if success {
                    self.dismiss(to: HomeViewController.self)
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func goToBack() {
        if let navi = self.navigationController, navi.children.count > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func presentLocationPickerIfNeeded() {
        if let locations = viewModel.locations {
            self.presentLocationPicker(with: locations)
        } else {
            self.requestLocations()
        }
    }
    
    private func requestLocations() {
        viewModel.input.requestGeoReverse(with: photoModel, showHud: true)
    }
    
    private func presentLocationPicker(with locations: [MomentsLocationModel]) {
        if locationPicker == nil {
            locationPicker = MomentsLocationPicker(items: locations).then {
                $0.modalPresentationStyle = .fullScreen
                $0.view.roundCorners([.topLeft, .topRight], radius: 30.rpx)
                $0.view.frame = CGRect(x: 0, y: 202.rpx, width: ScreenWidth, height: ScreenHeight - 202.rpx)
            }
        }
        
        present(locationPicker!,
                transionStyle: .sheet,
                tapGestureDismissal: true,
                panGestureDismissal: true,
                overlayStyle: .color(.black.withAlphaComponent(0.4)),
                dismissCompletion:  {
            self.editPhotoView?.isBackHidden = false
            self.editMindView?.isBackHidden = false
        })
        
        locationPicker!.selectHandler = { [unowned self] geo in
            self.editPhotoView?.updateLocation(with: geo.name)
            self.editMindView?.updateLocation(with: geo.name)
            self.viewModel.input.updateLocation(geo)
        }
    }
    
    private func pushFriendsPickerController() {
        if friendsPicker == nil {
            friendsPicker = FriendsPickerController(style: .moments)
            friendsPicker!.dismissHandler = { [unowned self] friends in
                self.viewModel.input.updateSelectedFriends(friends)
                if let friends = friends, friends.count > 0 {
                    self.visiblePicker.setFriendsCellSubTitle(to: "\(friends.count) selected")
                } else {
                    self.visiblePicker.setFriendsCellSubTitle(to: nil)
                }
            }
        }
        self.navigationController?.pushViewController(friendsPicker!)
    }
    
}

// MARK: - animation
private extension MomentsEditingController {
    
    func showVisiblePickerWithAnimation() {
        self.visiblePicker.isHidden = false
        UIView.animate(withDuration: 0.2, delay: .zero, options: .curveEaseOut) {
            self.visiblePicker.show()
            self.editPhotoView?.toZoomOut()
            self.editMindView?.toZoomOut()
        }
        addPickerCallback()
    }
    
    func hideVisiblePickerWithAnimation() {
        UIView.animate(withDuration: 0.2, delay: .zero, options: .curveEaseOut) {
            self.visiblePicker.hide()
            self.editPhotoView?.toZoomIn()
            self.editMindView?.toZoomIn()
        } completion: { _ in
            self.editPhotoView?.makeHidden(false)
            self.editMindView?.makeHidden(false)
            self.visiblePicker.isHidden = true
        }
    }
    
    func hideVisiblePicker(progress: Double) {
        self.editPhotoView?.toZoomIn(progress: progress)
        self.editMindView?.toZoomIn(progress: progress)
        self.visiblePicker.hide(progress: progress)
    }
    
    func addPickerCallback() {
        
        visiblePicker.panStateHandler = { [unowned self] state in
            switch state {
            case .changed(let progress):
                self.hideVisiblePicker(progress: progress)
            case .cancelled:
                self.showVisiblePickerWithAnimation()
            case .ended:
                self.hideVisiblePickerWithAnimation()
            default:
                break
            }
        }
        
        visiblePicker.pickHandler = { [unowned self] state in
            switch state {
            case .everyone:
                self.viewModel.input.updateShareType(.everyone)
            case .friendsOnly:
                self.viewModel.input.updateShareType(.friend)
                self.pushFriendsPickerController()
            case .IncognitoMode:
                self.viewModel.input.updateShareType(.private)
                self.showIncognitoModeDialog()
            }
        }
        
        visiblePicker.shareHandler = { [unowned self] in
            self.viewModel.input.requestShareMoments()
        }
        
    }
    
    func showIncognitoModeDialog() {
        if let _ = UserCache.value(forKey: .momentsIncognitoDialog) { return }
        let dialog = PopupDialog(title: "About Incognito Mode",
                                 message: "The moment you post will never be seen by anyone. \n You can see it in your own space.")
        let confirm = GradientButton(title: "Got it", action: nil)
        dialog.addButton(confirm)
        self.present(dialog, animated: true)
        UserCache.set("dialog", forKey: .momentsIncognitoDialog)
    }
    
}
