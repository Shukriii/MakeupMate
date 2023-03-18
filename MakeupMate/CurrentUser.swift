//
//  ChatUser.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 06/03/2023.
//

/*
 This struct decodes a dictionary of data, and places them into variable to they can be easily accessed
 
 This code was reused from tutorial: https://www.youtube.com/watch?v=yHngqpFpVZU&t=1136s&ab_channel=LetsBuildThatApp
 */

import Foundation

struct CurrentUser {
    let uid, email: String
    
    //decoding the properties
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
    }
}
