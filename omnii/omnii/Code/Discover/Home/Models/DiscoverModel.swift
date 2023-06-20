//
//  DiscoverModel.swift
//  omnii
//
//  Created by huyang on 2023/6/14.
//

import Foundation
import CommonUtils

struct DiscoverModel: Decodable {
    
    let current: Int
    let size: Int
    let total: Int
    let hasNext: Bool
    let records: [DiscoverRecordModel]
    
}

struct DiscoverRecordModel: Decodable {
    
    struct ShareScopeType: RawRepresentable, Decodable {
        static let everyone = ShareScopeType(rawValue: "EVERYONE")
        static let friend = ShareScopeType(rawValue: "FRIEND")
        static let foryou = ShareScopeType(rawValue: "FORYOU")

        let rawValue: String
    }
    
    struct InteractionType: RawRepresentable, Decodable {
        static let invite = InteractionType(rawValue: "INVITE")
        static let moment = InteractionType(rawValue: "MOMENT")

        let rawValue: String
    }
    
    let id: Int64
    let userId: String
    let type: String
    let likeNum: Int64
    let commentNum: Int64
    let content: String
    
    let owner: DiscoverRecordOwnerModel
    
    let shareScopeType: ShareScopeType
    let interactionType: InteractionType
    
    @Default.Empty var createDatetime: String

    /// moment
    @Default.Empty var imageUrl: String

    /// geo
    @Default.Empty var address: String
    @Default.Empty var name: String
    @Default.Empty var description: String
    @Default.Zero var latitude: Double
    @Default.Zero var longitude: Double
    
    /// invite
    @Default.Zero var limitNum: Int
    @Default.Zero var participatedNum: Int
    @Default.Empty var appointedTime: String
    @Default.Empty var participatedUsers: [DiscoverRecordOwnerModel]
    
}

struct DiscoverRecordOwnerModel: Codable {
    
    let userNickName: String
    let userLocalUserId: String
    @Default.Empty var userRealName: String
    @Default.Empty var userAvatar: String
    
}
