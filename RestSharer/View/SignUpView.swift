//
//  SignUpView.swift
//  RestSharer
//
//  Created by 변상우 on 10/7/24.
//

import SwiftUI

enum Field {
    case nickName
}

struct SignUpView: View {
    
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore
    @State private var checkNicknameColor: Color = Color.red

    @State private var nickName: String = ""
    @State private var phoneNumber: String = ""
    @State private var cautionNickname: String = ""
    
    @State private var isHiddenCheckButton: Bool = false
    @State private var checkNickname: Bool = false /// 닉네임 중복 확인 Bool 값
    @State private var isNicknameValid: Bool = true
    
    @State private var agreeToPrivacyPolicy: Bool = false  // 개인정보 처리방침 동의 상태

    @FocusState private var focusField: Field?
    
    private let phoneNumberMaximumCount: Int = 11  /// 휴대폰 번호 최대 글자수

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
                Text("전화번호")
                    .font(.pretendardBold14)
                    .foregroundStyle(.primary)
                TextField("ex) 01098765432 (-)없이", text: $phoneNumber)
                    .disableAutocorrection(true) // 자동수정 비활성화
                    .frame(width: .screenWidth*0.90, height: .screenHeight*0.05)
                    .padding(.leading, 5)
                    .background(Color.lightGrayColor)
                    .cornerRadius(7)
                    .keyboardType(.numberPad)
                    .onChange(of: phoneNumber) { newValue in
                        if newValue.count > phoneNumberMaximumCount {
                            phoneNumber = String(newValue.prefix(phoneNumberMaximumCount))
                        }
                    }

                // MARK: 개인정보 수집 약관 동의
                HStack {
                    Image(systemName: agreeToPrivacyPolicy ? "checkmark.square" : "square")
                        .onTapGesture {
                            agreeToPrivacyPolicy.toggle()
                        }
                    Text("개인정보 처리방침에 동의합니다.")
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
            .disabled(!checkNickname || phoneNumber.count < phoneNumberMaximumCount || !agreeToPrivacyPolicy)
            .padding()
            
            Spacer()
        }
        .padding(.horizontal, 12)
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
