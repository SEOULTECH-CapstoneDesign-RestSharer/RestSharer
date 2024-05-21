//
//  RestSharerApp.swift
//  RestSharer
//
//  Created by 변상우 on 4/29/24.
//

import SwiftUI

import Firebase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

@main
struct RestSharerApp: App {
    
    @StateObject private var feedStore = FeedStore()
    
    init() {
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(AuthStore())
                .environmentObject(feedStore)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    /// 구글 로그인 인증 프로세스가 끝날 때 애플리케이션이 수신하는 URL
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
