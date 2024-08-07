//
//  FeedListView.swift
//  RestSharer
//
//  Created by 강민수 on 8/5/24.
//

import SwiftUI
import NMapsMap


struct FeedListView: View {
    @EnvironmentObject var feedStore : FeedStore
    @EnvironmentObject var followStore : FollowStore
    @EnvironmentObject var userStore : UserStore
    
    @Binding var root: Bool
    @Binding var selection: Int
    
    //    @State private var searchResult: SearchResult = SearchResult(title: "", category: "", address: "", roadAddress: "", mapx: "", mapy: "")
    var body: some View {
        
        NavigationView {
            //MARK: 팔로잉 리스트 체크
            if followStore.followingList.isEmpty {
                EmptyFeed(feedType: .noFollowing)
            }
            //MARK: 피드리스트 체크
            else if feedStore.feedList.isEmpty {
                EmptyFeed(feedType: .noFeed)
            } else {

                List {
                    ForEach(feedStore.feedList, id:\.self) { feed in
                        FeedCellView(feed: feed, root:$root, selection:$selection)
                    }
                }
                .navigationBarTitle("팔로워의 리뷰", displayMode: .inline)
                .onAppear{
                    followStore.fetchFollowerFollowingList(userStore.user.email)
                 
                }
            }
        }
    }
}
