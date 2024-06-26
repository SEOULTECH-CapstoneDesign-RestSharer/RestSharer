//
//  SearchBarView.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.
//

import SwiftUI

struct SearchBarView: View {
    @EnvironmentObject var searchStore: SearchStore
    @Binding var searchTerm: String
    @Binding var inSearchMode: Bool
    @State private var contiuneOnboarding = false
    
    var body: some View {
        VStack {
            HStack {
                SearchBarTextField(text: $searchTerm, isEditing: $inSearchMode, placeholder: "사용자 닉네임 검색")
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onSubmit {
                        contiuneOnboarding = true
                        Task {
                            await searchStore.searchUser(searchTerm: searchTerm)
                            searchStore.addRecentSearch(searchTerm)
                        }
                    }
                    .navigationDestination(isPresented: $contiuneOnboarding) {
                        UserListView(searchTerm: $searchTerm)
                    }
                }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}
