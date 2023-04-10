//
//  CompareView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 26/03/2023.
//

/*
  This view fetches all the categories for the user to chose from, once pciked it displays the products that are associated to the category
 
  No code has been copied directly but the auhtor adpated code form the follloing tutorials:
  dropdown - https://www.youtube.com/watch?v=0LrP6dv8tHY&ab_channel=JamesHaville
  delete mehtod learnt from - https://www.youtube.com/watch?v=2g1t15bwX44&ab_channel=PaulHudson
 */

import SwiftUI
import SDWebImageSwiftUI

struct CompareView: View {
    
    @State private var isExpanded = false
    @State private var selectedCategory = ""
    @State private var statusMessage = ""
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var am = AccountFunctionalityViewModel()
    @ObservedObject private var af = AddFunctionalityViewModel()
    
    @State private var categories = [CategoryDetails]()
    @State private var category: CategoryDetails?
    
    @State private var inventoryProducts = [ProductDetails]()
    @State private var wishlistProducts = [ProductDetails]()
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading, spacing: 15){
                
                TopNavigationBar(navigationName: "Compare")
                    .fullScreenCover(isPresented: $am.isUserCurrentlyLoggedOut, onDismiss: nil){
                        LoginView(didCompleteLoginProcess: {
                            self.am.isUserCurrentlyLoggedOut = false
                        })
                    }.padding(.vertical)
                
                displayView
                
            }.navigationBarHidden(true)
        }
    }
    
    private var displayView: some View {
        ScrollView {
            VStack {
                Text("Select a category below").padding()
                
                // The dropdown which uses fetches the categories and displays them, uses selectedCategory to store the category chosen byt the user)
                DisclosureGroup("\(selectedCategory)", isExpanded: $isExpanded) {
                    ScrollView {
                        VStack {
                            ForEach(af.categories) { category in
                                Text("\(category.categoryName)")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .onTapGesture {
                                        self.selectedCategory = category.categoryName //The category picked name
                                        withAnimation {
                                            self.isExpanded .toggle()
                                            fetchCategoryProducts()
                                            findCategoryInventoryProducts()
                                            findCategoryWishlistProducts()
                                        }
                                    }
                            }
                        }
                    }.frame(minHeight: 0, maxHeight: 180)
                }
                .padding()
                .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                .cornerRadius(8)
                
            }
            .padding(.horizontal)
            
            HStack{
                ProductListing(columnTitle: "Inventory", productType: $inventoryProducts)
                    .frame(width: 190)
                Divider()
                ProductListing(columnTitle: "Wishlist", productType: $wishlistProducts)
                    .frame(width: 190)
            }
            .padding()
        }
    }
    
    private func fetchCategoryProducts() {
        FirebaseManager.shared.firestore.collection("categories").getDocuments { documentsSnapshot,
            error in
            if let error = error {
                self.statusMessage = "Failed to fetch inventory product: \(error)"
                print(statusMessage)
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                print("data")
                self.categories.append(.init(documentID: snapshot.documentID, data: data))
                print(categories)
            })
            self.statusMessage = "Fetched products successfully"
            print(statusMessage)
            
        }
    }
    
    // This function places all the inventory categories into an array that have the same category as selectedCategory
    private func findCategoryInventoryProducts(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection("inventory")
            .order(by: "name")
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.statusMessage = "Failed to fetch product: \(error)"
                    print(self.statusMessage)
                    return
                }
                
                // The snapshot listener querySnapshot listens for changes
                querySnapshot?.documentChanges.forEach( { change in
                    // if a product is added
                    if change.type == .added {
                        let data = change.document.data()
                        self.inventoryProducts.append(.init(documentID: change.document.documentID, data: data))
                    }
                    //if product is deleted
                    if change.type == .removed {
                        if let index = self.inventoryProducts.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            self.inventoryProducts.remove(at: index)
                        }
                    }
                    // if a product is modified
                    if change.type == .modified {
                        if let index = self.inventoryProducts.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            let data = change.document.data()
                            self.inventoryProducts[index] = .init(documentID:change.document.documentID, data: data)
                        }
                    }
                })
                self.statusMessage = "Fetched products successfully"
                print (self.statusMessage)
                
                for product in self.inventoryProducts {
                    if product.category != self.selectedCategory {
                        if let index = self.inventoryProducts.firstIndex(where: { $0.documentID == product.documentID }) {
                            self.inventoryProducts.remove(at: index)
                            
                        }
                    }
                }
                
            }
    }
    
    // This function places all the wishlist categories into an array that have the same category as selectedCategory
    private func findCategoryWishlistProducts(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection("wishlist")
            .order(by: "name")
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.statusMessage = "Failed to fetch product: \(error)"
                    print(self.statusMessage)
                    return
                }
                
                // The snapshot listener querySnapshot listens for changes
                querySnapshot?.documentChanges.forEach( { change in
                    // if a product is added
                    if change.type == .added {
                        let data = change.document.data()
                        self.wishlistProducts.append(.init(documentID: change.document.documentID, data: data))
                    }
                    //if product is deleted
                    if change.type == .removed {
                        if let index = self.wishlistProducts.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            self.wishlistProducts.remove(at: index)
                        }
                    }
                    // if a product is modified
                    if change.type == .modified {
                        if let index = self.wishlistProducts.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            let data = change.document.data()
                            self.wishlistProducts[index] = .init(documentID:change.document.documentID, data: data)
                        }
                    }
                })
                self.statusMessage = "Fetched products successfully"
                print (self.statusMessage)
                
                print("original Products: \(wishlistProducts)")
                
                for product in self.wishlistProducts {
                    if product.category != self.selectedCategory {
                        if let index = self.wishlistProducts.firstIndex(where: { $0.documentID == product.documentID }) {
                            self.wishlistProducts.remove(at: index)
                            
                        }
                    }
                }
                
                print("wishlistProducts: \(wishlistProducts)")
            }
    }
}

// This view is used to display the products 
struct ProductListing: View {
    
    var columnTitle: String
    @Binding var productType: [ProductDetails]
    
    var body: some View {
        VStack {
            Text(columnTitle)
                .font(.system(size: 20, weight: .bold))
            ScrollView {
                VStack {
                    ForEach (productType) { product in
                        HStack {
                            if !product.image.isEmpty {
                                WebImage(url: URL(string: product.image))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
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
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
        }
    }
}

struct CompareView_Previews: PreviewProvider {
    static var previews: some View {
        CompareView()
    }
}
