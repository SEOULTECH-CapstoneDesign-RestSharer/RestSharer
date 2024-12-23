//
//  MainHomeView.swift
//  RestSharer
//
//  Created by 강민수 on 5/10/24.
//

import SwiftUI
import NMapsMap

struct MainHomeView: View {
    @EnvironmentObject var feedStore: FeedStore
//    @EnvironmentObject var postStore: PostStore
    @ObservedObject var coordinator: Coordinator = Coordinator.shared
//    @ObservedObject var locationSearchStore = LocationSearchStore.shared
    
    @Binding var root: Bool
    @Binding var selection: Int
    @Binding var showLocation: Bool
//    @Binding var searchResult: SearchResult
    
    @State var selectedNumber: Int = 0
    @State private var tapped: Bool = true
    @State private var isShowSearch: Bool = false

    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    HStack(alignment: .bottom) {
                        VStack {
                            Spacer()
                            HStack {
                                Button {
                                    selectedNumber = 0
                                } label: {
                                    Image(systemName: "map")
                                    Text("지도")
                                }
                                .font(.pretendardBold20)
                                .foregroundColor(selectedNumber == 0 ? .privateColor : .subGrayColor)
                                .padding(.bottom, 10)
                                .padding(.trailing, 10)
                                //                            .modifier(YellowBottomBorder(showBorder: selectedNumber == 0))
                                
                                Button {
                                    selectedNumber = 1
                                } label: {
                                    Image(systemName: "text.justify")
                                    Text("피드")
                                }
                                .font(.pretendardBold20)
                                .foregroundColor(selectedNumber == 1 ? .privateColor : .subGrayColor)
                                .padding(.bottom, 10)
                                .padding(.trailing, 10)
                                //                            .modifier(YellowBottomBorder(showBorder: selectedNumber == 1))
                            }
                        }
                        
                        Spacer()
                        
//                        NavigationLink {
//                            ChatRoomListView()
//                        } label: {
//                            Image(systemName: "paperplane")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 22)
//                                .padding(.bottom, 10)
//                                .padding(.trailing, 10)
//                        }
                    }
                    .frame(height: 50)
                }
                .padding(.leading, 10)
                .padding(.horizontal, 10)
                .font(.pretendardMedium20)
                .foregroundColor(.primary)
                
                .sheet(isPresented: $isShowSearch) {
                    //                MapSearchView(showLocation: $showLocation, searchResult: $searchResult, coord: $coordinator.coord, selection: $selection)
                }
                if selectedNumber == 0 {
                    MapMainView(root: $root, selection: $selection)
                } else if selectedNumber == 1 {
                    FeedMainView(root: $root, selection: $selection)
                }
            }
        } else {
            // Fallback on earlier versions
        }
//        .popup(isPresented: $feedStore.uploadToast) {
//            ToastMessageView(message: "업로드가 완료되었습니다!")
//                .onDisappear {
//                    self.feedStore.uploadToast = false
//                }
//        } customize: {
//            $0
//                .autohideIn(2)
//                .type(.floater(verticalPadding: 20))
//                .position(.bottom)
//                .animation(.spring())
//                .closeOnTapOutside(true)
//                .backgroundColor(.clear)
//        }
//        
//        .popup(isPresented: $feedStore.deleteToast) {
//            ToastMessageView(message: "피드가 삭제되었습니다.")
//                .onDisappear {
//                    self.feedStore.uploadToast = false
//                }
//        } customize: {
//            $0
//                .autohideIn(3)
//                .type(.floater(verticalPadding: 20))
//                .position(.bottom)
//                .animation(.spring())
//                .closeOnTapOutside(true)
//                .backgroundColor(.clear)
//        }
//        
//        .popup(isPresented: $feedStore.updatedToast) {
//            ToastMessageView(message: "피드가 수정 완료 되었습니다.")
//                .onDisappear {
//                    self.feedStore.uploadToast = false
//                }
//        } customize: {
//            $0
//                .autohideIn(3)
//                .type(.floater(verticalPadding: 20))
//                .position(.bottom)
//                .animation(.spring())
//                .closeOnTapOutside(true)
//                .backgroundColor(.clear)
//        }
    }
}

//struct MainHomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainHomeView(root: .constant(true), selection: .constant(1), showLocation: .constant(true), searchResult: .constant(SearchResult(title: "", category: "", address: "", roadAddress: "", mapx: "", mapy: "")))
//            .environmentObject(FeedStore())
//    }
//}
