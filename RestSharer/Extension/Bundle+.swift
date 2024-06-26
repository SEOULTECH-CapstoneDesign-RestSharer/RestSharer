//
//  Bundle+.swift
//  RestSharer
//
//  Created by 변상우 on 4/30/24.
//

import Foundation

extension Bundle {
    var naver_client_ID: String {
        guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["NClientID"] as? String else { fatalError("NClientID 설정 안됨") }
        
        return key
    }
    
    var naver_client_Secret: String {
        guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["NClientSecret"] as? String else { fatalError("NClientSecret 설정 안됨") }
        
        return key
    }
    
//    var publicHoliday_API_KEY: String {
//        guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }
//        
//        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
//        guard let key = resource["publicHoliday_API_KEY"] as? String else { fatalError("publicHoliday_API_KEY error") }
//        
//        return key
//    }

    var naverMap_client_ID: String {
        guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["NMFClientId"] as? String else { fatalError("NMFClientId 설정 안됨") }
        
        return key
    }
    
    var naverMap_client_Secret: String {
        guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["NMFClientSecret"] as? String else { fatalError("NMFClientSecret 설정 안됨") }
        
        return key
    }
    
//    var payment_Client_KEY: String {
//        guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }
//        
//        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
//        guard let key = resource["payment_Client_KEY"] as? String else { fatalError("payment_Client_KEY 설정 안됨") }
//        
//        return key
//    }
//    
}
