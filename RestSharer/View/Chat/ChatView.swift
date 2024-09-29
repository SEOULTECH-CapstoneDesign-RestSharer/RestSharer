//
//  ChatView.swift
//  RestSharer
//
//  Created by 변상우 on 9/29/24.
//

import SwiftUI
import FirebaseAuth

struct ChatView: View {
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var chatStore: ChatStore
    
    @State private var messageText = ""

    var body: some View {
        VStack {
            List(chatStore.messages) { message in
                HStack {
                    if message.senderNickname == userStore.user.nickname {
                        Spacer()
                        Text(message.text)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    } else {
                        Text(message.text)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        Spacer()
                    }
                }
            }
            HStack {
                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)

                Button {
                    chatStore.myEmail = userStore.user.email
                    chatStore.myNickname = userStore.user.nickname
                    chatStore.otherEmail = "cartman2540@gmail.com"
                    chatStore.otherNickname = "new"
                    chatStore.sendMessage(text: messageText, senderNickname: userStore.user.nickname)
                    messageText = ""
                } label: {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationBarTitle("Chat", displayMode: .inline)
        
        .onAppear {
            chatStore.loadMessages(myEmail: userStore.user.email, otherNickname: "new")
        }
    }
}

#Preview {
    ChatView()
}
