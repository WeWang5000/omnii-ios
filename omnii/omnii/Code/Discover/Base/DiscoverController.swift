//
//  DiscoverMapController.swift
//  omnii
//
//  Created by huyang on 2023/6/2.
//

import UIKit
import CommonUtils

class DiscoverController: UIViewController {
    
    var navigationShadowView: UIView!
    var navigationBar: NavigationBar!
    var browseButton: UIButton!
    var horizontalAdapter: DiscoverHorizontalCardController!
    var verticalAdapter : DiscoverVerticalCardController!
    
    // report
    private var showReport: Bool = false
    private var showReportCompletion: Bool = false
    
    let viewModel: DiscoverViewModel
    
    deinit {
        print("DiscoverMapController deinit")
    }
    
    init(viewModel: DiscoverViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBlue
        
        setupViews()
        
        navigationBar.backAction = { [unowned self] in
            self.dismiss(animated: true)
        }
        
    }
    
    func isBrowseButtonHidden(_ isHidden: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.browseButton.y = isHidden ? ScreenHeight : (ScreenHeight - ScreenFit.safeBottomHeight - self.browseButton.height)
        }
    }
   
}

extension DiscoverController {
    
    private func setupViews() {
        
        horizontalAdapter = DiscoverHorizontalCardController(viewController: self, viewModel: viewModel).then {
            $0.isHidden = true
        }
        verticalAdapter = DiscoverVerticalCardController(viewController: self, viewModel: viewModel).then {
            $0.isHidden = false
        }
        
        navigationShadowView = UIView().then {
            $0.isUserInteractionEnabled = false
            let size = CGSize(width: ScreenWidth, height: 200.rpx)
            $0.frame = CGRect(origin: .zero, size: size)
            $0.backgroundColor = UIColor.discoverNavigationShadowGradient(size: size)
        }
        
        navigationBar = NavigationBar().then {
            $0.backgroundColor = .clear
            $0.setButtonBackgroudColor(.black.withAlphaComponent(0.2))
        }
        
        browseButton = UIButton().then {
            $0.isSelected = true
            let size = CGSize(width: 120.rpx, height: 40.rpx)
            let x = (ScreenWidth - size.width) / 2.0
            let y = ScreenHeight - ScreenFit.safeBottomHeight - size.height
            $0.frame = CGRect(x: x, y: y, size: size)
            let color = UIColor.purpleVerticalGradient(size: size)
            $0.setRoundBackgroundColor(color, for: .normal)
            $0.setTitle("Browse", for: .normal)
            $0.setTitle("Browse", for: [.normal, .highlighted])
            $0.setTitle("Map view", for: .selected)
            $0.setTitle("Map view", for: [.selected, .highlighted])
        }
        
        browseButton.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        
        view.addSubviews([navigationShadowView,
                          navigationBar,
                          browseButton])
    }
    
    @objc private func click(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            showVerticalCollectionView(animated: true)
        } else {
            showHorizontalCollectionView(animated: true)
        }
    }
    
    func showHorizontalCollectionView(animated: Bool) {
        guard horizontalAdapter.isHidden else { return }
        
        if animated {
            horizontalAdapter.alpha = 0.0
            horizontalAdapter.isHidden = false
            UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseIn) {
                self.navigationBar.setButtonBackgroudColor(.black.withAlphaComponent(0.2))
                self.verticalAdapter.alpha = 0.0
                self.horizontalAdapter.alpha = 1.0
            } completion: { _ in
                self.verticalAdapter.isHidden = true
                self.verticalAdapter.alpha = 1.0
            }
            
        } else {
            
            navigationBar.setButtonBackgroudColor(.black.withAlphaComponent(0.2))
            horizontalAdapter.isHidden = false
            verticalAdapter.isHidden = true
        }
    }
    
    func showVerticalCollectionView(animated: Bool) {
        guard verticalAdapter.isHidden else { return }
        
        if animated {
            verticalAdapter.alpha = 0.0
            verticalAdapter.isHidden = false
            UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseOut) {
                self.navigationBar.setButtonBackgroudColor(.white.withAlphaComponent(0.1))
                self.verticalAdapter.alpha = 1.0
                self.horizontalAdapter.alpha = 0.0
            } completion: { _ in
                self.horizontalAdapter.isHidden = true
                self.horizontalAdapter.alpha = 1.0
            }
            
        } else {
            
            navigationBar.setButtonBackgroudColor(.white.withAlphaComponent(0.1))
            horizontalAdapter.isHidden = true
            verticalAdapter.isHidden = false
        }
    }
    
}

// MARK: - report sheet
extension DiscoverController {
    
    func moreSheet() {
        let items = [CommonSheetItem(title: "Report", icon: UIImage(named: "discover_report")!, tapDismiss: true)]
        let sheet = CommonSheetController(items: items)
        sheet.selectedHandler = { [unowned self] _ in
            self.showReport = true
        }
        present(sheet,
                transionStyle: .sheet,
                tapGestureDismissal: true,
                panGestureDismissal: true,
                dismissCompletion:  { [unowned self] in
            
            if self.showReport {
                self.presentReportSheet()
                self.showReport = false
            }
        })
    }
    
    func presentReportSheet() {
        let items = [
            PickerEntity(title: "I just don't like it"),
            PickerEntity(title: "Nuditv or sexual activity"),
            PickerEntity(title: "Hate speech or symbols"),
            PickerEntity(title: "Bullying or harassment"),
            PickerEntity(title: "false information"),
            PickerEntity(title: "Scam or fraud"),
            PickerEntity(title: "Something else")
        ]
        let sheet = pickerSheet(items: items,
                                height: 541.rpx,
                                title: "Report",
                                buttonTitle: "Submit",
                                confirmDismiss: true) { [unowned self] state in
            switch state {
            case let .select(entity):
                if entity.title == items.last?.title {
                    // TODO: - Something else
                    print("Something else")
                }
            case .confirm(_):
                self.showReportCompletion = true
            }
        }
        
        presentSheet(sheet,
                     tapGestureDismissal: true,
                     panGestureDismissal: true,
                     dismissCompletion: { [unowned self] in
            
            if self.showReportCompletion {
                self.presentCompletionSheet()
                self.showReportCompletion = false
            }
        })
    }
    
    func presentCompletionSheet() {
        let sheet = DiscoverReportCompletionSheet()
        present(sheet,
                transionStyle: .sheet,
                tapGestureDismissal: true,
                panGestureDismissal: true)
    }
    
}
