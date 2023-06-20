//
//  DiscoverRecordViewModel.swift
//  omnii
//
//  Created by huyang on 2023/6/15.
//

import Foundation
import Combine
import IGListDiffKit

protocol DiscoverRecordViewModelInputs {
    func requestLike()
    func requestJoinInvite()
    
    // 卡片内按钮点击事件回调
    func tapHandler(controller: DiscoverController) -> ((DiscoverCardTapEvents) -> Void)
}

protocol DiscoverRecordViewModelOutputs {
    
}

final class DiscoverRecordViewModel {
    
    var input: DiscoverRecordViewModelInputs { self }
    var output: DiscoverRecordViewModelOutputs { self }
    
    struct TextLayout {
        let attrs: [NSAttributedString.Key : Any]
        let height: Double
    }
    
    let model: DiscoverRecordModel
    
    var contentHorizontalLayout: TextLayout?
    var contentVerticalLayout: TextLayout?
    
    var contentExpand: Bool = false
    @Published var like: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    init(model: DiscoverRecordModel) {
        self.model = model
        self.contentHorizontalLayout = layoutContent(scale: 190.0 / 355.0)
        self.contentVerticalLayout = layoutContent(scale: 1.0)
    }
    
    private func layoutContent(scale: Double) -> TextLayout {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        let attrs: [NSAttributedString.Key : Any] = [.font : UIFont(type: .montserratBlod, size: 25.rpx * scale)!,
                                                     .paragraphStyle: paragraphStyle]
        let height = model.content.height(attributes: attrs, containerWidth: 315.rpx * scale)
        return TextLayout(attrs: attrs, height: height)
    }
    
    private func toLike() {
        let params = ["id" : model.id]
        Provider.requestPublisher(.momentLike(params))
            .filterSuccessfulStatusCodes()
            .filterBody()
            .showErrorToast()
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(_) = completion {
                    self.like = false
                }
            }, receiveValue: { [unowned self] model in
                print(model)
                self.like = true
            })
            .store(in: &cancellables)
    }
    
    private func toDisLike() {
        let params = ["id" : model.id]
        Provider.requestPublisher(.momentDisLike(params))
            .filterSuccessfulStatusCodes()
            .filterBody()
            .showErrorToast()
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(_) = completion {
                    self.like = false
                }
            }, receiveValue: { [unowned self] model in
                print(model)
                self.like = true
            })
            .store(in: &cancellables)
    }
    
}

extension DiscoverRecordViewModel: DiscoverRecordViewModelInputs {
    
    func requestJoinInvite() {
        let params = ["inviteId" : model.id]
        Provider.requestPublisher(.inviteJoin(params))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .catchErrorWithToast()
            .sink { json in
                print(json)
            }
            .store(in: &cancellables)
    }
    
    func requestLike() {
        like.toggle()
        like ? toLike() : toDisLike()
    }
    
    func tapHandler(controller: DiscoverController) -> ((DiscoverCardTapEvents) -> Void) {
        return { [unowned self] event in
            switch event {
            case .more:
                controller.moreSheet()
            case .like:
                self.requestLike()
            default:
                controller.warningAlert(title: "Waiting", message: "It's Coming Soon")
                break
            }
        }
    }
    
}

extension DiscoverRecordViewModel: DiscoverRecordViewModelOutputs {
    
}


extension DiscoverRecordViewModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return model.id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? DiscoverRecordViewModel else { return false }
        return model.id == object.model.id
    }
    
}
