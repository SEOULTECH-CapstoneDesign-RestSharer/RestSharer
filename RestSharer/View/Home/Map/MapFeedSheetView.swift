//
//  MapFeedSheetView.swift
//  Private
//
//  Created by 변상우 on 5/10/24.
//
import SwiftUI

struct MapFeedSheetView: View {
    
    @EnvironmentObject private var userStore: UserStore
    
    @State private var isChangePlaceColor: Bool = false
    
    let feed: [MyFeed]
    
    var body: some View {
        ScrollView {
            HStack {
//                Button {
//                    if (userStore.user.bookmark.contains("\(feed.id)")) {
//                        userStore.deletePlace(feed)
//                        userStore.user.bookmark.removeAll { $0 == "\(feed.id)" }
//                        userStore.updateUser(user: userStore.user)
//                        userStore.clickSavedCancelPlaceToast = true
//                        isChangePlaceColor.toggle()
//                    } else {
//                        userStore.savePlace(feed) //장소 저장 로직(사용가능)
//                        userStore.user.bookmark.append("\(feed.id)")
//                        userStore.updateUser(user: userStore.user)
//                        userStore.clickSavedPlaceToast = true
//                        isChangePlaceColor.toggle()
//                    }
//                } label: {
//                    Image(systemName: userStore.user.bookmark.contains("\(feed.id)") ? "pin.fill": "pin")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 15)
//                        .padding(.horizontal, 10)
//                        .foregroundColor(isChangePlaceColor ? .privateColor : .white)
//                        .foregroundColor(userStore.user.bookmark.contains("\(feed.images[0].suffix(32))") ? .privateColor : .primary)
//                }
//                .padding(.leading, 15)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(feed[0].title)")
                        .font(.pretendardMedium16)
                        .foregroundColor(.primary)
                    Text("\(feed[0].roadAddress)")
                        .font(.pretendardRegular12)
                        .foregroundColor(.primary)
                }
                .padding(.leading, 15)
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 80)
            .background(Color.darkGraySubColor)
            .cornerRadius(15)
            
            ForEach(feed) { feed in
                MapFeedCellView(feed: feed)
            }
        }
        .padding(.top, 20)
        
        .onAppear {
            print("MapFeedSheetView \(feed)")
        }
    }
}

//struct MapFeedSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapFeedSheetView()
//    }
//}
