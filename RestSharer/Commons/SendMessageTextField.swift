//
//  SendMessageTextField.swift
//  RestSharer
//
//  Created by 변상우 on 9/30/24.
//

import SwiftUI

struct SendMessageTextField: View {
    @Binding var text: String
    
    var placeholder: String
    var action: () -> Void
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never) // 첫글자 대문자 비활성화
                .disableAutocorrection(true) // 자동수정 비활성화
                .padding(10)
                .padding(.leading, 5)
                .padding(.trailing, 40)
                .background(Color.lightGrayColor)
                .cornerRadius(20)
            
            Button(action: action) {
                Circle()
                    .frame(width: 35)
                    .foregroundColor(.black)
                    .overlay {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .scaledToFit()
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 15)
                    }
            }
            .padding(.trailing, 5)
            .zIndex(3)
        }
//        .frame(width: .screenWidth * 0.9, height: 40)
//        .padding(.bottom, 10)
    }
}
