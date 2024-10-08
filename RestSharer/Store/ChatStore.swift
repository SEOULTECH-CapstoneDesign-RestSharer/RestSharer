//
//  ChatStore.swift
//  RestSharer
//
//  Created by 변상우 on 9/29/24.
//

import Foundation

import FirebaseFirestore

class ChatStore: ObservableObject {
    
    @Published var chatRooms: [String] = []
    @Published var messages: [Message] = []
    
    private var db = userCollection
    var myEmail = ""
    var myNickname = ""
    var otherEmail = ""
    var otherNickname = ""
    
    func fetchChatRooms(myEmail: String) {
        print("myEmail: \(myEmail)")
        db.document(myEmail).collection("MyChatRoom").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let documents = querySnapshot?.documents {
                    self.chatRooms = documents.map { $0.documentID }
                }
            }
        }
        
        print("self.chatRooms: \(self.chatRooms)")
    }

    func loadMessages(myEmail: String, otherNickname: String) {
        db.document(myEmail).collection("MyChatRoom").document(otherNickname).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading messages: \(error.localizedDescription)")
                    return
                }

                self.messages = snapshot?.documents.compactMap { document in
                    try? document.data(as: Message.self)
                } ?? []
            }
    }

    func sendMessage(text: String, senderNickname: String) {
        let message = Message(text: text, senderNickname: senderNickname, timestamp: Date())
        do {
            _ = try db.document(myEmail).collection("MyChatRoom").document(otherNickname).collection("messages").addDocument(from: message)
            _ = try db.document(otherEmail).collection("MyChatRoom").document(myNickname).collection("messages").addDocument(from: message)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
}
