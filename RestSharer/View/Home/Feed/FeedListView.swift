//
//  FeedListView.swift
//  RestSharer
//
//  Created by 강민수 on 8/5/24.
//

import SwiftUI
import NMapsMap

struct FeedListView: View {
    @EnvironmentObject var feedStore: FeedStore
    @EnvironmentObject var followStore: FollowStore
    @EnvironmentObject var userStore: UserStore
    
    @Binding var root: Bool
    @Binding var selection: Int
    
    var body: some View {
        NavigationView {
            // MARK: 팔로잉 리스트 체크
            if followStore.followingList.isEmpty {
                EmptyFeed(feedType: .noFollowing)
            }
            // MARK: 피드리스트 체크
            else if feedStore.feedList.isEmpty {
                EmptyFeed(feedType: .noFeed)
            } else {
                List {
                    // 필터링하여 팔로잉하는 사용자의 피드만 표시
                    ForEach(feedStore.feedList.filter { feed in
                        followStore.followingList.contains(feed.writerNickname)
                    }, id: \.self) { feed in
                        FeedCellView(feed: feed, root: $root, selection: $selection)
                    }
                }
                .navigationBarTitle("팔로워의 리뷰", displayMode: .inline)
                .onAppear {
                    Task {
                        await followStore.fetchFollowerFollowingList(userStore.user.email)
                        print("팔로잉 리스트: \(followStore.followingList)")
                        print("피드 리스트: \(feedStore.feedList)")
                    }
                }
            }
        }
    }
}
