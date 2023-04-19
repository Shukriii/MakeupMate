//
//  CategoryFunctionality.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 19/04/2023.
//

import Foundation
import SwiftUI

class CategoryFunctionalityViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var statusMessage = ""
    @Published var products = [ProductDetails]()
   
    func fetchProducts(fromCollection collectionName: String){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
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
}
