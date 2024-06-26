//
//  MyFollowerFollowingView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI

struct MyFollowerFollowingView: View {
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var followStore: FollowStore
    
    let user: User
    var followerList : [String]
    var followingList : [String]
    
    @State var viewNumber: Int
    
    var body: some View {
        NavigationStack {
            HStack {
                Spacer()
                Button {
                    viewNumber = 0
                } label: {
                    HStack {
                        Text("\(followerList.count)")
                        Text("팔로워")
                    }
                    .font(.pretendardSemiBold16)
                    .padding(.bottom, 15)
                    .foregroundColor(.primary)
                    .modifier(BottomBorder(showBorder: viewNumber == 0))
                }
                Spacer()
                Button {
                    viewNumber = 1
                } label: {
                    HStack {
                        Text("\(followingList.count)")
                        Text("팔로잉")
                    }
                    .font(.pretendardSemiBold16)
                    .padding(.bottom, 15)
                    .foregroundColor(.primary)
                    .modifier(BottomBorder(showBorder: viewNumber == 1))
                }
                Spacer()
            }
            .padding(.bottom, 10)
            TabView (selection: $viewNumber) {
                MyFollowerView(user: user, followerList: followerList).tag(0)
                MyFollowingView(user: user, followingList: followingList).tag(1)
            }
            .tabViewStyle(PageTabViewStyle())
            .padding([.leading,.trailing],5)
        }
        .navigationTitle("\(user.nickname)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .backButtonArrow()
    }
}

struct MyFollowerFollowingView_Previews: PreviewProvider {
    static var previews: some View {
        MyFollowerFollowingView(user: User(), followerList: [""], followingList: [""], viewNumber:0).environmentObject(UserStore())
    }
}
