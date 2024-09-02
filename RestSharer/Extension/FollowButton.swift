//
//  FollowButton.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.
//

import SwiftUI

struct FollowButton: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var followStore: FollowStore

    var user: User
    
    @State private var backgroundColor = Color.white

    var body: some View {
        Button {
            followStore.followCheck.toggle()
            followStore.manageFollow(
                userNickname: user.nickname,              // 상대방의 닉네임
                myNickname: userStore.user.nickname,      // 자신의 닉네임
                userEmail: user.email,                    // 상대방의 이메일
                myEmail: userStore.user.email             // 자신의 이메일
            )
        } label: {
            Text((followStore.followCheck) ? "팔로우" : "팔로잉")
        }
        .background((followStore.followCheck) ? Color("AccentColor") : Color.white)
    }
}
