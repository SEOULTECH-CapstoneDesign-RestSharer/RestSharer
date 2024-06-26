//
//  MySavedView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI
import Kingfisher

struct MySavedView: View {
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var feedStore: FeedStore
    
    @State var isMyPageFeedSheet: Bool = false
    @State private var isLongPressing = false
    
    @Binding var root: Bool
    @Binding var selection: Int
    
    var columns: [GridItem] = [GridItem(.fixed(.screenWidth*0.33), spacing: 1, alignment:  nil),
                               GridItem(.fixed(.screenWidth*0.33), spacing: 1, alignment:  nil),
                               GridItem(.fixed(.screenWidth*0.33), spacing: 1, alignment:  nil)]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if userStore.mySavedFeedList.isEmpty {
                Text("저장한 피드가 없습니다.")
                    .font(.pretendardMedium20)
                    .foregroundStyle(.primary)
                    .padding(.top, .screenHeight * 0.2 + 37.2)
            } else {
                LazyVGrid(
                    columns: columns,
                    alignment: .center,
                    spacing: 1
                ) {
                    ForEach(userStore.mySavedFeedList, id: \.self) { feed in
                        Button {
                            feedStore.selctedFeed = feed
                            isMyPageFeedSheet = true
                        } label: {
                            KFImage(URL(string:feed.images[0])) .placeholder {
                                Image(systemName: "photo")
                            }.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: .screenWidth * 0.33, height: .screenWidth * 0.33)
                                .clipShape(Rectangle())
                        }
                        .fullScreenCover(isPresented: $isMyPageFeedSheet) {
                            MyPageFeedView( isMyPageFeedSheet: $isMyPageFeedSheet, root:$root, selection:$selection, feed: feedStore.selctedFeed, feedList: userStore.mySavedFeedList, isMyFeedList: false)
                        }
                        .gesture(
                            LongPressGesture()
                                .onChanged { _ in
                                    isLongPressing = true
                                }
                        )
                        .contextMenu(ContextMenu(menuItems: {
                            Button("선택한 피드 삭제") {
                                userStore.deleteSavedFeed(feed)
                                userStore.user.myFeed.removeAll { $0 == feed.id }
                                userStore.updateUser(user: userStore.user)
                            }
                        }))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
