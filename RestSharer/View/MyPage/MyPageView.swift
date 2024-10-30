//
//  MyPageView.swift
//  RestSharer
//
//  Created by 강민수 on 6/23/24.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var feedStore: FeedStore
    @EnvironmentObject private var followStore: FollowStore
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var postCoordinator: PostCoordinator = PostCoordinator.shared
    
    @Binding var root: Bool
    @Binding var selection: Int
    /// 각 버튼을 누르면 해당 화면을 보여주는 bool값
    @State var viewNumber: Int = 0
    
    var body: some View {
        NavigationStack {
            HStack {
                Spacer()
                
                NavigationLink {
                    SettingView()
                } label: {
                    Image(systemName: "gearshape")
                        .padding(.top, 10)
                        .padding(.trailing,30)
                        .foregroundColor(.primary)
                }
            }
            
            UserInfoView(followerList: followStore.followerList, followingList: followStore.followingList)
                .padding(.top,-20.0)
                .padding(.bottom, 20)
            
            HStack {
                NavigationLink {
                    NavigationStack {
                        PostNaverMap(currentFeedId: $postCoordinator.currentFeedId, showMarkerDetailView: $postCoordinator.showMarkerDetailView, showMyMarkerDetailView: $postCoordinator.showMyMarkerDetailView, coord: $postCoordinator.coord, tappedLatLng: $postCoordinator.tappedLatLng)
                        .sheet(isPresented: $postCoordinator.showMyMarkerDetailView) {
                            MapFeedSheetView(feed: feedStore.feedList.filter { $0.address == postCoordinator.currentFeedId })
                                .presentationDetents([.height(.screenHeight * 0.55)])
                        }
                    .navigationBarBackButtonHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("내 마커")
                    .backButtonArrow()
                    }
                } label: {
                    HStack {
                        Image(systemName: "map")
                        Text("내 마커")
                            .font(.pretendardRegular14)
                    }
                    .foregroundColor(.primary)
                }
                .frame(width: .screenWidth*0.5)
            }
            
            HStack {
                Button {
                    viewNumber = 0
                }label: {
                    HStack {
                        Spacer()
                        viewNumber == 0 ? Image( systemName: "location.fill") : Image (systemName: "location")
                        Text("내 피드")
                        Spacer()
                    }
                    .font(.pretendardRegular12)
                    .foregroundColor(viewNumber == 0 ? .privateColor : .primary)
                    .padding(.bottom, 15)
                    .padding([.trailing,.leading], 0)
                    .modifier(YellowBottomBorder(showBorder: viewNumber == 0))
                }
                
                Button {
                    viewNumber = 1
                }label: {
                    HStack {
                        Spacer()
                        viewNumber == 1 ? Image(systemName: "pin.fill") : Image (systemName: "pin")
                        Text("저장한 장소")
                        Spacer()
                    }
                    .font(.pretendardRegular12)
                    .foregroundColor(viewNumber == 1 ? .privateColor : .primary)
                    .padding(.bottom, 15)
                    .padding([.trailing,.leading], 0)
                    .modifier(YellowBottomBorder(showBorder: viewNumber == 1))
                }
            }
            .padding(.top, 20)
            
            Divider()
                .background(Color.white)
                .padding(.top, -9)
            
            TabView(selection: $viewNumber) {
                MyHistoryView(root:$root, selection:$selection).tag(0)
                MySavedPlaceView().tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            Spacer()
               
        }
        .onAppear{
            Task {
                if userStore.user.email != "" {
                    await followStore.fetchFollowerFollowingList(userStore.user.email)
                }
                postCoordinator.checkIfLocationServicesIsEnabled()
                PostCoordinator.shared.myFeedList = userStore.myFeedList
                postCoordinator.makeOnlyMyFeedMarkers()
            }
        }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(root: .constant(true), selection: .constant(5)).environmentObject(UserStore())
    }
}
