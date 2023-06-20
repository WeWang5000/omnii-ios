//
//  CameraViewController.swift
//  omnii
//
//  Created by huyang on 2023/5/8.
//

import UIKit
import AVFoundation
import PermissionsKit
import PopupDialog
import Bubble
import Photos

class CameraViewController: UIViewController {
    
    private let cameraManager = CameraManager()
    private let assetManager = AssetManager()
    
    private var photoAuthorized = false
    private var cameraFlashMode: AVCaptureDevice.FlashMode = .off
    
    private var cameraView: CameraView? {
        return view as? CameraView
    }
    
    private var photoCollections: [PhotoCollectionModel]?
    
    deinit {
        unregisterChangeObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view = CameraView(frame: UIScreen.main.bounds)
        cameraManager.addPreviewLayerToView(cameraView!.cameraView)
        cameraManager.writeFilesToPhoneLibrary = true
        cameraManager.imageAlbumName = "Omnii"
        
        registerChangeObserver()
        cameraViewObserve()
        photoPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserCache.value(forKey: .momentsInfoOverlyView) == nil {
            presentInfo()
            UserCache.set("momentsInfoOverlyView", forKey: .momentsInfoOverlyView)
        }
    }
    
    private func cameraViewObserve() {
        cameraView!.cameraAction = { [unowned self] actionType in
            switch actionType {
            case .camera:
                self.capturePicture()
            case .edit:
                self.presentInputMind()
            case .close:
                self.dismiss(animated: true)
            case .flash(let mode):
                self.updateFlash(mode: mode)
            case .info:
                self.presentInfo()
            case .device(let device):
                self.updateCameraDevice(device: device)
            case .ablum:
                self.presentAblum()
            }
        }
    }
    
}

// MARK: - camera action
private extension CameraViewController {
    
    private func capturePicture() {
        cameraManager.capturePictureWithCompletion { [unowned self] result in
            switch result {
            case .failure(let error):
                self.showErrorDialog(title: "Error occurred", message: error.localizedDescription)
            case .success(let content):
                if let image = content.asImage, self.photoAuthorized {
                    self.cameraView!.updateAblumImage(image)
                    let moments = MomentsEditingController(image: image)
                    let navi = NavigationController(rootViewController: moments)
                    present(navi, transionStyle: .fade)
                }
            }
        }
    }
    
    private func showErrorDialog(title: String, message: String) {
        let dialog = PopupDialog(title: title, message: message)
        let confirm = PopupDialogButton(title: "OK", action: nil)
        dialog.addButton(confirm)
        self.present(dialog, animated: true)
    }
    
    private func updateFlash(mode: AVCaptureDevice.FlashMode) {
        cameraFlashMode = mode
        cameraManager.flashMode = mode
    }
    
    private func updateCameraDevice(device: CameraDevice) {
        if device == .front {
            cameraManager.flashMode = .off
            cameraView!.updateFlash(mode: cameraManager.flashMode)
        } else {
            cameraManager.flashMode = cameraFlashMode
            cameraView!.updateFlash(mode: cameraManager.flashMode)
        }
        cameraManager.cameraDevice = device
    }
    
    private func presentAblum() {
        guard let collections = self.photoCollections else { return }
        let ablum = AblumViewController(ablums: collections)
        let navi = NavigationController(rootViewController: ablum)
        self.present(navi, animated: true)
    }
    
    private func presentInfo() {
        self.present(CoverMessageController(message: "Share Drop Moments on the Map!"), transionStyle: .fade)
    }
    
    private func presentInputMind() {
        let mind = MomentsInputMindController(placeholder: "What's on your mind?")
        mind.modalPresentationStyle = .fullScreen
        let navi = NavigationController(rootViewController: mind)
        present(navi, animated: true)
    }
    
}

// MARK: - fetch photo assets
private extension CameraViewController {
    
    private func photoPermission() {
        if !Permission.photoLibrary.authorized {
            Permission.photoLibrary.request {
                if Permission.photoLibrary.authorized {
                    self.photoAuthorized = true
                    self.fetchPhotos()
                }
            }
        } else {
            self.photoAuthorized = true
            fetchPhotos()
        }
    }
    
    private func fetchPhotos() {
        
        assetManager.asyncFetchPhotoCollection { [unowned self] collections in
            
            self.photoCollections = collections
            
            guard let cameraView = self.cameraView,
                    let recent = collections.first
            else { return }
            
            recent.loadThumbnail { image in
                if let image = image {
                    cameraView.updateAblumImage(image)
                }
            }
            
            showAblumBubble()
        }
        
    }
    
    private func showAblumBubble() {
        if let _ = UserCache.value(forKey: .cameraAblumBubble) { return }
        if let cameraView = self.cameraView {
            let bubble = Bubble.show(message: "saved to the album", target: cameraView.ablumButton, super: cameraView)
            bubble.dismiss(animated: true, after: 3.0)
            UserCache.set("bubble", forKey: .cameraAblumBubble)
        }
    }
    
    private func registerChangeObserver() {
        PHPhotoLibrary.shared().register(self) // 监听照片库
    }
    
    private func unregisterChangeObserver() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}


extension CameraViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        fetchPhotos()
    }
    
}
