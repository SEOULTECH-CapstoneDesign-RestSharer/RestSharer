//
//  MainTabView.swift
//  RestSharer
//
//  Created by 강민수 on 5/10/24.
//

import SwiftUI

struct MainTabView: View {
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color.tabColor)
    }
    
    @EnvironmentObject var userStore: UserStore
//    @EnvironmentObject var shopStore: ShopStore
//    @EnvironmentObject var reservationStore: ReservationStore
  
//    @StateObject private var feedStore: FeedStore = FeedStore()
//    @StateObject private var searchStore: SearchStore = SearchStore()
     
    @State var selection: Int = 1
    @State private var rootSection1: Bool = false
    @State private var rootSection2: Bool = false
    @State private var rootSection3: Bool = false
    @State private var rootSection4: Bool = false
    @State private var rootSection5: Bool = false
    
    var selectionBinding: Binding<Int> { Binding (
        get: {
            self.selection
        },
        set: {
            if $0 == self.selection && rootSection1 {
                rootSection1 = false
            }
            if $0 == self.selection && rootSection2 {
                rootSection2 = false
            }
            if $0 == self.selection && rootSection3 {
                rootSection3 = false
            }
            if $0 == self.selection && rootSection4 {
                rootSection4 = false
            }
            if $0 == self.selection && rootSection4 {
                rootSection5 = false
            }
            self.selection = $0
        }
    )}
    
    var nicknameIsEmpty: Bool {
        print("닉네임: \(userStore.user.nickname)")
        return userStore.user.nickname.isEmpty
    }
    
    
    var body: some View {
//        if nicknameIsEmpty {
//            SignUpView()      //일단 SignUp 만들기 전이니까 주석처리 해둠 - 민수
//        } else {
            NavigationView {        //NavigationStack가 IOS 16이상이라는 오류가 생겨서 NavigationView로 일시 수정함 -> 후에 논의
                TabView(selection: selectionBinding) {
                    MainHomeView(root: $rootSection1, selection: $selection).tabItem {
                        Image(systemName: "house.fill")
                    }.tag(1)
//                    SearchView(root: $rootSection2, selection: $selection).tabItem {
//                        Image(systemName: "magnifyingglass")
//                    }.tag(2)
//                    PostView(root: $rootSection3, selection: $selection).tabItem {
//                        Image(systemName: "plus")
//                    }.tag(3)
//                    ShopDetailView(root: $rootSection4, selection: $selection).tabItem {
//                        Image(systemName: "calendar.badge.clock")
//                    }.tag(4)
//                    MyPageView(root: $rootSection5, selection: $selection).tabItem {
//                        Image(systemName: "person.fill")
//                    }.tag(5)      //메인 페이지 제외 만들기 전이므로 주석처리 - 민수
                }
            }
//        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
