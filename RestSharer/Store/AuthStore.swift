//
//  AuthStore.swift
//  RestSharer
//
//  Created by 변상우 on 4/30/24.
//

import Foundation

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import Combine
import AuthenticationServices
import CryptoKit
import FirebaseCore

enum LoginPlatform {
    case email
    case google
    case none
}

class AuthStore: ObservableObject {
    @Published var currentUser: Firebase.User?
    @Published var welcomeToast: Bool = false
    @Published var loginPlatform: LoginPlatform = .google
    
    let userStore: UserStore = UserStore()
    
    init() {
        currentUser = Auth.auth().currentUser
    }
    
    func signInGoogle() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        } else {
            guard let cliendID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: cliendID)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            
            guard let rootViewController = windowScene.windows.first?.rootViewController else {
                return
            }
            
            GIDSignIn.sharedInstance.configuration = configuration
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
                authenticateUser(for: result?.user, with: error)
            }
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let googleUser = user {
            let email = googleUser.profile?.email ?? ""
            let name = googleUser.profile?.name ?? ""
            
            let userData: [String: Any] = ["email" : email,
                                           "name" : name,
                                           "nickname" : "",
                                           "phoneNumber" : "",
                                           "profileImageURL" : "",
                                           "follower" : [],
                                           "following" : [],
                                           "myFeed" : [],
                                           "savedFeed" : [],
                                           "bookmark" : [],
                                           "chattingRoom" : [],
                                           "myReservation" : []
            ]
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let idToken = user?.idToken?.tokenString, let accessToken = user?.accessToken.tokenString else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            userCollection.whereField("email", isEqualTo: (user?.profile?.email)!).getDocuments { snapshot, error in
                if snapshot!.documents.isEmpty {
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        Auth.auth().signIn(with: credential) { [unowned self] (result, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                if let user = User(document: userData) {
                                    self.currentUser = result?.user
                                    self.welcomeToast = true
                                    self.userStore.createUser(user: user)
                                    self.loginPlatform = .google
                                }
                            }
                        }
                    }
                } else {
                    userCollection.document((user?.profile?.email)!).getDocument { snapshot, error in
                        _ = snapshot!.data()
                        
                        Auth.auth().signIn(with: credential) { result, error in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            } else {
                                self.currentUser = result?.user
                                self.welcomeToast = true
                                self.loginPlatform = .google
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signOutGoogle() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            print(error.localizedDescription)
        }
    }
    func deleteAuth (_ email: String) {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print("사용자 삭제 중 오류 발생: \(error.localizedDescription)")
            } else {
                print("사용자 삭제 완료")
            }
        }
        
    }
}
