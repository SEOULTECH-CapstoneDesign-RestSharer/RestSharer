//
//  MapMainView.swift
//  RestSharer
//
//  Created by 변상우 on 5/10/24.
//

import SwiftUI
import UIKit
import NMapsMap
//import PopupView

struct MapMainView: View {
    
//    @StateObject private var locationSearchStore = LocationSearchStore.shared
    @StateObject var coordinator: Coordinator = Coordinator.shared
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var feedStore: FeedStore
    @EnvironmentObject var followStore: FollowStore
    
    @Binding var root: Bool
    @Binding var selection: Int
    
    @State private var coord: NMGLatLng = NMGLatLng(lat: 0.0, lng: 0.0)
    
    @State private var filteredFeeds: [MyFeed] = []
    
    var body: some View {
        ZStack {
            VStack {
                if filteredFeeds.isEmpty {
                    Text("검색 탭으로 이동해 원하는 유저를 팔로우하세요!")
                        .font(.pretendardRegular14)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.darkGrayColor)
                        .cornerRadius(30)
                    NaverMap(currentFeedId: $coordinator.currentFeedId, showMarkerDetailView: $coordinator.showMarkerDetailView,
                     markerTitle: $coordinator.newMarkerTitle,
                     markerTitleEdit: $coordinator.newMarkerAlert, coord: $coordinator.coord)
                } else {
                    NaverMap(currentFeedId: $coordinator.currentFeedId, showMarkerDetailView: $coordinator.showMarkerDetailView,
                     markerTitle: $coordinator.newMarkerTitle,
                     markerTitleEdit: $coordinator.newMarkerAlert, coord: $coordinator.coord)
                }
            }
        }
        .refreshable {
            await feedStore.fetchFeeds()
        }
        
        .onAppear {
            // 팔로잉 목록을 가져오는 비동기 작업
            Task {
                await followStore.fetchFollowerFollowingList(userStore.user.email)
                
                // fetchFollowerFollowingList가 완료된 후에 실행될 코드
                filteredFeeds = feedStore.feedList.filter { feed in
                    followStore.followingList.contains(feed.writerNickname) || feed.writerNickname == userStore.user.nickname
                }
                print("Filtered Feeds after update: \(filteredFeeds)")

                coordinator.checkIfLocationServicesIsEnabled()
                Coordinator.shared.feedList = filteredFeeds
                coordinator.makeMarkers()
                
                print("Following list after fetch in MapMainView: \(followStore.followingList)")
            }
        }
        
        .sheet(isPresented: $coordinator.showMarkerDetailView) {
            MapFeedSheetView(feed: filteredFeeds.filter { $0.address == coordinator.currentFeedId })
                .presentationDetents([.height(.screenHeight * 0.5)])
        }
        
//        .popup(isPresented: $authStore.welcomeToast) {
//            ToastMessageView(message: "Private에 오신걸 환영합니다!")
//                .onDisappear {
//                    authStore.welcomeToast = false
//                }
//        } customize: {
//            $0
//                .autohideIn(2)
//                .type(.floater(verticalPadding: 20))
//                .position(.bottom)
//                .animation(.spring())
//                .closeOnTapOutside(true)
//                .backgroundColor(.clear)
//        }
    }
    
    // 팔로잉한 작성자의 피드만 필터링하는 함수
//    var filteredFeeds: [MyFeed] {
//        let followingList = followStore.followingList // followStore에서 팔로잉 리스트 가져옴
//        print("Following list in filteredFeeds: \(followingList)")
//
//        return feedStore.feedList.filter { feed in
//            let isFollowing = followingList.contains(feed.writerNickname)
//            print("Is following \(feed.writerNickname): \(isFollowing)")
//            return isFollowing
//        }
//    }
}

//struct MapMainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapMainView()
//            .environmentObject(ShopStore())
//            .environmentObject(FeedStore())
//    }
//}
