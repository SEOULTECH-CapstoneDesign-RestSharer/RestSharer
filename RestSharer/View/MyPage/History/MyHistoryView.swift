//
//  MyHistoryView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI
import Kingfisher

struct MyHistoryView: View {
    @EnvironmentObject private var userStore: UserStore
//    @EnvironmentObject private var reservationStore: ReservationStore
    @EnvironmentObject private var feedStore: FeedStore
    
    @State var isFeed: Bool = true
    @State var isMap: Bool = false
    @State var isReservation: Bool = false
    @State var isMyPageFeedSheet: Bool = false
    
    @Binding var root: Bool
    @Binding var selection: Int
    
    var columns: [GridItem] = [GridItem(.fixed(.screenWidth*0.33), spacing: 1, alignment:  nil),
                               GridItem(.fixed(.screenWidth*0.33), spacing: 1, alignment:  nil),
                               GridItem(.fixed(.screenWidth*0.33), spacing: 1, alignment:  nil)]
    
    var body: some View {
        VStack {
            if (isFeed == true) {
                ScrollView(showsIndicators: false) {
                    if userStore.myFeedList.isEmpty {
                        Text("게시물이 존재 하지 않습니다.")
                            .font(.pretendardMedium20)
                            .foregroundStyle(.primary)
                            .padding(.top, .screenHeight * 0.2 + 37.2)
                    } else {
                        LazyVGrid(
                            columns: columns,
                            alignment: .center,
                            spacing: 1
                        ) {
                            ForEach(userStore.myFeedList, id: \.self) { feed in
                                Button {
                                    feedStore.selctedFeed = feed
                                    isMyPageFeedSheet = true
                                } label: {
                                    KFImage(URL(string:feed.images[0])) .placeholder {
                                        Image(systemName: "photo")
                                    }.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: .screenWidth*0.33,height: .screenWidth*0.33)
                                        .clipShape(Rectangle())
                                }
                                .fullScreenCover(isPresented: $isMyPageFeedSheet) {
                                    MyPageFeedView(isMyPageFeedSheet: $isMyPageFeedSheet, root:$root, selection:$selection, feed: feedStore.selctedFeed, feedList: userStore.myFeedList, isMyFeedList: true)
                                }
                            }
                        }
                    }
                }
            }
            Spacer()
        }
    }
}
