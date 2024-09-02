//
//  ChatRoomListViewController.swift
//  RestSharer
//
//  Created by 변상우 on 8/7/24.
//

import UIKit
import SwiftUI
import SendBirdUIKit

class ChatRoomListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.navigationController?.isNavigationBarHidden = true
        
        // SBUChannelListViewController를 바로 추가합니다.
        let clvc = SBUChannelListViewController()
        addChild(clvc)
        clvc.view.frame = view.bounds
        view.addSubview(clvc.view)
        clvc.didMove(toParent: self)
    }

//    @objc
//    func displaySendbirdChanelList(){
//        let clvc = SBUChannelListViewController()
//        let navc = UINavigationController(rootViewController: clvc)
//        navc.title = "Sendbird SwiftUI Demo"
//        navc.modalPresentationStyle = .fullScreen
//        present(navc, animated: true)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        let clvc = SBUChannelListViewController()
//        self.navigationController?.pushViewController(clvc, animated: true)
//    }
}

struct ChatRoomListViewContainer: UIViewControllerRepresentable {
    // 4a. Set the typealias to the class in step 3
    typealias UIViewControllerType = ChatRoomListViewController
    // 4b. Have the makeUIViewController return an instance of the class from step 3
    func makeUIViewController(context: Context) -> ChatRoomListViewController {
        return ChatRoomListViewController()
    }
    // 4c. Add the required updateUIViewController function
    func updateUIViewController(_ uiViewController: ChatRoomListViewController, context: Context) {
    }
}
