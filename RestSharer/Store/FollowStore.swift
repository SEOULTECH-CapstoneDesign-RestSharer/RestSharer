//
//  FollowStore.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.
//

import Foundation
import Firebase

final class FollowStore: ObservableObject {
    @Published var followerList: [String] = [] // User가 아닌 닉네임을 저장
    @Published var followingList: [String] = [] // ""
    
    @Published var followers = 0
    @Published var following = 0
    @Published var followCheck = false
    
    
    static let currentUserRef = userCollection.document("currentUserID")
    
    
    static func followingCollection(userid: String) ->  CollectionReference{
        
        return userCollection.document(userid).collection("following")
    }
    
    static func followersCollection(userid: String) ->  CollectionReference{
        
        return userCollection.document(userid).collection("follower")
    }
    
    static func followingID(nickname: String) -> DocumentReference {
        
        return userCollection.document((Auth.auth().currentUser?.email)!).collection("following").document(nickname)
    }
    
    static func followersID(email: String, nickname: String) -> DocumentReference {
        
        return userCollection.document(email).collection("follower").document(nickname)
    }
    
    func followState(userid: String) {
        FollowStore.followingID(nickname: userid).getDocument {
            (document, error) in
            
            if let doc = document, doc.exists {
                self.followCheck = true
            } else {
                self.followCheck = false
            }
        }
    }
    
    
    func updateFollowCount(userId: String) {
        
        FollowStore.followingCollection(userid: userId).getDocuments { (snap, error) in
            
            if let doc = snap?.documents {
                self.following = doc.count
            }
        }
        
        FollowStore.followersCollection(userid: userId).getDocuments { (snap, error) in
            
            if let doc = snap?.documents {
                self.followers = doc.count
            }
        }
    }
    
    //팔로우 상태를 체크후 팔로우 언팔로우 하는 함수
    func manageFollow(userId: String, myNickName: String, userEmail: String) {
        
        if !followCheck {
            follow(userId: userId, myNickName: myNickName, OtherEmail: userEmail)
            updateFollowCount(userId: userId)
        } else {
            unfollow(userId: userId, myNickName: myNickName, userEmail: userEmail)
            updateFollowCount(userId: userId)
        }
    }
    
    //팔로우
    func follow(userId: String, myNickName: String, OtherEmail: String) {
        
        FollowStore.followingID(nickname: userId).setData(["following": FieldValue.arrayUnion([userId])]) { (err) in
            if err == nil {
                self.followingList.append(userId)
            }
        }
        
        FollowStore.followersID(email: OtherEmail, nickname: myNickName).setData(["follower": FieldValue.arrayUnion([myNickName])]) { (err) in
            if err == nil {
                self.followerList.append(myNickName)
            }
        }
    }
    
    //언팔로우
    func unfollow(userId: String, myNickName: String, userEmail: String) {
        
        FollowStore.followingID(nickname: userId).getDocument { (document, err) in
            if let doc = document, doc.exists {
                doc.reference.delete()
                if let index = self.followingList.firstIndex(of: userId) {
                    self.followingList.remove(at: index)
                }
            }
        }
        
        FollowStore.followersID(email: userEmail, nickname: myNickName).getDocument { (document, err) in
            if let doc = document, doc.exists {
                doc.reference.delete()
                if let index = self.followerList.firstIndex(of: myNickName) {
                    self.followerList.remove(at: index)
                }
            }
        }
    }
    
    func fetchFollowerFollowingList (_ useremail: String) {
        userCollection.document(useremail)
            .collection("follower")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                } else {
                    if let documents = querySnapshot?.documents {
                        self.followerList = documents.compactMap { $0.documentID } // documentID를 사용하여 배열 생성
                    }
                }
            }
        userCollection.document(useremail)
            .collection("following")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                } else {
                    if let documents = querySnapshot?.documents {
                        self.followingList = documents.compactMap { $0.documentID } // documentID를 사용하여 배열 생성
                    }
                }
            }
    }
}
