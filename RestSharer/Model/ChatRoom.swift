//
//  ChatRoom.swift
//  Private
//
//  Created by 변상우 on 2023/09/21.
//

import Foundation

import FirebaseFirestore

struct ChatRoom: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
}

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let text: String
    let senderNickname: String
    let timestamp: Date
}
