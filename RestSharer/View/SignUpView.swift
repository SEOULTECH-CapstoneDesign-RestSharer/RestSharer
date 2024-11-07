//
//  SignUpView.swift
//  RestSharer
//
//  Created by 변상우 on 10/7/24.
//

import SwiftUI
import WebKit

enum Field {
    case nickName
}

struct SignUpView: View {
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore
    @State private var checkNicknameColor: Color = Color.red

    @State private var nickName: String = ""
    @State private var phoneNumber: String = "01012345678"
    @State private var cautionNickname: String = ""
    
    @State private var isHiddenCheckButton: Bool = false
    @State private var checkNickname: Bool = false /// 닉네임 중복 확인 Bool 값
    @State private var isNicknameValid: Bool = true
    
    @State private var agreeToPrivacyPolicy: Bool = false  // 개인정보 처리방침 동의 상태
    @State private var agreeToServicePolicy: Bool = false  // 서비스 이용약관 동의 상태
    @State private var showPrivacyPolicySheet = false
    @State private var showServicePolicySheet = false

    @FocusState private var focusField: Field?
    
    private let phoneNumberMaximumCount: Int = 11  /// 휴대폰 번호 최대 글자수
    
    private var allAgreement: Bool {
        return agreeToPrivacyPolicy && agreeToServicePolicy && checkNickname ? true : false
    }
    
    

    var body: some View {
        VStack {
            Spacer()
            Text("RestSharer")
                .font(.pretendardBold28)
                .foregroundStyle(.primary)
            
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                //MARK: 닉네임
                Text("닉네임")
                    .font(.pretendardBold14)
                    .foregroundStyle(.primary)
                HStack {
                    ZStack {
                        TextField("ex) Chris (특수문자 불가, 최대 20자)", text: $nickName)
                            .textInputAutocapitalization(.never) // 첫글자 대문자 비활성화
                            .disableAutocorrection(true) // 자동수정 비활성화
                            .border(isNicknameValid ? Color.clear : Color.accentColor)
                            .focused($focusField, equals: .nickName)
                            .frame(width: .screenWidth*0.90, height: .screenHeight*0.05)
                            .padding(.leading, 5)
                            .background(Color.lightGrayColor)
                            .cornerRadius(7)
                            .onChange(of: nickName) {
                                ischeckNickname()
                                checkNickname = true
                                nickName = String(nickName.prefix(20)).trimmingCharacters(in: .whitespaces)
                                Task {
                                    checkNickname = await authStore.doubleCheckNickname(nickname: nickName)
                                    print("중복여부: \(checkNickname)")
                                }
                            }
                        
                        Spacer()
                        //MARK: 중복확인
                        if isHiddenCheckButton {
                            if checkNickname == false {
                                Text("이미 사용 중인 닉네임")
                                    .font(.pretendardBold18)
                                    .foregroundStyle(.red)
                                    .padding(.leading, 180)
                            } else {
                                Text("사용 가능")
                                    .foregroundStyle(.green)
                                    .padding(.leading, 250)
                            }
                        }
                    }
                } // HStack
                if !isValidNickname(nickName) && nickName.count > 0 {
                    Text(cautionNickname)
                        .font(.pretendardMedium16)
                        .foregroundStyle(checkNicknameColor)
                }
                
                //MARK: 전화번호
//                Text("전화번호")
//                    .font(.pretendardBold14)
//                    .foregroundStyle(.primary)
//                TextField("ex) 01012345678 (-)없이", text: $phoneNumber)
//                    .disableAutocorrection(true) // 자동수정 비활성화
//                    .frame(width: .screenWidth*0.90, height: .screenHeight*0.05)
//                    .padding(.leading, 5)
//                    .background(Color.lightGrayColor)
//                    .cornerRadius(7)
//                    .keyboardType(.numberPad)
//                    .onChange(of: phoneNumber) { newValue in
//                        if newValue.count > phoneNumberMaximumCount {
//                            phoneNumber = String(newValue.prefix(phoneNumberMaximumCount))
//                        }
//                    }

                // MARK: 개인정보 수집 약관 동의
                HStack {
                    Image(systemName: agreeToPrivacyPolicy ? "checkmark.square" : "square")
                        .onTapGesture {
                            agreeToPrivacyPolicy.toggle()
                        }
                    Text("(필수)개인정보 처리방침에 동의합니다.")
                        .onTapGesture {
                            // 웹사이트를 시트 형식으로 열기 위한 상태 업데이트
                            showPrivacyPolicySheet = true
                        }
                }
                .padding(.top, 10)
                
                HStack {
                    Image(systemName: agreeToServicePolicy ? "checkmark.square" : "square")
                        .onTapGesture {
                            agreeToServicePolicy.toggle()
                        }
                    Text("(필수)서비스 이용약관에 동의합니다.")
                        .onTapGesture {
                            // 웹사이트를 시트 형식으로 열기 위한 상태 업데이트
                            showServicePolicySheet = true
                        }
                }
                .padding(.top, 10)
            }
            .padding(.bottom, 20)
            
            // 정보 입력 완료 버튼
            Button {
                userStore.user.nickname = nickName
                userStore.user.phoneNumber = phoneNumber
                userStore.updateUser(user: userStore.user)
            } label: {
                Text("정보입력 완료하기")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!allAgreement)
            .padding()
            
            Spacer()
        }
        .padding(.horizontal, 12)
        
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
    
    // MARK: 닉네임 유효성 체크 함수
    func ischeckNickname() {
        if isValidNickname(nickName) {
            cautionNickname = ""
            isHiddenCheckButton = true
            checkNicknameColor = .red
        }
        else if (!isValidNickname(nickName) && nickName.count > 0) || nickName == "" {
            cautionNickname = "닉네임 형식이 맞지 않습니다."
            isHiddenCheckButton = false
            checkNicknameColor = .red
        }
    }
    
    func isValidNickname(_ nickName: String) -> Bool {
        let nicknameExpression = "^[a-zA-Z0-9]+$"
        let nickNamePredicate = NSPredicate(format:"SELF MATCHES %@", nicknameExpression)
        return nickNamePredicate.evaluate(with: nickName)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(UserStore())
            .environmentObject(AuthStore())
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
