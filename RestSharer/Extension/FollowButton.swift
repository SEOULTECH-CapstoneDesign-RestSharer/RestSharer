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

    var user:User
    
    @State private var backgroundColor = Color.white
    

    var body: some View {
        Button {
            followStore.followCheck.toggle()
            followStore.manageFollow(userId: user.nickname, myNickName: userStore.user.nickname, userEmail: user.email)
        } label: {
            Text((followStore.followCheck) ? "팔로우" : "팔로잉")
        }
        .background((followStore.followCheck) ? Color("AccentColor") : Color.white)
    }
}
