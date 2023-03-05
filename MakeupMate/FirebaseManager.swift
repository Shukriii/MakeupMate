//
//  FirebaseManager.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 05/03/2023.
//

import Foundation
import Firebase

// to stop preview crashing, the Firebase config is placed into a class
// used to access Firebase
class FirebaseManager: NSObject {
    
    let auth: Auth
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init (){
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        super.init()
    }
}

