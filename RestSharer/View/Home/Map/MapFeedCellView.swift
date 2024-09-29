//
//  MapFeedCellView.swift
//  RestSharer
//
//  Created by 변상우 on 5/10/24.
//

import SwiftUI
import NMapsMap
import Kingfisher

struct MapFeedCellView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var feedStore: FeedStore
    @EnvironmentObject private var chatStore: ChatStore
    
    @State private var currentPicture = 0
    @State private var isChatRoomActive: Bool = false
    @State private var isShowingChatSendView: Bool = false
    @State private var isActionSheetPresented = false
    @State private var isFeedUpdateViewPresented: Bool = false
    @State private var isShowingMessageTextField: Bool = false
    @State private var isChangePlaceColor: Bool = false
    @State private var messageToSend: String = ""
    @State private var message: String = ""
    @State private var searchResult: SearchResult = SearchResult(title: "", category: "", address: "", roadAddress: "", mapx: "", mapy: "")
    
    var feed: MyFeed
    
    var body: some View {
        VStack {
            HStack {
                KFImage(URL(string: feed.writerProfileImage))
                    .resizable()
                    .placeholder {
                        Image("userDefault")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: .screenWidth*0.13, height: .screenWidth*0.13)
                    }
                    .clipShape(Circle())
                    .frame(width: .screenWidth*0.13, height: .screenWidth*0.13)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(feed.writerNickname)")
                        .font(.pretendardMedium16)
                    Text("\(feed.createdDate)")
                        .font(.pretendardRegular12)
                        .foregroundColor(.primary.opacity(0.8))
                }
                Spacer()
            }
            .padding(.top, 15)
            .padding(.leading, 20)
            .padding(.bottom, 10)
            
            HStack(alignment: .top) {
                TabView(selection: $currentPicture) {
                    ForEach(feed.images, id: \.self) { image in
                        KFImage(URL(string: image )) .placeholder {
                            Image(systemName: "photo")
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: .screenWidth * 0.45, height: .screenWidth * 0.45)
                        .tag(Int(feed.images.firstIndex(of: image) ?? 0))
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(width: .screenWidth * 0.45, height: .screenWidth * 0.45)
                .padding(.trailing, 15)
                
                VStack(alignment: .leading) {
                    Text("\(feed.contents)")
                        .font(.pretendardRegular16)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    if feed.writerNickname != userStore.user.nickname {
                        HStack {
                            Spacer()
                            Button {
                                if (userStore.user.bookmark.contains("\(feed.id)")) {
                                    userStore.deletePlace(feed)
                                    userStore.user.bookmark.removeAll { $0 == "\(feed.id)" }
                                    userStore.updateUser(user: userStore.user)
                                    userStore.clickSavedCancelPlaceToast = true
                                    isChangePlaceColor.toggle()
                                } else {
                                    userStore.savePlace(feed) //장소 저장 로직(사용가능)
                                    userStore.user.bookmark.append("\(feed.id)")
                                    userStore.updateUser(user: userStore.user)
                                    userStore.clickSavedPlaceToast = true
                                    isChangePlaceColor.toggle()
                                }
                            } label: {
                                Image(systemName: userStore.user.bookmark.contains("\(feed.id)") ? "pin.fill": "pin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15)
                                    .padding(.horizontal, 10)
                                    .foregroundColor(isChangePlaceColor ? .privateColor : .white)
                                    .foregroundColor(userStore.user.bookmark.contains("\(feed.id)") ? .privateColor : .primary)
                            }
                            Button {
                                if(userStore.user.myFeed.contains("\(feed.id)")) {
                                    userStore.deleteSavedFeed(feed)
                                    userStore.user.myFeed.removeAll { $0 == "\(feed.id)" }
                                    userStore.updateUser(user: userStore.user)
                                    userStore.clickSavedCancelFeedToast = true
                                } else {
                                    userStore.saveFeed(feed) //장소 저장 로직(사용가능)
                                    userStore.user.myFeed.append("\(feed.id)")
                                    userStore.updateUser(user: userStore.user)
                                    userStore.clickSavedFeedToast = true
                                }
                            } label: {
                                if colorScheme == ColorScheme.dark {
                                    Image(userStore.user.myFeed.contains("\(feed.id)") ? "bookmark_fill" : "bookmark_dark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .padding(.trailing, 5)
                                } else {
                                    Image(userStore.user.myFeed.contains( "\(feed.id)" ) ? "bookmark_fill" : "bookmark_light")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .padding(.trailing, 5)
                                }
                            }
                            
                            Button {
                                withAnimation {
                                    isShowingMessageTextField.toggle()
                                }
                            } label: {
                                Image(systemName: isShowingMessageTextField ? "paperplane.fill" : "paperplane")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .foregroundColor(isShowingMessageTextField ? .privateColor : .white)
                            }
                        }
                        .font(.pretendardMedium24)
                        .foregroundColor(.primary)
                        .padding(.trailing, 10)
                    }
                }
                Spacer()
            }
            .padding(.leading, 20)
            
            if isShowingMessageTextField {
                SendMessageTextField(text: $message, placeholder: "메시지를 입력하세요") {
                    chatStore.myEmail = userStore.user.email
                    chatStore.myNickname = userStore.user.nickname
                    chatStore.otherEmail = "cartman2540@gmail.com"
                    chatStore.otherNickname = "new"
                    chatStore.sendMessage(text: message, senderNickname: userStore.user.nickname)
                    message = ""
                }
                .padding(.horizontal, 20)
            }
            
            Divider()
                .padding(.vertical, 10)
        }
    }
}

//struct MapFeedCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapFeedCellView()
//    }
//}
