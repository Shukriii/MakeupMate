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
// fetchCurrentUser() - fetchs the current user
// fetchAllInventoryProducts() - fetchs the inventory products of the current user
// handleSignOut() - Uses firebase Auth to sign current user out
// removeInventoryProduct() - Removes inventory products from the view
class ViewModel: ObservableObject {
    
    @Published var currentUser: CurrentUser?
    @Published var errorMessage = ""
    @Published var products = [ProductDetails]()
    @Published var isUserCurrentlyLoggedOut = false
    @State var whichEdit: Bool = false
    
    init(collectionName: String) {
        // If the user is logged out set the uid to nil,
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil }
        
        fetchCurrentUser()
        fetchProducts(fromCollection: collectionName)
    }
    
    // Fetchs the currents users uid, and decodes the data from Firestore and places into currentUser
    // Adapted from Video 2
    func fetchCurrentUser(){
        // Retrives the uid from Firebase Auth and places into uid
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "fetchCurrentUser(): Could not find firebase uid"
            print("fetchCurrentUser(): Could not find firebase uid")
            return }
        
        // Finds the uid in Firebase Firestore, then finds the document with its uid
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                print("No data found")
                return }
            
            // places the data from the document into currenUser
            self.currentUser = .init(data: data)
        }
    }
    
    func fetchProducts(fromCollection collectionName: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "fetchProducts(): Could not find firebase uid"
            print ("fetchProducts(): Could not find firebase uid")
            return }
        
        if collectionName == "inventory" {
            whichEdit = true
        }
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection(collectionName)
            .order(by: "name")
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch product: \(error)"
                    print("Failed to fetch product: \(error)")
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
            }
    }
    
    // Adapted from Video 3
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        print("Current user has been signed out")
    }
    
    // Is called after a user logs out to clear the Inventory
    func removeProducts(){
        self.products = []
        print("Previous products removed from view")
    }
    
}



// This struct is passed a product which is a list, and using the ProductDetails struct it uses a variable to access the data. Is displays the product image, along with product name, shade and brand if avaliable. It has an Edit icon which redirects the user to EditView



struct ProductRow: View {
    
    let product: ProductDetails
    
    @ObservedObject private var vm = ViewModel(collectionName: "inventory")
    
    var body: some View {
        VStack{
            HStack {
                
                if !product.image.isEmpty {
                    WebImage(url: URL(string: product.image))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipped()
                } else {
                    Image(systemName: "photo").font(.system(size:30))
                }

                VStack (alignment: .leading){
                    Text(product.name)
                        .font(.system(size: 17, weight: .semibold))
                    Text(product.shade)
                        .foregroundColor(Color(.lightGray))
                    Text(product.brand)
                }
                Spacer ()

                /*
                NavigationLink(destination: vm.whichEdit ? EditInventoryProductView(productID: product.id) : EditWishlistProductView()) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                    .foregroundColor(Color(.label)) }
                
                
                
                NavigationLink(destination: EditInventoryProductView(productID: product.id)) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                    .foregroundColor(Color(.label)) } */
    
            }
            Divider()
                .padding(.vertical, 2)
        }.padding(.horizontal)
    }
}
