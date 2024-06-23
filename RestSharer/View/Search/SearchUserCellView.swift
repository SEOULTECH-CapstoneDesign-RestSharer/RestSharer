//
//  SearchUserCellView.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.
//

import SwiftUI
import Kingfisher

struct SearchUserCellView: View {
    @EnvironmentObject private var followStore: FollowStore
    
    let user: User
    
    var body: some View {
        HStack {
            ZStack {
                if user.profileImageURL.isEmpty {
                    Circle()
                        .frame(width: .screenWidth*0.15)
                    KFImage(URL(string: "https://www.personality-insights.com/wp-content/uploads/2017/12/default-profile-pic-e1513291410505.jpg"))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: .screenWidth*0.15, height: .screenWidth*0.15)
                        .background(.black)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                } else {
                    KFImage(URL(string: user.profileImageURL))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: .screenWidth*0.15, height: .screenWidth*0.15)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            }
            .padding(.leading ,3)
            
            VStack(alignment: .leading) {
                Text(user.nickname)
                    .font(.pretendardBold18)
                    .foregroundColor(.chatTextColor)
                
                Text(user.name)
                    .font(.pretendardRegular14)
                    .foregroundColor(.chatTextColor)
            }
            Spacer() // // HStack 내의 가장 위에 쓰면 모든 요소가 오른쪽 정렬
        }
    }
}
