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
    
    static func followersID(userEmail: String, myNickname: String) -> DocumentReference {
        return userCollection.document(userEmail).collection("follower").document(myNickname)
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
            follow(userNickname: userNickname, myNickname: myNickname, userEmail: userEmail, myEmail: myEmail) {
                DispatchQueue.main.async{
                    self.followCheck = true
                    self.updateFollowCount(userEmail: userEmail) // 팔로우 후 업데이트
                }
            }
        } else {
            unfollow(userNickname: userNickname, myNickname: myNickname, userEmail: myEmail, myEmail: userEmail) {
                DispatchQueue.main.async{
                    print("\(myNickname) successfully unfollowed \(userNickname)")
                    self.followCheck = false
                    self.updateFollowCount(userEmail: myEmail) // 언팔로우 후 업데이트
                }
            }
        }
    }


    
    // 팔로우
    func follow(userNickname: String, myNickname: String, userEmail: String, myEmail: String, completion: @escaping () -> Void) {
        FollowStore.followingID(userNickname: userNickname).setData(["following": FieldValue.arrayUnion([userNickname])]) { (err) in
            if err == nil {
                self.followingList.append(userNickname)
                print("Following list after follow: \(self.followingList)") // 팔로우 후 followingList 출력
                completion()
            }
        }
        
        FollowStore.followersID(userEmail: userEmail, myNickname: myNickname).setData(["follower": FieldValue.arrayUnion([myNickname])]) { (err) in
            if err == nil {
                self.followerList.append(myNickname)
                print("\(self.followerList)")
            }
        }
    }
    
    // 언팔로우
    func unfollow(userNickname: String, myNickname: String, userEmail: String, myEmail: String, completion: @escaping () -> Void) {
        print("Attempting to unfollow \(userNickname) from \(myNickname)'s perspective.")
        print("userEmail: \(userEmail), myEmail: \(myEmail)")
        print("userNickname: \(userNickname), myNickname: \(myNickname)")
        
        FollowStore.followingID(userNickname: userNickname).getDocument { (document, err) in
            if let error = err {
                print("Error getting following document: \(error.localizedDescription)")
                completion() // 에러 발생 시에도 클로저 호출
                return
            }
            
            if let doc = document, doc.exists {
                print("Following document exists for \(userNickname). Proceeding to delete.")
                doc.reference.delete { error in
                    if let error = error {
                        print("Error deleting following: \(error.localizedDescription)")
                        return
                    }
                    print("\(userNickname) successfully removed from \(myNickname)'s following list.")
                    
                    if let index = self.followingList.firstIndex(of: userNickname) {
                        self.followingList.remove(at: index)
                        print("\(userNickname) removed from local following list.")
                    }
                }
            } else {
                print("Following document does not exist for \(userNickname).")
            }
        }
        
        FollowStore.followersID(userEmail: userEmail, myNickname: myNickname).getDocument { (document, err) in
                if let error = err {
                    print("Error getting follower document: \(error.localizedDescription)")
                    completion() // 에러 발생 시에도 클로저 호출
                    return
                }

                if let doc = document, doc.exists {
                    print("Follower document exists for \(userEmail). Proceeding to delete.")
                    doc.reference.delete { error in
                        if let error = error {
                            print("Error deleting follower: \(error.localizedDescription)")
                            return
                        }
                        print("\(myNickname) successfully removed from \(userEmail)'s followers list.")
                        
                        if let index = self.followerList.firstIndex(of: myNickname) {
                            self.followerList.remove(at: index)
                            print("\(myNickname) removed from local follower list.")
                        }
                        print("\(self.followerList)")
                        completion() // 여기서 completion 호출
                    }
                } else {
                    print("Follower document does not exist for \(userEmail).")
                    completion() // 문서가 없을 경우에도 completion 호출
                }
            }
        }
    
    func fetchFollowerFollowingList(_ myEmail: String) {
        userCollection.document(myEmail).collection("following")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching following list: \(error.localizedDescription)")
                } else {
                    if let documents = querySnapshot?.documents {
                        // 문서 ID를 사용하여 팔로잉 리스트를 생성
                        self.followingList = documents.map { $0.documentID }
                    }
                }
            }

        userCollection.document(myEmail)
            .collection("follower")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                } else {
                    if let documents = querySnapshot?.documents {
                        self.followerList = documents.map { $0.documentID } // documentID를 사용하여 배열 생성
                    }
                }
            }
    }

}
