//
//  SettingView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI
import FirebaseAuth

struct SettingView: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var feedStore: FeedStore
    
    @State private var logoutAlert = false
    @State private var deleteAuth = false
    
    @State private var showPrivacyPolicySheet = false
    @State private var showServicePolicySheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section (content: {
                    HStack {
                        VStack {
                            Text("v1.0.0")
                                .font(.pretendardRegular16)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Text("최신 버전입니다.")
                            .font(.pretendardRegular12)
                            .foregroundColor(.primary)
                    }
                    
                }, header: {
                    Text("현재버전")
                        .font(.pretendardRegular12)
                        .foregroundColor(.primary)
                })
                
                Section (content: {
                    Button{
                        print("서비스 이용약관")
                        showServicePolicySheet.toggle()
                    } label: {
                        HStack {
                            Text("서비스 이용약관")
                                .font(.pretendardRegular16)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button{
                        print("개인정보 처리방침")
                        showPrivacyPolicySheet.toggle()
                    } label: {
                        HStack {
                            Text("개인정보 처리방침")
                                .font(.pretendardRegular16)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.primary)
                }, header: {
                    Text("계정관리")
                        .font(.pretendardRegular12)
                })
                
                Section (content: {
                    Button{
                        print("로그아웃")
                        logoutAlert = true
                    } label: {
                        HStack {
                            Text("로그아웃")
                                .font(.pretendardRegular16)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.primary)
                    .alert(isPresented: $logoutAlert) {
                        Alert(
                            title: Text("로그아웃")
                                .font(.pretendardRegular16)
                                .foregroundColor(.primary),
                            message: Text("로그아웃하시겠습니까?")
                                .font(.pretendardRegular12)
                                .foregroundColor(.primary),
                            primaryButton:.destructive(Text("로그아웃")
                                .font(.pretendardRegular12)
                                .foregroundColor(.primary), action: {
                                    Task {
                                        do {
                                            try Auth.auth().signOut()
                                            authStore.signOut()
                                            authStore.currentUser = nil
                                        }
                                    }
                                }),
                            secondaryButton: .cancel(Text("취소")
                                .font(.pretendardRegular12)
                                .foregroundColor(.primary))
                        )
                    }
                    
                    Button{
                        deleteAuth = true
                    } label: {
                        HStack {
                            Text("회원탈퇴")
                                .font(.pretendardRegular16)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $deleteAuth) {
                        Alert(
                            title: Text("회원탈퇴"),
                            message: Text("회원탈퇴 하시겠습니까?"),
                            primaryButton:.destructive(Text("회원탈퇴"), action: {
                                feedStore.deleteFeed (writerNickname: userStore.user.nickname)
                                userStore.deleteUser(userEmail: userStore.user.email)
                                authStore.deleteAuth()
                                
                                authStore.currentUser = nil
                                
//                                Task {
//                                    do {
//                                        try Auth.auth().signOut()
//                                        authStore.signOut()
//                                        authStore.currentUser = nil
//                                    }
//                                }
                            }),
                            secondaryButton: .cancel(Text("취소"))
                        )
                    }
                    
                }, header: {
                    Text("계정관리")
                        .font(.pretendardRegular12)
                })
                // 웹사이트를 시트 형식으로 열기
                .sheet(isPresented: $showPrivacyPolicySheet) {
                    if let url = URL(string: "https://fluorescent-potassium-a57.notion.site/RestSharer-1339e588c65d809e8f9aecbd7a3c0877?pvs=4") {
                        WebView(url: url)
                    } else {
                        Text("유효하지 않은 URL입니다.")
                    }
                }
                
                // 웹사이트를 시트 형식으로 열기
                .sheet(isPresented: $showServicePolicySheet) {
                    if let url = URL(string: "https://fluorescent-potassium-a57.notion.site/RestSharer-1379e588c65d80a08ba0cc8cf29bfd54?pvs=4") {
                        WebView(url: url)
                    } else {
                        Text("유효하지 않은 URL입니다.")
                    }
                }
            }
            .navigationTitle("설정").font(.pretendardRegular16).foregroundColor(.primary)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .backButtonArrow()
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
