//
//  LoginView.swift
//  RestSharer
//
//  Created by 변상우 on 4/30/24.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct LoginView: View {
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            
            VStack(alignment: .center, spacing: 10) {
                Text("RestSharer")
                
                HStack {
                    ZStack {
                        Divider()
                            .foregroundStyle(.primary)
                        
                        Text("간편 로그인")
                            .font(.pretendardBold14)
                            .foregroundStyle(.primary)
                            .padding()
                            .background(Color.black)
                    }
                }
                .padding()
                
                Button {
                    authStore.signInGoogle()
                } label: {
                    Text("구글 로그인")
                        .font(Font.pretendardBold18)
                        .foregroundStyle(.black)
                }
                .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.06)
                .background(Color(uiColor: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)))
                .cornerRadius(12)
                
                Button {
                    authStore.signInWithApple()
                } label: {
                    Text("Apple 로그인")
                        .font(Font.pretendardBold18)
                        .foregroundStyle(.black)
                }
                .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.06)
                .background(Color(uiColor: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)))
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .onDisappear {
            if let email = authStore.currentUser?.email {
                userStore.fetchCurrentUser(userEmail: email)
                
                userStore.fetchMyInfo(userEmail: email, completion: { result in
                    if result {
                        
                    }
                })
            }
        }
    }
}

#Preview {
    LoginView()
}
