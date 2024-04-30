//
//  User.swift
//  RestSharer
//
//  Created by 변상우 on 4/30/24.
//

import Foundation

import Firebase

struct User {
    let id: String = UUID().uuidString
    let email: String
    var name: String
}
