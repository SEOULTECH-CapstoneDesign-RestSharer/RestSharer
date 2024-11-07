//
//  OtherProfileView.swift
//  RestSharer
//
//  Created by 변상우 on 6/23/24.
//

import SwiftUI

struct OtherProfileView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var feedStore: FeedStore
    @EnvironmentObject private var followStore: FollowStore
    
    @ObservedObject var postCoordinator: PostCoordinator = PostCoordinator.shared
    
    /// 각 버튼을 누르면 해당 화면을 보여주는 bool값
    @State var viewNumber: Int = 0
    @State var selection: Int = 1
    @State private var root: Bool = false
    @State private var isShowingReportForm: Bool = false
    @State private var isUserBlocked: Bool = false  // 차단 여부 확인
    
    let user:User
    
    var body: some View {
        NavigationStack {
            if userStore.blockedUsers.contains(user.nickname) {
                VStack {
                    Text("차단된 사용자입니다.")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                    Button("뒤로가기") {
                        dismiss()
                    }
                    .padding()
                }
            } else {
                VStack {
                    OtherInfoView(followerList: followStore.followerList, followingList: followStore.followingList, user: user)
                        .padding(.top,-20.0)
                        .padding(.bottom, 20)
                    HStack {
                        NavigationLink {
                            PostNaverMap(currentFeedId: $postCoordinator.currentFeedId, showMarkerDetailView: $postCoordinator.showMarkerDetailView, showMyMarkerDetailView: $postCoordinator.showMyMarkerDetailView, coord: $postCoordinator.coord, tappedLatLng: $postCoordinator.tappedLatLng)
                                .sheet(isPresented: $postCoordinator.showMyMarkerDetailView) {
                                    MapFeedSheetView(feed: feedStore.feedList.filter { $0.address == postCoordinator.currentFeedId })
                                        .presentationDetents([.height(.screenHeight * 0.55)])
                                }
                                .navigationBarBackButtonHidden(true)
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationTitle("\(user.nickname)님의 마커")
                                .backButtonArrow()
                        } label: {
                            HStack {
                                Image(systemName: "map")
                                    .foregroundStyle(Color.privateColor)
                                Text("\(user.nickname)님의 마커 보기")
                                    .font(.pretendardRegular14)
                            }
                            .padding()
                            .frame(width: .screenWidth*0.9)
                            .foregroundColor(.primary)
                        }
                        .frame(width: .screenWidth*0.9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.privateColor,lineWidth: 2)
                                .opacity(0.4)
                        )
                    }
                    
                    HStack {
                        Button {
                            viewNumber = 0
                        }label: {
                            HStack {
                                Spacer()
                                viewNumber == 0 ? Image( systemName: "location.fill") : Image (systemName: "location")
                                Text("피드")
                                Spacer()
                            }
                            .font(.pretendardRegular12)
                            .foregroundColor(viewNumber == 0 ? .privateColor : .primary)
                            //                    .frame(width: .screenWidth*0.3)
                            .padding(.bottom, 15)
                            .padding([.trailing,.leading], 0)
                            .modifier(YellowBottomBorder(showBorder: viewNumber == 0))
                        }
                        
                        Button {
                            viewNumber = 2
                        }label: {
                            HStack {
                                Spacer()
                                viewNumber == 2 ? Image(systemName: "pin.fill") : Image (systemName: "pin")
                                Text("저장한 장소")
                                Spacer()
                            }
                            .font(.pretendardRegular12)
                            .foregroundColor(viewNumber == 2 ? .privateColor : .primary)
                            //                    .frame(width: .screenWidth*0.3)
                            .padding(.bottom, 15)
                            .padding([.trailing,.leading], 0)
                            .modifier(YellowBottomBorder(showBorder: viewNumber == 2))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    Divider()
                        .background(Color.white)
                        .padding(.top, -9)
                    
                    TabView(selection: $viewNumber) {
                        OtherHistoryView(root:$root, selection:$selection, user:user).tag(0)
                        OtherSavedPlaceView(user: user).tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    Spacer()
                    
                }
                .navigationBarItems(trailing: Button(action: {
                    isShowingReportForm.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                        .foregroundColor(.primary)
                })
                .sheet(isPresented: $isShowingReportForm) {
                    VStack(spacing: 20) {
                        Text("차단하기")
                        
                        Text("이 사용자를 차단하시겠습니까?")

                        Button(role: .destructive, action: {
                            Task {
                                await userStore.blockUser(nickname: user.nickname)
                                
                                await userStore.fetchBlockedUsers()
                            }
                            isShowingReportForm.toggle()
                        }) {
                            Text("차단하기")
                                .font(.headline)
                                .foregroundStyle(Color.white)
                                .padding()
                                .frame(width: .screenWidth * 0.8, height: 50)
                                .background(Color.privateColor)
                                .cornerRadius(10)
                        }

                        Button("취소", role: .cancel) {
                            isShowingReportForm.toggle()
                        }
                            .frame(width: .screenWidth * 0.8, height: 50)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray)
                            )
                    }
                    .padding()
                    .presentationDetents([.height(.screenHeight * 0.3), .medium])
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("\(user.nickname)")
        .backButtonArrow()
        .onAppear{
            if userStore.blockedUsers.contains(user.nickname) {
                isUserBlocked = true
            } else {
                userStore.fetchotherUser(userEmail: user.email) { result in
                    if result {
                        postCoordinator.checkIfLocationServicesIsEnabled()
                        PostCoordinator.shared.myFeedList = userStore.otherFeedList
                        postCoordinator.makeOnlyMyFeedMarkers()
                        print("userStore.otherFeedList \(userStore.otherFeedList)")
                    }
                }
                Task {
                    await followStore.fetchFollowerFollowingList(user.email)
                }
            }
        }
    }
}
