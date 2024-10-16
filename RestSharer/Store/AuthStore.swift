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
    case apple
    case none
}

class AuthStore: NSObject, ObservableObject {
    @Published var currentUser: Firebase.User?
    @Published var welcomeToast: Bool = false
    @Published var loginPlatform: LoginPlatform = .google
    
    let userStore: UserStore = UserStore()
    
    override init() {
        currentUser = Auth.auth().currentUser
    }
    
    // 구글 로그인 함수
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
    
    // 구글 로그인 후 사용자 정보 처리
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
    
    // 애플 로그인
    func signInWithApple() {
        print("============signInWithApple============")
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // 애플 로그인 후 사용자 정보 처리
    func handleAuthorization(_ authorization: ASAuthorization) {
        print("============handleAuthorization============")
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        if let fullName = credential.fullName,
           let identifyToken = credential.identityToken {
            let userName = (fullName.familyName ?? "") + (fullName.givenName ?? "")
            let email = credential.email
            
            guard let identityToken = credential.identityToken else {
                print("애플 로그인 토큰을 가져올 수 없습니다.")
                return
            }

            guard let idTokenString = String(data: identityToken, encoding: .utf8) else {
                print("토큰 문자열 변환 실패")
                return
            }
            
            let firebaseCredential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: "" // Nonce는 선택적입니다.
            )
            
            
            Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
                if let error = error {
                    print("Firebase 애플 로그인 실패: \(error.localizedDescription)")
                    return
                }
                
                userCollection.whereField("email", isEqualTo: (authResult?.user.email)!).getDocuments { snapshot, error in
                    if snapshot!.documents.isEmpty {
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let userData: [String: Any] = ["email" : authResult?.user.email ?? "",
                                                           "name" : "appleLogin",
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
                            
                            if let user = User(document: userData) {
                                self.currentUser = authResult?.user
                                self.welcomeToast = true
                                self.loginPlatform = .apple
                                
                                self.userStore.createUser(user: user)
                            }
                        }
                    } else {
                        userCollection.document((authResult?.user.email)!).getDocument { snapshot, error in
                            _ = snapshot!.data()
                            
                            self.currentUser = authResult?.user
                            self.welcomeToast = true
                            self.loginPlatform = .apple
                        }
                    }
                }
            }
        }
    }
    
    func doubleCheckNickname(nickname: String) async -> Bool {
        do {
            let datas = try await userCollection.whereField("nickname", isEqualTo: nickname).getDocuments()
            if !datas.isEmpty {
                return false
            } else {
                return true
            }
        }
        catch {
            debugPrint("getDocument 에러")
            return false
        }
    }
    
    // 공통 로그아웃 함수
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            loginPlatform = .none
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 사용자 계정 삭제
    func deleteAuth() {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print("사용자 삭제 중 오류 발생: \(error.localizedDescription)")
            } else {
                print("사용자 삭제 완료")
            }
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthStore: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        handleAuthorization(authorization)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("애플 로그인 오류: \(error.localizedDescription)")
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first { $0.isKeyWindow } ?? windowScene.windows[0]
        }
        fatalError("No key window available")
    }
}
