//
//  FirebaseManager.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 05/03/2023.
//

/*
 This class is used to access Firebase services, inlcuding Authentication, Firestore and Storage.
 It initalises FirebaseApp and configures the services.
 This class prevents code repetition, by making it avaliable via FirebaseManager.
 
 This code has been reused from: https://www.youtube.com/watch?v=yHngqpFpVZU&t=1106s&ab_channel=LetsBuildThatApp
 */

import Foundation
import Firebase
import FirebaseStorage

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

