//
//  ContentView.swift
//  RestSharer
//
//  Created by 변상우 on 4/29/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var authStore: AuthStore
    
    @State private var logoutAlert = false
    
    var body: some View {
        VStack {
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
                        .foregroundColor(.primary), action: { platformLogout() }),
                    secondaryButton: .cancel(Text("취소")
                        .font(.pretendardRegular12)
                        .foregroundColor(.primary))
                )
            }
        }
        .padding()
    }
    
    func platformLogout() {
        switch authStore.loginPlatform {
        case .google:
            authStore.signOutGoogle()
//        case .kakao:
//            authStore.handleKakaoLogout()
        case .email, .none:
            print(#function)
//        default:
//            print(#function)
        }
    }
}

#Preview {
    ContentView()
}
