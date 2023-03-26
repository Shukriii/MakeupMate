//
//  AccountFunctionality.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

import Foundation

// fetchCurrentUser() - fetchs the current user
// handleSignOut() - Uses firebase Auth to sign current user out

// TODO: - LoginView only appears when on InventoryView

class AccountFunctionalityViewModel: ObservableObject {
    
    @Published var currentUser: CurrentUser?
    @Published var errorMessage = ""
    
    @Published var isUserCurrentlyLoggedOut = false
    
    init() {
        /* If the user is logged out set the uid to nil,
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil } */
        fetchCurrentUser()
    }
    
    //Fetchs the currents users uid, and decodes the data from Firestore and places into currentUser
    // Adapted from Video 2
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
            
            // places the data from the document into currenUser
            self.currentUser = .init(data: data)
        }
    }
    
    // Adapted from Video 3
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        print("Current user has been signed out")
    }
}
