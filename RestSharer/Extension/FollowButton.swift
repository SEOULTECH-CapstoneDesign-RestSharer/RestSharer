//
//  FollowButton.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.


//import SwiftUI
//
//struct FollowButton: View {
//    @EnvironmentObject var userStore: UserStore
//    @EnvironmentObject var followStore: FollowStore
//
//    var user: User
//    
//    @State private var backgroundColor = Color.white
//
//    var body: some View {
//        Button {
//            followStore.followCheck.toggle()
//            followStore.manageFollow(
//                userNickname: user.nickname,              // 상대방의 닉네임
//                myNickname: userStore.user.nickname,      // 자신의 닉네임
//                userEmail: user.email,                    // 상대방의 이메일
//                myEmail: userStore.user.email             // 자신의 이메일
//            )
//        } label: {
//            Text((followStore.followCheck) ? "팔로우" : "팔로잉")
//        }
//        .background((followStore.followCheck) ? Color("AccentColor") : Color.white)
//    }
//}
import SwiftUI

struct FollowButton: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var followStore: FollowStore

    var user: User

    var body: some View {
        Button {
            print("myEmail: \(userStore.user.email), userEmail: \(user.email)")
            if followStore.followCheck { // 현재 팔로우 중일 때
                followStore.unfollow(
                    userNickname: user.nickname,
                    myNickname: userStore.user.nickname,
                    userEmail: user.email,
                    myEmail: userStore.user.email
                ) {
                    followStore.followCheck = false // 언팔로우 후 상태 업데이트
                }
            } else { // 현재 팔로우 중이지 않을 때
                followStore.follow(
                    userNickname: user.nickname,
                    myNickname: userStore.user.nickname,
                    userEmail: user.email,
                    myEmail: userStore.user.email
                ) {
                    followStore.followCheck = true // 팔로우 후 상태 업데이트
                }
            }
        } label: {
            Text(followStore.followCheck ? "팔로잉" : "팔로우")
                .font(.pretendardSemiBold14)
                .frame(width: .screenWidth * 0.5, height: 32)
                .foregroundColor(.black)
                .background(followStore.followCheck ? Color("AccentColor") : Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: followStore.followCheck ? 0 : 1)
                )
        }
    }
}
