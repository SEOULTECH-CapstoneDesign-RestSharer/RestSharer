//
//  MyFollowingView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Kingfisher

struct MyFollowingView: View {
    @EnvironmentObject var followStore: FollowStore
    @State private var followingUserList: [User] = []
    
    let user: User
    var followingList: [String]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(followingUserList, id: \.self) { following in
                HStack {
                    NavigationLink(destination: OtherProfileView(user: following)) {
                        if following.profileImageURL.isEmpty {
                            ZStack {
                                Circle()
                                    .frame(width: .screenWidth * 0.13)
                                    .foregroundColor(.primary)
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: .screenWidth * 0.115, height: .screenWidth * 0.115)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                            }
                        } else {
                            KFImage(URL(string: following.profileImageURL))
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: .screenWidth * 0.13, height: .screenWidth * 0.13)
                        }
                        Text("\(following.nickname)")
                            .font(.pretendardMedium18)
                            .foregroundColor(.primary)
                            .padding(.leading, 15)
                    }
                    Spacer()
                    
                    // 언팔로우 버튼
                    Button {
                        followStore.unfollow(userNickname: following.nickname, myNickname: user.nickname, userEmail: user.email) {
                            if followStore.followingList.contains(following.nickname) {
                                print("\(following.nickname) 언팔로우 실패")
                            } else {
                                followingUserList.removeAll { $0 == following }
                                print("\(following.nickname) 언팔로우 성공")
                            }
                        }
                    } label: {
                        Text("언팔로우")
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
                    .frame(width: .screenWidth * 0.9)
            }
        }
        .onAppear {
            if followingUserList.count != followingList.count {
                searchFollowingUser(searchName: followingList)
            }
        }
        .refreshable {
            followStore.fetchFollowerFollowingList(user.email)
        }
    }

    func searchFollowingUser(searchName: [String]) {
        for index in searchName {
            let query = userCollection
                .whereField("nickname", isEqualTo: index)
                .limit(to: 10)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("데이터 가져오기 실패: \(error.localizedDescription)")
                    return
                }
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let user = User(document: data) { // user가 nil이 아닐 때만 추가
                        followingUserList.append(user)
                    } else {
                        print("User 데이터를 생성하지 못했습니다.")
                    }
                }
            }
        }
    }
}

struct MyFollowingView_Previews: PreviewProvider {
    static var previews: some View {
        MyFollowingView(user: User(), followingList: [""]).environmentObject(UserStore())
    }
}
