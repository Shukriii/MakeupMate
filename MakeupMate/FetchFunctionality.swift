//
//  FetchFunctionality.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 26/03/2023.
//

/*
 
 This observable object is used to populate the Inventory and Wishlist views, the instance of the object updates when a products is added, deleted or edited. CategoryView uses this OO to check if a category has products in it before deleting it.
 
  No code has been copied directly, but the querySnapshot used in fetchProduct function has been addpated from this tutorial: https://www.letsbuildthatapp.com/videos/7874
 */

import Foundation

class FetchFunctionalityViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var products = [ProductDetails]()
    
    // the object instance automatically users fetchProducts
    init(collectionName: String) {
        fetchProducts(fromCollection: collectionName)
    }
    
    // Provided with a parameter collectName, to know which collection to access. Uses querySnapshot to fetch all the products and listen for chnages of type added, deleted or modified.
    // querySnapshot listens for documents changes and updates the product array as appropirate
    func fetchProducts(fromCollection collectionName: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "fetchProducts(): Could not find firebase uid"
            print ("fetchProducts(): Could not find firebase uid")
            return
        }
        
        //uses the uid and collection name to access the collection
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

    // Is called after a user logs out to clear the Inventory
    func removeProducts(){
        self.products = []
        print("Previous products removed from view")
    }
    
}
