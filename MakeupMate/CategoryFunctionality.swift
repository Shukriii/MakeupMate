//
//  CategoryFunctionality.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 23/04/2023.
//

/*
  This OO is initalised with fetchCategories which is used by Inventory and Wishlist views to display the products according to their category.
 
  The display message is used by CategoryView to display an alert when the user tries to delete a category that has  products, or to tries to add a product with no name or category.
 
  querySnapshot adapted from - https://www.letsbuildthatapp.com/videos/7874
  code for displayMessage adpated from - https://www.youtube.com/watch?v=NJDBb4sOfNE&ab_channel=Kavsoft
 */

import Foundation
import SwiftUI

class CategoryFunctionalityViewModel: ObservableObject {
    
    @Published var statusMessage = ""
    @Published var categories = [CategoryDetails]()
    
    // The instance of this object automatically calls fetchCategories
    init(){
        fetchCategories()
    }
    
    //
    func fetchCategories() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("categories").document(uid).collection("categories")
            .order(by: "name")
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.statusMessage = "Failed to fetch category: \(error)"
                    print("Failed to fetch category: \(error)")
                    return
                }
                
                // The snapshot listener querySnapshot listens for changes
                querySnapshot?.documentChanges.forEach( { change in
                    // if a category is added
                    if change.type == .added {
                        let data = change.document.data()
                        self.categories.append(.init(documentID: change.document.documentID, data: data))
                    }
                    //if a category is deleted
                    if change.type == .removed {
                        if let index = self.categories.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            self.categories.remove(at: index)
                        }
                    }
                    // if a product is modified
                    if change.type == .modified {
                        if let index = self.categories.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            let data = change.document.data()
                            self.categories[index] = .init(documentID:change.document.documentID, data: data)
                            }
                        }
                })
                self.statusMessage = "Fetched categories successfully"
                //print (self.statusMessage)
                
            }
    }
    
    // parametised with title and message so the alert can be reused
    func displayMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
        
        // The dismiss button
        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (_) in
        }
        
        alert.addAction(dismiss)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
        })
    }
    
    
    
}
