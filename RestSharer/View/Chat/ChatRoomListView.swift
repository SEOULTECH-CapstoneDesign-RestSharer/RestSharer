//
//  ChatRoomListView.swift
//  RestSharer
//
//  Created by 변상우 on 8/7/24.
//

import SwiftUI
import SendBirdUIKit

struct ChatRoomListView: View {
    init() {
        // 1. Initialize Sendbird UIKit
        SBUMain.initialize(applicationId:"D1E6401F-DB5B-4702-A3FB-E5F46D78D2D2")
        // 2. Set the current user
        SBUGlobals.CurrentUser = SBUUser(userId: "tkddn123987")
        // 3. Connect to Sendbird
        SBUMain.connect { (user, error) in
            // user object will be an instance of SBDUser
            guard let _ = user else {
                print("ContentView: init: Sendbird connect: ERROR: \(String(describing: error)). Check applicationId")
                return
            }
        }
    }
    var body: some View {
        // 4. Call up the custom Channel List
        ChatRoomListViewContainer()
    }
}
