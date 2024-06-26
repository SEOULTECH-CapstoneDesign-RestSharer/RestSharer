//
//  UserListView.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.
//

import SwiftUI

struct UserListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var searchStore: SearchStore
    @EnvironmentObject var followStore: FollowStore
    
    @Binding var searchTerm: String
    
    @State private var trimmedSearchTerm: String = ""
    @State private var inSearchMode = false
    @State private var isSearchTextEmpty: Bool = true
    
    var body: some View {
        ScrollView {
            LazyVStack {
                SearchBarView(searchTerm: $searchTerm, inSearchMode: $inSearchMode)
                    .padding(.bottom, 12)
                searchResultView
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
    
    var searchResultView: some View {
        ScrollView {
            if searchStore.searchUserResults.isEmpty {
                Text("검색 결과가 없습니다.")
                    .foregroundColor(.gray)
                    .padding(.top)
            } else {
                ForEach(searchStore.searchUserResults, id: \.self) { user in
                    NavigationLink {
                        LazyView(OtherProfileView(user: user))
                    } label: {
                        SearchUserCellView(user: user)
                            .padding(.leading)
                    }
                }
            }
        }
    }
    
    //상단 백버튼 - 로고 뷰
    var btnBack : some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .scaledToFit()
                        .font(.pretendardSemiBold16)
                        .foregroundColor(Color.privateColor)
                }
            }.padding(10)
        }
    }
}
