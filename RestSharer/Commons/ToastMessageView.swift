//
//  ToastMessageView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI

struct ToastMessageView: View {
    var message: String
    
    var body: some View {
        Text("\(message)")
            .font(.pretendardMedium16)
            .foregroundColor(.white)
            .frame(width: .screenWidth * 0.8, height: 50)
            .background(Color.darkGrayColor)
            .cornerRadius(30)
    }
}
