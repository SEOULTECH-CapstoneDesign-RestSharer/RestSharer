//
//  LaunchView.swift
//  RestSharer
//
//  Created by 변상우 on 4/30/24.
//

import SwiftUI

struct LaunchView: View {
    
    @EnvironmentObject var authStore: AuthStore
    
    @State private var isActive = false
    @State private var isloading = true
    
    var body: some View {
        if isActive {
            if authStore.currentUser != nil {
                MainTabView()
             } else {
                 LoginView()
             }
        } else {
            if isloading {
                ZStack {
                    Text("RestSharer")
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            self.isActive = true
                            self.isloading.toggle()
                        }
                    }
                    
//                    if let email = authStore.currentUser?.email {
//                        userStore.fetchCurrentUser(userEmail: email)
//                        
//                        userStore.fetchMyInfo(userEmail: email, completion: { result in
//                            if result {
//                                self.isActive = true
//                                self.isloading.toggle()
//                            }
//                        })
//                    } else {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                            withAnimation {
//                                self.isActive = true
//                                self.isloading.toggle()
//                            }
//                        }
//                    }
                }
            }
        }
    }
}

#Preview {
    LaunchView()
}
