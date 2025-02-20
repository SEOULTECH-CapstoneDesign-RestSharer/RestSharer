//
//  ShopInfoCardView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI
import Kingfisher
import NMapsMap

struct ShopInfoCardView: View {
    @EnvironmentObject var userStore: UserStore
    
    @ObservedObject var postCoordinator: PostCoordinator = PostCoordinator.shared
    @ObservedObject var detailCoordinator = DetailCoordinator.shared
    @StateObject private var locationSearchStore = LocationSearchStore.shared
    
    @Binding var isShowingLocation: Bool
    @Binding var searchResult: SearchResult
    
    @State private var lat: String = ""
    @State private var lng: String = ""
    
    let mySavedPlaceList: [MyFeed]
    var isOtherUser: Bool
    
    var body: some View {
        ForEach(mySavedPlaceList, id:\.self) {place in
            HStack {
                Button {
                    isShowingLocation = true
                    
                    lat = locationSearchStore.formatCoordinates(place.mapy, 2) ?? ""
                    lng = locationSearchStore.formatCoordinates(place.mapx, 3) ?? ""
                    
                    detailCoordinator.coord = NMGLatLng(lat: Double(lat) ?? 0, lng: Double(lng) ?? 0)
                    postCoordinator.newMarkerTitle = place.title
                    searchResult.title = place.title
                    
                    postCoordinator.moveCameraPosition()
                    postCoordinator.makeSearchLocationMarker()
                    print("\(place.id)")
                } label: {
                    KFImage(URL(string:place.images[0])) .placeholder {
                        Image(systemName: "photo")
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: .screenWidth * 0.2, height: .screenWidth * 0.2)
                    .cornerRadius(10)
                    .padding(.leading,7)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(place.title)
                                .font(.pretendardSemiBold16)
                                .foregroundColor(.primary)
                                .padding(.bottom, 2)
                            Divider()
                                .frame(height: .screenHeight * 0.01)
                                .background(Color.primary)
                            Label(
                                title: { Text(place.category[0])
                                        .font(.pretendardRegular12)
                                        .foregroundColor(.primary)
                                },
                                icon: { Image(systemName: "fork.knife").foregroundColor(.privateColor).frame(width: 1).padding(.leading, 6).padding(.trailing, 4) }
                            )
                        }
                        VStack(alignment: .leading) {
                            HStack{
                                Image(systemName: "mappin")
                                    .foregroundColor(.privateColor)
                                    .frame(width: .screenWidth * 0.001)
                                    .padding([.leading,.trailing], 4)
                                Text(place.roadAddress)
                                    .font(.pretendardRegular12)
                                    .foregroundColor(.primary)
                                    .padding(.leading,-3)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.top,2)
                    }
                    .padding(.leading,3)
                }
                
                Spacer()
                Button {
                    userStore.user.bookmark.removeAll { $0 == "\(place.id)" }
                    userStore.deletePlace(place)
                    userStore.updateUser(user: userStore.user)
                } label: {
                    Image(systemName: "pin.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(.private))
                        .padding(.trailing, 15)
                }.disabled(isOtherUser)
            }
            Divider()
                .background(Color.primary)
                .frame(width: .screenWidth * 0.98)
        }
        
    }
}
