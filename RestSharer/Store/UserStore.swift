//
//  UserStore.swift
//  RestSharer
//
//  Created by 변상우 on 5/10/24.
//

import SwiftUI
import NMapsMap
import Firebase
import FirebaseAuth
import FirebaseFirestore

final class UserStore: ObservableObject {
    @Published var user: User = User()
    @Published var follower: [User] = []
    @Published var following: [User] = []
    @Published var myFeedList: [MyFeed] = []
    @Published var myFeedAndSavedList: [MyFeed] = []
    @Published var mySavedFeedList: [MyFeed] = []
    @Published var mySavedPlace: [MyFeed] = []
    
    @Published var mySavedPlaceList: [MyFeed] = []
    @Published var otherFeedList: [MyFeed] = []
    @Published var otherSavedFeedList: [MyFeed] = []
    @Published var otherSavedPlaceList: [MyFeed] = []
    @Published var blockedUsers: [String] = []
    
    @Published var clickSavedFeedToast: Bool = false
    @Published var clickSavedPlaceToast: Bool = false
    @Published var clickSavedCancelFeedToast: Bool = false
    @Published var clickSavedCancelPlaceToast: Bool = false
    @Published var clickIsSavedNickName: Bool = false
    
    func fetchMyInfo(userEmail: String, completion: @escaping (Bool) -> Void) {
        print("Fetching info for userEmail: \(userEmail)")
        userCollection.document(userEmail).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            } else if let userData = snapshot?.data(), let user = User(document: userData) {
                print("User data fetched successfully: \(user.email)")
                self.user = user
                completion(true)
            } else{
                print("No user data found for \(userEmail)")
            }
        }
    }
    
    func createUser(user: User) {
        userCollection
            .document(user.email)
        //            .setData(user.toDictionary())
            .setData(["email" : user.email,
                      "name" : user.name,
                      "nickname" : user.nickname,
                      "phoneNumber" : user.phoneNumber,
                      "profileImageURL" : user.profileImageURL,
                      "follower" : user.follower,
                      "following" : user.following,
                      "myFeed" : user.myFeed,
                      "savedFeed" : user.savedFeed,
                      "bookmark" : user.bookmark,
                      "chattingRoom" : user.chattingRoom,
                      "myReservation" : user.myReservation
                     ]
            )
        
        fetchCurrentUser(userEmail: user.email)
    }
    
    
    func updateUser(user: User) {
        userCollection
            .document(user.email)
            .updateData(["email" : user.email,
                         "name" : user.name,
                         "nickname" : user.nickname,
                         "phoneNumber" : user.phoneNumber,
                         "profileImageURL" : user.profileImageURL,
                         "follower" : user.follower,
                         "following" : user.following,
                         "myFeed" : user.myFeed,
                         "savedFeed" : user.savedFeed,
                         "bookmark" : user.bookmark,
                         "chattingRoom" : user.chattingRoom,
                         "myReservation" : user.myReservation
                        ]
            )
        fetchCurrentUser(userEmail: user.email)
    }
    
    func fetchCurrentUser(userEmail: String) {
        print("fetchCurrentUser")
        userCollection.document(userEmail).getDocument { snapshot, error in
            print(snapshot?.data())
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            } else if let userData = snapshot?.data(), let user = User(document: userData) {
                self.user = user
                print("user: \(user)")
            }
        }
        
        //----
        userCollection.document(userEmail).collection("MyFeed").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            }
            self.myFeedList = querySnapshot?.documents.compactMap { (queryDocumentSnapshot) -> MyFeed? in
                let documetID = queryDocumentSnapshot.documentID
                let data = queryDocumentSnapshot.data()
                var feed = MyFeed(documentData: data)
                feed?.createdAt = data["createdAt"] as? Double ?? 0.0
                feed?.id = documetID
                return feed
            } .sorted(by: { Date(timeIntervalSince1970: $0.createdAt) > Date(timeIntervalSince1970: $1.createdAt) }) ?? []
        }
        
        // Fetch myFeedAndSavedList
        userCollection.document(userEmail).collection("MyFeed").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            }
            var myFeedList = querySnapshot?.documents.compactMap { (queryDocumentSnapshot) -> MyFeed? in
                let documetID = queryDocumentSnapshot.documentID
                let data = queryDocumentSnapshot.data()
                var feed = MyFeed(documentData: data)
                feed?.createdAt = data["createdAt"] as? Double ?? 0.0
                feed?.id = documetID
                return feed
            } ?? []

            // Fetch mySavedPlaceList and add to myFeedList
            userCollection.document(userEmail).collection("SavedPlace").addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                }
                let savedPlaceList = querySnapshot?.documents.compactMap { (queryDocumentSnapshot) -> MyFeed? in
                    let documetID = queryDocumentSnapshot.documentID
                    let data = queryDocumentSnapshot.data()
                    var feed = MyFeed(documentData: data)
                    feed?.id = documetID
                    feed?.createdAt = data["createdAt"] as? Double ?? 0.0
                    return feed
                } ?? []

                // Combine myFeedList and mySavedPlaceList, removing duplicates based on feed.id
                var combinedList = myFeedList + savedPlaceList
                var uniqueFeeds: [String: MyFeed] = [:]
                for feed in combinedList {
                    uniqueFeeds[feed.id] = feed
                }
                
                // Sort the combined list by createdAt
                self.myFeedAndSavedList = Array(uniqueFeeds.values).sorted {
                    Date(timeIntervalSince1970: $0.createdAt) > Date(timeIntervalSince1970: $1.createdAt)
                }
            }
        }
        
        userCollection.document(userEmail).collection("SavedPlace").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            }
            self.mySavedPlaceList = querySnapshot?.documents.compactMap { (queryDocumentSnapshot) -> MyFeed? in
                let documetID = queryDocumentSnapshot.documentID
                let data = queryDocumentSnapshot.data()
                var feed = MyFeed(documentData: data)
                feed?.id = documetID
                feed?.createdAt = data["createdAt"] as? Double ?? 0.0
                return feed
            } .sorted(by: { Date(timeIntervalSince1970: $0.createdAt) > Date(timeIntervalSince1970: $1.createdAt) }) ?? []
        }
    }
    
    func fetchotherUser(userEmail:String, completion: @escaping (Bool) -> Void) {
        userCollection.document(userEmail).collection("MyFeed").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            }
            self.otherFeedList = querySnapshot?.documents.compactMap { (queryDocumentSnapshot) -> MyFeed? in
                let data = queryDocumentSnapshot.data()
                var feed = MyFeed(documentData: data)
                feed?.createdAt = data["createdAt"] as? Double ?? 0.0
                return feed
            }.sorted(by: { Date(timeIntervalSince1970: $0.createdAt) > Date(timeIntervalSince1970: $1.createdAt) }) ?? []
        }
        userCollection.document(userEmail).collection("SavedFeed").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            }
            self.otherSavedFeedList = querySnapshot?.documents.compactMap { (queryDocumentSnapshot) -> MyFeed? in
                let data = queryDocumentSnapshot.data()
                var feed = MyFeed(documentData: data)
                feed?.createdAt = data["createdAt"] as? Double ?? 0.0
                return feed
            } .sorted(by: { Date(timeIntervalSince1970: $0.createdAt) > Date(timeIntervalSince1970: $1.createdAt) }) ?? []
        }
        userCollection.document(userEmail).collection("SavedPlace").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
            }
            self.otherSavedPlaceList = querySnapshot?.documents.compactMap { (queryDocumentSnapshot) -> MyFeed? in
                let documetID = queryDocumentSnapshot.documentID
                let data = queryDocumentSnapshot.data()
                var feed = MyFeed(documentData: data)
                feed?.id = documetID
                feed?.createdAt = data["createdAt"] as? Double ?? 0.0
                return feed
            }
            .sorted(by: { Date(timeIntervalSince1970: $0.createdAt) > Date(timeIntervalSince1970: $1.createdAt) }) ?? []
        }
        completion(true)
    }
    
    func deleteUser(userEmail: String) {
        deleteCollection("MyFeed")
        deleteCollection("MyReservation")
        deleteCollection("SavedFeed")
        deleteCollection("SavedPlace")
        deleteCollection("follower")
        deleteCollection("following")
        
        userCollection
            .document(user.email).delete()
        
        user = User()
    }
    
    func saveFeed(_ feed: MyFeed) {
        do {
            try
            userCollection.document(user.email).collection("SavedFeed")
                .document("\(feed.id)")
                .setData(from:feed)
            
        } catch {
            print("Error bookMark Feed: \(error)")
        }
    }
    
    //MARK: 현재 유저의 닉네임을 불러오는 함수
    func getCurrentUserNickname(completion: @escaping (String?) -> Void) {
        let userRef = userCollection.document(user.email)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let nickname = data?["nickname"] as? String
                completion(nickname)
            } else {
                completion(nil)
            }
        }
    }
    
    func createMarker() {
        
    }
    //    func createUser(user: User) {
    //        userCollection
    //            .document(user.email)
    ////            .setData(user.toDictionary())
    //            .setData(["email" : user.email,
    //                      "name" : user.name,
    //                      "nickname" : user.nickname,
    //                      "phoneNumber" : user.phoneNumber,
    //                      "profileImageURL" : user.profileImageURL,
    //                      "follower" : user.follower,
    //                      "following" : user.following,
    //                      "myFeed" : user.myFeed,
    //                      "savedFeed" : user.savedFeed,
    //                      "bookmark" : user.bookmark,
    //                      "chattingRoom" : user.chattingRoom,
    //                      "myReservation" : user.myReservation
    //                     ]
    //            )
    //
    //        fetchCurrentUser(userEmail: user.email)
    //    }
    
    func deleteSavedFeed(_ feed: MyFeed) {
        userCollection.document(user.email)
            .collection("SavedFeed")
            .document("\(feed.id)")
            .delete()
    }
    
    func deleteMyFeed(_ feed: MyFeed) {
        userCollection.document(user.email)
            .collection("MyFeed")
            .document("\(feed.id)")
            .delete()
    }
    
    func savePlace(_ feed: MyFeed) {
        userCollection.document(user.email)
            .collection("SavedPlace")
            .document("\(feed.id)")
            .setData(["writerNickname": "",
                      "writerEmail": "",
                      "writerName": "",
                      "writerProfileImage": "",
                      "images": feed.images,
                      "contents": "",
                      "createdAt": feed.createdAt,
                      "title": feed.title,
                      "category": feed.category,
                      "address": feed.address,
                      "roadAddress": feed.roadAddress,
                      "mapx": feed.mapx,
                      "mapy": feed.mapy
                     ])
    }
    
    func deletePlace(_ feed: MyFeed) {
        userCollection.document(user.email)
            .collection("SavedPlace")
            .document("\(feed.id)")
            .delete()
    }
    
    func checkNickName(_ userNickName: String, completion: @escaping (Bool) -> Void) {
        let query = userCollection.whereField("nickname",isEqualTo: userNickName)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error searching documents: \(error)")
                completion(false)
            } else {
                if let documentCount = querySnapshot?.documents.count, documentCount > 0 {
                    // 닉네임이 존재하는 경우
                    completion(true)
                } else {
                    // 닉네임이 존재하지 않는 경우
                    completion(false)
                }
            }
        }
    }
    
    private func makeFeedData(from feed: MyFeed) -> [String: Any] {
        return [
            "writerNickname": feed.writerNickname,
            "writerEmail": feed.writerEmail,
            "writerName": feed.writerName,
            "writerProfileImage": feed.writerProfileImage,
            "images": feed.images,
            "contents": feed.contents,
            "createdAt": Timestamp(date: Date(timeIntervalSince1970: feed.createdAt)),
            "title": feed.title,
            "category": feed.category,
            "address": feed.address,
            "roadAddress": feed.roadAddress,
            "mapx": feed.mapx,
            "mapy": feed.mapy,
        ]
    }
    
    func deleteCollection (_ collectionName: String) {
        userCollection.document(user.email)
            .collection(collectionName)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let documentReference = document.reference
                        documentReference.delete { error in
                            if let error = error {
                                print("Error deleting document: \(error)")
                            } else {
                                print("Document deleted successfully")
                            }
                        }
                    }
                }
            }
    }
    
    func blockUser(nickname: String) async {
        do {
            let userDocRef = userCollection.document(user.email)
            let blockedUsersCollectionRef = userDocRef.collection("BlockedUsers")
            
            // 차단된 사용자의 닉네임을 blockedUsers 컬렉션에 추가
            try await blockedUsersCollectionRef.document(nickname).setData([
                "nickname": nickname,
                "timestamp": FieldValue.serverTimestamp() // 타임스탬프를 추가할 수 있음
            ])
            
            blockedUsers.append(nickname) // 로컬 데이터 업데이트
            print("\(nickname)을 차단 목록에 추가했습니다.")
        } catch {
            print("Error blocking user: \(error.localizedDescription)")
        }
    }
    
    // 차단된 사용자 목록 가져오기
    func fetchBlockedUsers() async {
        let blockedUsersRef = userCollection.document(user.email).collection("BlockedUsers")
        
        do {
            let snapshot = try await blockedUsersRef.getDocuments()
            blockedUsers = snapshot.documents.compactMap { $0.documentID }
            print("차단된 사용자 목록: \(blockedUsers)")
        } catch {
            print("Error fetching blocked users: \(error.localizedDescription)")
        }
    }
}



