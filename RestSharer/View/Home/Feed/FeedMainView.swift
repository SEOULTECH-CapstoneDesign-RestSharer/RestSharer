import SwiftUI

struct FeedMainView: View {
    
    @EnvironmentObject var feedStore: FeedStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var followStore: FollowStore
    @Binding var root: Bool
    @Binding var selection: Int
    
    var body: some View {
        ScrollView {
            // feedList에서 팔로잉한 작성자의 피드만 필터링
            ForEach(filteredFeeds) { feed in
                FeedCellView(feed: feed, root: $root, selection: $selection)
                    .padding(.bottom, 15)
            }
        }
        .refreshable {
            await feedStore.fetchFeeds()
        }
        .onAppear {
            // 팔로잉 목록을 가져오는 비동기 작업
            Task {
                await followStore.fetchFollowerFollowingList(userStore.user.email)
                print("Following list after fetch in FeedMainView: \(followStore.followingList)")
            }
        }
        .popup(isPresented: $userStore.clickSavedFeedToast) {
            ToastMessageView(message: "피드가 저장 되었습니다!")
                .onDisappear {
                    userStore.clickSavedFeedToast = false
                }
        } customize: {
            $0
                .autohideIn(1)
                .type(.floater(verticalPadding: 20))
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.clear)
        }
        .popup(isPresented: $userStore.clickSavedPlaceToast) {
            ToastMessageView(message: "장소가 저장 되었습니다!")
                .onDisappear {
                    userStore.clickSavedPlaceToast = false
                }
        } customize: {
            $0
                .autohideIn(1)
                .type(.floater(verticalPadding: 20))
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.clear)
        }
        .popup(isPresented: $userStore.clickSavedCancelFeedToast) {
            ToastMessageView(message: "피드 저장이 취소 되었습니다!")
                .onDisappear {
                    userStore.clickSavedCancelFeedToast = false
                }
        } customize: {
            $0
                .autohideIn(1)
                .type(.floater(verticalPadding: 20))
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.clear)
        }
        .popup(isPresented: $userStore.clickSavedCancelPlaceToast) {
            ToastMessageView(message: "장소 저장이 취소 되었습니다!")
                .onDisappear {
                    userStore.clickSavedCancelPlaceToast = false
                }
        } customize: {
            $0
                .autohideIn(1)
                .type(.floater(verticalPadding: 20))
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.clear)
        }
    }
    
    // 팔로잉한 작성자의 피드만 필터링하는 함수
    var filteredFeeds: [MyFeed] {
        let followingList = followStore.followingList // followStore에서 팔로잉 리스트 가져옴
        print("Following list in filteredFeeds: \(followingList)")

        return feedStore.feedList.filter { feed in
            let isFollowing = followingList.contains(feed.writerNickname) || feed.writerNickname == userStore.user.nickname
            print("Is following \(feed.writerNickname): \(isFollowing)")
            return isFollowing
        }
    }
}

struct FeedMainView_Previews: PreviewProvider {
    static var previews: some View {
        FeedMainView(root: .constant(true), selection: .constant(0))
            .environmentObject(FeedStore())
            .environmentObject(UserStore())
            .environmentObject(FollowStore())
    }
}
