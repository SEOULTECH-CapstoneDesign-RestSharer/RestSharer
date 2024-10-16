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

enum LoginPlatform {
    case email
    case google
    case apple
    case none
}

class AuthStore: NSObject, ObservableObject {
    @Published var currentUser: Firebase.User?
    @Published var welcomeToast: Bool = false

    let userStore: UserStore = UserStore()
    
    override init() {
        currentUser = Auth.auth().currentUser
    }
    
    // Google 로그인
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
                            }
                        }
                    }
                }
            }
        }
    }

    // Apple 로그인
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // Apple 로그인 후 사용자 정보 처리
    func handleAuthorization(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

        guard let identityToken = credential.identityToken else {
            print("애플 로그인 토큰을 가져올 수 없습니다.")
            return
        }

        guard let idTokenString = String(data: identityToken, encoding: .utf8) else {
            print("토큰 문자열 변환 실패")
            return
        }

        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: "")

        Auth.auth().signIn(with: firebaseCredential) { [weak self] authResult, error in
            if let error = error {
                print("Firebase 애플 로그인 실패: \(error.localizedDescription)")
                return
            }
            
            self?.handleUserData(authResult: authResult)
        }
    }


    // 사용자 데이터 처리
    private func handleUserData(authResult: AuthDataResult?) {
        guard let email = authResult?.user.email else { return }
        print("handleUserData")
        print("email: \(email)")
        userCollection.whereField("email", isEqualTo: email).getDocuments { [weak self] snapshot, error in
            if snapshot?.documents.isEmpty == true {
                print("snapshot?.documents.isEmpty == true")
                let userData: [String: Any] = [
                    "email": email,
                    "name": "appleLogin",
                    "nickname": "",
                    "phoneNumber": "",
                    "profileImageURL": "",
                    "follower": [],
                    "following": [],
                    "myFeed": [],
                    "savedFeed": [],
                    "bookmark": [],
                    "chattingRoom": [],
                    "myReservation": []
                ]
                
                if let user = User(document: userData) {
                    self?.currentUser = authResult?.user
                    self?.welcomeToast = true
                    self?.userStore.createUser(user: user)
                }
            } else {
                print("snapshot?.documents.isEmpty != true")
                self?.currentUser = authResult?.user
                self?.welcomeToast = true
            }
        }
    }

    // 공통 로그아웃 함수
    func signOut() {
        print("signOut")

        if let domain = extractDomain(from: currentUser?.email ?? "") {
            print("domain: \(domain)")
            switch domain {
            case "gmail.com":
                print("gmail")
                GIDSignIn.sharedInstance.signOut()
                
                do {
                    try Auth.auth().signOut()
                    currentUser = nil
                } catch {
                    print(error.localizedDescription)
                }
            case "privaterelay.appleid.com":
                print("appleid")
                do {
                    try Auth.auth().signOut()
                    currentUser = nil
                } catch {
                    print(error.localizedDescription)
                }
            default:
                print("이메일 플랫폼 삭제 로직 필요")
            }
        }
    }

    // 사용자 계정 삭제 함수 (재인증 포함)
    func deleteAuth() {
        guard let user = Auth.auth().currentUser else {
            print("사용자가 로그인되어 있지 않습니다.")
            return
        }

        if let domain = extractDomain(from: user.email ?? "") {
            switch domain {
            case "gmail.com":
                deleteUserWithGoogle(user: user)
            case "privaterelay.appleid.com":
                signOut()
            default:
                print("이메일 플랫폼 삭제 로직 필요")
            }
        }
    }

    // 구글 계정 삭제
    private func deleteUserWithGoogle(user: Firebase.User) {
        guard let idToken = GIDSignIn.sharedInstance.currentUser?.idToken?.tokenString else {
            print("Google 인증 토큰을 가져올 수 없습니다.")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString ?? "")
        reauthenticateAndDelete(user: user, credential: credential)
    }

    // 재인증 후 계정 삭제 처리 함수
    private func reauthenticateAndDelete(user: Firebase.User, credential: AuthCredential) {
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                print("재인증 실패: \(error.localizedDescription)")
                return
            }
            
            // 재인증 성공 시 계정 삭제
            user.delete { error in
                if let error = error {
                    print("사용자 삭제 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("사용자 삭제 완료")
//                    GIDSignIn.sharedInstance.signOut()
                    
                    Task {
                        do {
                            try Auth.auth().signOut()
                            GIDSignIn.sharedInstance.signOut()
                            self.currentUser = nil
                        } catch {
                            
                        }
                    }
                    
//                    do {
//                        try Auth.auth().signOut()
//                        self.currentUser = nil
//                    } catch {
//                        print(error.localizedDescription)
//                    }
                }
            }
        }
    }

    // 도메인 추출 함수
    func extractDomain(from email: String) -> String? {
        let emailComponents = email.split(separator: "@")
        guard emailComponents.count == 2 else { return nil }
        return String(emailComponents[1])
    }
    
    func doubleCheckNickname(nickname: String) async -> Bool {
        do {
            let datas = try await userCollection.whereField("nickname", isEqualTo: nickname).getDocuments()
            return datas.isEmpty
        }
        catch {
            debugPrint("getDocument 에러")
            return false
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
