//
//  ChatRoomListView.swift
//  RestSharer
//
//  Created by 변상우 on 8/7/24.
//

import SwiftUI

struct ChatRoomListView: View {
    
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var userStore: UserStore

    var body: some View {
        NavigationView {
            List(chatStore.chatRooms, id: \.self) { chatRoom in
                NavigationLink {
                    ChatView()
                } label: {
                    Text(chatRoom)
                        .padding()
                }
            }
        }
        .navigationBarTitle("Chat Rooms", displayMode: .inline)
        
        .onAppear {
            chatStore.fetchChatRooms(myEmail: userStore.user.email)
        }
    }
}
