//
//  OtherSavedPlaceView.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.
//

import SwiftUI

struct OtherSavedPlaceView: View {
    @EnvironmentObject private var userStore: UserStore
    
    @State private var isShowingLocation: Bool = false
    @State private var searchResult: SearchResult = SearchResult(title: "", category: "", address: "", roadAddress: "", mapx: "", mapy: "")
    
    let user:User
    
    var body: some View {
        ScrollView {
            if userStore.otherSavedPlaceList.isEmpty {
                Text("저장한 장소가 없습니다.")
                    .font(.pretendardBold24)
                    .foregroundColor(.primary)
                    .padding(.top, .screenHeight * 0.2 + 37.2)
            } else {
                ShopInfoCardView(isShowingLocation: $isShowingLocation, searchResult: $searchResult, mySavedPlaceList: userStore.otherSavedPlaceList, isOtherUser: true)
            }
        }
        .sheet(isPresented: $isShowingLocation) {
            LocationDetailView(searchResult: $searchResult)
                .presentationDetents([.height(.screenHeight * 0.6), .large])
        }
    }
}
