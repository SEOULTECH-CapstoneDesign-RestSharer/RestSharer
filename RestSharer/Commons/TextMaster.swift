//
//  TextMaster.swift
//  RestSharer
//
//  Created by 변상우 on 5/10/24.
//

import SwiftUI

struct TextMaster: View {
    
    @Binding var text: String
    @State private var dynamicHeight: CGFloat
    
    let isFocused: FocusState<Bool>.Binding
    let minLine: Int
    let maxLine: Int
    let font: UIFont
    let becomeFirstResponder: Bool
    let placeholder: String
    
    init(
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        minLine: Int = 3,
        maxLine: Int,
        fontSize: CGFloat,
        becomeFirstResponder: Bool = false,
        placeholder: String
        
    )
    {
        _text = text
        self.isFocused = isFocused
        self.minLine = minLine
        self.maxLine = maxLine
        self.becomeFirstResponder = becomeFirstResponder
        self.placeholder = placeholder
        
        let font = UIFont(name: "Pretendard-Regular", size: fontSize)
        self.font = font!
        _dynamicHeight = State(initialValue: font!.lineHeight * CGFloat(minLine) + 16) // textContainerInset 디폴트 값은 top, bottom 으로 각각 패딩 8 씩 들어감
    }
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
//            RoundedRectangle(cornerRadius: 10) // 테두리를 둥글게 만들기 위한 RoundedRectangle 사용
//                .fill(Color.clear)
//                .border(Color.privateColor, width: 1)
//                .frame(height: dynamicHeight)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(.custom(font.familyName, size: font.pointSize))
                    .foregroundColor(Color(UIColor.placeholderText))
                    .padding(EdgeInsets(top: 7, leading: 5, bottom: 0, trailing: 0))
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isFocused.wrappedValue ? 0 : 1)
            }
            UITextViewRepresentable(
                text: $text,
                dynamicHeight: $dynamicHeight,
                isFocused: isFocused,
                minLine: minLine,
                maxLine: maxLine,
                font: font,
                becomeFirstResponder: becomeFirstResponder)
            .frame(height: dynamicHeight)
            .focused(isFocused)
//            .border(isFocused.wrappedValue ? Color.privateColor : Color.gray, width: 1)
        }
    }
}
fileprivate struct UITextViewRepresentable: UIViewRepresentable {

  @Binding var text: String
  @Binding var dynamicHeight: CGFloat

  let isFocused: FocusState<Bool>.Binding
  let minLine: Int
  let maxLine: Int
  let font: UIFont
  let becomeFirstResponder: Bool

  func makeUIView(context: UIViewRepresentableContext<UITextViewRepresentable>) -> UITextView {
    let textView = UITextView(frame: .zero)
    textView.delegate = context.coordinator
    textView.font = font
    textView.backgroundColor = .clear
    textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textView.isScrollEnabled = false
    textView.bounces = false
    textView.layer.cornerRadius = 10

    if becomeFirstResponder {
      textView.becomeFirstResponder()
    }

    return textView
  }

  func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewRepresentable>) {
    guard uiView.text == self.text else { // 외부에서 주입되는 텍스트에 대한 반응을 위해 필요
      uiView.text = self.text
      return
    }
  }

  func makeCoordinator() -> UITextViewRepresentable.Coordinator {
    Coordinator(
      text: $text,
      isFocused: isFocused,
      dynamicHeight: $dynamicHeight,
      minHeight: font.lineHeight * CGFloat(minLine) + 16,
      maxHeight: font.lineHeight * CGFloat(maxLine + (maxLine > minLine ? 1 : .zero)) + 16)
  }

  final class Coordinator: NSObject, UITextViewDelegate {

    @Binding var text: String
    @Binding var dynamicHeight: CGFloat

    let isFocused: FocusState<Bool>.Binding
    let minHeight: CGFloat
    let maxHeight: CGFloat

    init(
      text: Binding<String>,
      isFocused: FocusState<Bool>.Binding,
      dynamicHeight: Binding<CGFloat>,
      minHeight: CGFloat,
      maxHeight: CGFloat)
    {
      _text = text
      self.isFocused = isFocused
      _dynamicHeight = dynamicHeight
      self.minHeight = minHeight
      self.maxHeight = maxHeight
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
      isFocused.wrappedValue = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
      isFocused.wrappedValue = false
    }

    func textViewDidChange(_ textView: UITextView) {
      self.text = textView.text ?? ""

      if text.isEmpty {
        dynamicHeight = minHeight
        textView.isScrollEnabled = false
        return
      }

      let newSize = textView.sizeThatFits(.init(width: textView.frame.width, height: .greatestFiniteMagnitude))

      print("\n🔽최대 높이 -> \(maxHeight)")
      print("❤️NEW SIZE -> \(newSize.height) / lineHeight -> \(textView.font!.lineHeight)")
      print("🔼최소 높이 -> \(minHeight)")

      if newSize.height < maxHeight, textView.isScrollEnabled { // 최대 높이 미만으로 줄어들면서, 스크롤이 true 라면...
        textView.isScrollEnabled = false
        print("📜 스크롤 뷰 꺼짐!")
      } else if newSize.height > maxHeight, !textView.isScrollEnabled { // 최대 높이 초과로 커지면서, 스크롤이 false 라면...
        textView.isScrollEnabled = true
        textView.flashScrollIndicators()
        print("🦋 스크롤 뷰 켜짐!")
      }

      guard newSize.height > minHeight, newSize.height < maxHeight else { return }
      dynamicHeight = newSize.height // 텍스트뷰의 동적 높이 조절
    }
  }
}
