//
//  FirebaseManager.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 05/03/2023.
//

import Foundation
import Firebase
import FirebaseStorage

//Used to access Firebase
class FirebaseManager: NSObject {
    
    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    
    static let shared = FirebaseManager()
    
    override init (){
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
        
        super.init()
    }
}

