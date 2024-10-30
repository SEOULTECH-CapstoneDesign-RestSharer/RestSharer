//
//  SearchPageView.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.
//

import SwiftUI

struct SearchPageView: View {
    @EnvironmentObject var searchStore: SearchStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    Text("최근 검색어")
                        .font(.pretendardMedium24)
                        .padding()
                    
                    Spacer()
                }
                    if !searchStore.recentSearchResult.isEmpty {
                        let array = Array(searchStore.recentSearchResult.prefix(5))
                        ForEach(array, id: \.self) { resultText in
                            RecentSearchRowView(resultText: resultText)
                        }
                } else {
                    Text("검색 기록이 없습니다")
                        .font(.pretendardRegular16)
                        .foregroundColor(.secondary)
                }
                Spacer().padding(.bottom, 10)
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Text("찾은 사용자")
                        .font(.pretendardMedium24)
                        .padding()
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    if !searchStore.searchUserLists.isEmpty {
                        let array = Array(searchStore.searchUserLists.prefix(4))
                        ForEach(array, id: \.self) { user in
                            RecentUserRowView(user: user)
                        }
                    } else {
                        Text("검색 기록이 없습니다")
                            .font(.pretendardRegular16)
                            .foregroundColor(.gray)
                    }
                    Spacer().padding(.bottom, 10)
                }
            }
            Spacer()
        }
    }
    
    struct RecentSearchRowView: View {
        @EnvironmentObject var searchStore: SearchStore
        let resultText: String
        
        var body: some View {
            VStack {
                HStack {
                    Text(resultText)
                        .font(.pretendardRegular16)
                        .foregroundColor(.primary)
                    Spacer()
                    Button {
                        searchStore.removeRecentSearchResult(resultText)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 4)
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 8)
            }
            
        }
    }
    
    struct RecentUserRowView: View {
        @EnvironmentObject var searchStore: SearchStore
        @EnvironmentObject var followStore: FollowStore
        let user: User

        var body: some View {
            HStack {
                NavigationLink {
                    LazyView(OtherProfileView(user: user))
                } label: {
                    SearchUserCellView(user: user)
                }
                Spacer()
                Button {
                    searchStore.removeUserList(user)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .padding(.trailing, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

}
