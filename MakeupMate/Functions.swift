//
//  Functions.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 22/03/2023.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

// Class with 4 functions
// fetchAllInventoryProducts() - fetchs the inventory products of the current user
// removeInventoryProduct() - Removes inventory products from the view
class ViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var products = [ProductDetails]()
    @Published var categories = [CategoryDetails]()
    
    init(collectionName: String) {
        fetchProducts(fromCollection: collectionName)
        fetchCategories()
    }
    
    func fetchProducts(fromCollection collectionName: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "fetchProducts(): Could not find firebase uid"
            print ("fetchProducts(): Could not find firebase uid")
            return
        }
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection(collectionName)
            .order(by: "name")
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch product: \(error)"
                    print(self.errorMessage)
                    return
                }
                
                // The snapshot listener querySnapshot listens for changes
                querySnapshot?.documentChanges.forEach( { change in
                    // if a product is added
                    if change.type == .added {
                        let data = change.document.data()
                        self.products.append(.init(documentID: change.document.documentID, data: data))
                    }
                    //if product is deleted
                    if change.type == .removed {
                        if let index = self.products.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            self.products.remove(at: index)
                        }
                    }
                    // if a product is modified
                    if change.type == .modified {
                        if let index = self.products.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            let data = change.document.data()
                            self.products[index] = .init(documentID:change.document.documentID, data: data)
                            }
                        }
                })
                self.errorMessage = "Fetched products successfully"
                print (self.errorMessage)
                return
            }
    }
    
    func fetchCategories() {
        FirebaseManager.shared.firestore.collection("categories")
            .order(by: "Name")
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch category: \(error)"
                    print("Failed to fetch category: \(error)")
                    return
                }
                
                // The snapshot listener querySnapshot listens for changes
                querySnapshot?.documentChanges.forEach( { change in
                    // if a product is added
                    if change.type == .added {
                        let data = change.document.data()
                        self.categories.append(.init(documentID: change.document.documentID, data: data))
                    }
                })
                self.errorMessage = "Fetched categories successfully"
                print (self.errorMessage)
                
            }
    }

    // Is called after a user logs out to clear the Inventory
    func removeProducts(){
        self.products = []
        print("Previous products removed from view")
    }
    
}




