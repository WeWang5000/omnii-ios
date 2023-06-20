//
//  ShareFriendModel.swift
//  omnii
//
//  Created by huyang on 2023/5/30.
//

import Foundation
import CommonUtils

struct FriendsListModel: Decodable {
    
    // 返回记录的总数
    let total: Int
    // 当前页
    let current: Int
    // 每页数量
    let size: Int
    // 朋友列表
    let records: [FriendModel]
    
}

struct FriendModel: Decodable {
    
    let userId: String
    // 用户账号
    let userOmniiNo: String
    // 头像
    @Default.Empty var userAvatar: String
    // 昵称
    @Default.Empty var userNickName: String
    // 好友添加方式:来源
    @Default.Empty var origin: String
    // 好友关系建立时间
    @Default.Empty var relationshipEstablishmentDateTime: String
    // 计算好友持续时长，毫秒
    @Default.Zero var calculateFriendDuration: Int64
    // 依据现有规则，确定好友关系是否新好友
    @Default.False var relationshipIsNew: Bool
    // 当前新发布的有效瞬间
    @Default.Zero var currentMomentsCount: Int
    // 当前新发布的有效邀请
    @Default.Zero var currentInvitesCount: Int
    // 发布的瞬间总数
    @Default.Zero var totalMomentsCount: Int
    // 发布的邀请总数
    @Default.Zero var totalInvitesCount: Int
    
}

extension FriendModel: Comparable {
    
    static func < (lhs: FriendModel, rhs: FriendModel) -> Bool {
        return lhs.userNickName < rhs.userNickName
    }
    
    static func == (lhs: FriendModel, rhs: FriendModel) -> Bool {
        return lhs.userId == rhs.userId
    }
    
}
