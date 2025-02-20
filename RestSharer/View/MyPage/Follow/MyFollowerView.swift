//
//  MyFollowerView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Kingfisher

struct MyFollowerView: View {
    @EnvironmentObject var followStore: FollowStore
    @State private var followerUserList: [User] = []
    
    let user: User
    var followerList: [String]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(followerUserList, id: \.self) { follower in
                HStack {
                    NavigationLink() {
                        OtherProfileView(user:follower)
                    } label: {
                        if follower.profileImageURL.isEmpty {
                            ZStack {
                                Circle()
                                    .frame(width: .screenWidth*0.13)
                                    .foregroundColor(.primary)
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: .screenWidth*0.115,height: .screenWidth*0.115)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                            }
                        } else {
                            KFImage(URL(string: follower.profileImageURL))
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: .screenWidth*0.13, height: .screenWidth*0.13)
                        }
                        Text("\(follower.nickname)")
                            .font(.pretendardMedium18)
                            .foregroundColor(.primary)
                            .padding(.leading, 15)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("팔로잉")
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .font(.pretendardBold14)
                            .foregroundColor(.black)
                            .background(Color.yellow)
                            .cornerRadius(20)
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                Divider()
                    .background(Color.primary)
                    .frame(width: .screenWidth*0.9)
            }
        }
        .onAppear {
            if followerUserList.count != followerList.count {
                searchFollowerUser(searchName: followerList)
            }
        }
        .refreshable {
            Task {
                await followStore.fetchFollowerFollowingList(user.email)
            }
//            followerUserList = []
//            searchFollowerUser(searchName: user.follower)
        }
    }
    
    func searchFollowerUser(searchName: [String]) {
        
        for index in searchName {
            let query = userCollection
                .whereField("nickname",isEqualTo: index)
                .limit(to: 10)
            query.getDocuments { (querySnapshot,error) in
                if let error = error {
                    print("데이터 가져오기 실패: \(error.localizedDescription)")
                    return
                }
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let user = User(document: data)
                    followerUserList.append(user ?? User())
                }
            }
        }
    }
}
struct MyFollowerView_Previews: PreviewProvider {
    static var previews: some View {
        MyFollowerView(user:User(), followerList: ["a"]).environmentObject(UserStore())
    }
}
