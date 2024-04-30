//
//  Modifiers.swift
//  RestSharer
//
//  Created by 강민수 on 5/10/24.
//

import SwiftUI

struct BottomBorder: ViewModifier {
    
    let showBorder: Bool
    
    func body(content: Content) -> some View {
        Group {
            if showBorder {
                content.overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 2)
                        .foregroundColor(.primary)
                        .padding(.top, 10)
                    , alignment: .bottom
                )
            } else {
                content
            }
        }
    }
}
