//
//  ChatUser.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 06/03/2023.
//

import Foundation

struct CurrentUser {
    let uid, email: String
    
    //decoding the properties
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
    }
}
