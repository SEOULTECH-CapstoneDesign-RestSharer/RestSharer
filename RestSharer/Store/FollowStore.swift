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
    
    static func followingCollection(userEmail: String) -> CollectionReference {
        return userCollection.document(userEmail).collection("following")
    }
    
    static func followersCollection(userEmail: String) -> CollectionReference {
        return userCollection.document(userEmail).collection("follower")
    }
    
    static func followingID(userNickname: String) -> DocumentReference {
        return userCollection.document((Auth.auth().currentUser?.email)!).collection("following").document(userNickname)
    }
    
    static func followersID(myNickname: String) -> DocumentReference {
        return userCollection.document((Auth.auth().currentUser?.email)!).collection("follower").document(myNickname)
    }
    
    func followState(userNickname: String) {
        FollowStore.followingID(userNickname: userNickname).getDocument { (document, error) in
            if let doc = document, doc.exists {
                self.followCheck = true
            } else {
                self.followCheck = false
            }
        }
    }
    
    func updateFollowCount(userEmail: String) {
        FollowStore.followingCollection(userEmail: userEmail).getDocuments { (snap, error) in
            if let doc = snap?.documents {
                self.following = doc.count
            }
        }
        
        FollowStore.followersCollection(userEmail: userEmail).getDocuments { (snap, error) in
            if let doc = snap?.documents {
                self.followers = doc.count
            }
        }
    }
    
    // 팔로우 상태를 체크한 후 팔로우/언팔로우하는 함수
    func manageFollow(userNickname: String, myNickname: String, userEmail: String, myEmail: String) {
        if !followCheck {
            follow(userNickname: userNickname, myNickname: myNickname, userEmail: userEmail, myEmail: myEmail)
            updateFollowCount(userEmail: userEmail)
        } else {
            unfollow(userNickname: userNickname, myNickname: myNickname, userEmail: userEmail) {
                print("\(myNickname) successfully unfollowed \(userNickname)")
            }
            updateFollowCount(userEmail: userEmail)
        }
    }

    
    // 팔로우
    func follow(userNickname: String, myNickname: String, userEmail: String, myEmail: String) {
        FollowStore.followingID(userNickname: userNickname).setData(["following": FieldValue.arrayUnion([userNickname])]) { (err) in
            if err == nil {
                self.followingList.append(userNickname)
            }
        }
        
        FollowStore.followersID(myNickname: myNickname).setData(["follower": FieldValue.arrayUnion([myNickname])]) { (err) in
            if err == nil {
                self.followerList.append(myNickname)
            }
        }
    }
    
    // 언팔로우
    func unfollow(userNickname: String, myNickname: String, userEmail: String, completion: @escaping () -> Void) {
        FollowStore.followingID(userNickname: userNickname).getDocument { (document, err) in
            if let doc = document, doc.exists {
                doc.reference.delete()
                if let index = self.followingList.firstIndex(of: userNickname) {
                    self.followingList.remove(at: index)
                }
            }
            completion() // 언팔로우 처리 후 클로저 실행
        }
        
        FollowStore.followersID(myNickname: myNickname).getDocument { (document, err) in
            if let doc = document, doc.exists {
                // Firestore에서 문서 전체를 삭제하는 대신 특정 필드만 수정해서 제거할 수도 있음
                doc.reference.updateData([
                    "follower": FieldValue.arrayRemove([myNickname])  // 팔로워 목록에서 내 닉네임 삭제
                ]) { error in
                    if let error = error {
                        print("Failed to remove follower from the list: \(error.localizedDescription)")
                        return
                    }
                    // 팔로워 리스트에서 내 닉네임 삭제 후 로컬 리스트에서도 제거
                    if let index = self.followerList.firstIndex(of: myNickname) {
                        self.followerList.remove(at: index)
                    }
                    print("\(myNickname) was successfully removed from \(userEmail)'s followers list.")
                }
            } else {
                print("Document does not exist.")
            }
            completion() // 언팔로우 처리 후 클로저 실행
        }
    }
    
    func fetchFollowerFollowingList(_ myEmail: String) {
        userCollection.document(myEmail)
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
        
        userCollection.document(myEmail)
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
