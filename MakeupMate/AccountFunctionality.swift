//
//  ObservableObjects.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 29/03/2023.
//

import Foundation

/*
  No code has been directly copied but has been adapted from the following tutorials
  
  To fetch the current user from Firestore: https://www.youtube.com/watch?v=yHngqpFpVZU&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=7&ab_channel=LetsBuildThatApp
  Sign out functionality: https://www.youtube.com/watch?v=NLOKRKvnHCo&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=8&ab_channel=LetsBuildThatApp

 */
class AccountFunctionalityViewModel: ObservableObject {
    
    @Published var currentUser: CurrentUser?
    @Published var errorMessage = ""
    
    @Published var isUserCurrentlyLoggedOut = false
    
    init() {
        /*If the user is logged out set the uid to nil,
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil } */
        fetchCurrentUser()
    }
    
    //Fetchs the currents users uid, and decodes the data from Firestore and places into currentUser
    func fetchCurrentUser(){
        // Retrives the uid from Firebase Auth and places into uid
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "fetchCurrentUser(): Could not find firebase uid"
            print(self.errorMessage)
            return }
        
        // Finds the uid in Firebase Firestore, then finds the document with its uid
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print(self.errorMessage)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                print(self.errorMessage)
                return }
            
            // places the data from the document into currentUser
            self.currentUser = .init(data: data)
        }
    }
    
    // Signs the user out, and updates the boolean value to true
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        print("Current user has been signed out")
    }
}
