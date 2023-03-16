//
//  InventoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 04/03/2023.
//

/* Once the walkthrough is complete this is the next view displayed.
   If the user is not logged in, a fullScreenCover of LoginView will appear (line 189)
 
   This view let users:
        - See all the products in their inventory
        - Log out (calls LoginView)
        - Add an inventory product (calls AddInventoryProductView)
   This code was inspired by the following tutorials
   Creating inventory view: https://www.youtube.com/watch?v=pPsKTTd55xI&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=6&ab_channel=LetsBuildThatApp
   To fetch the current user from Firestore: https://www.youtube.com/watch?v=yHngqpFpVZU&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=7&ab_channel=LetsBuildThatApp
   Log in and log out: https://www.youtube.com/watch?v=NLOKRKvnHCo&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=8&ab_channel=LetsBuildThatApp
   Fetch inventory products from Firestore: https://www.youtube.com/watch?v=G0AyApE2w1c&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=13&ab_channel=LetsBuildThatApp
 */


import SwiftUI
import SDWebImageSwiftUI


// Class with 3 functions
// fetchCurrentUser() - fetchs the current user
// fetchAllInventoryProducts() - fetchs the inventory products of the current user
// handleSignOut() - Uses firebase Auth to sign current user out
class InventoryViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var currentUser: CurrentUser?
    @Published var products = [ProductDetails]()
    @Published var isUserCurrentlyLoggedOut = false
    
    init(){
        /* If the user is logged out set the uid to nil,
         DispatchQueue.main.async {
         self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
         } */
        
        fetchCurrentUser()
        fetchAllInventoryProducts()
    }
    
    // Fetchs the currents users id
    func fetchCurrentUser(){
        // Retrives the uid from Firebase Auth and places into uid
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "fetchCurrentUser(): Could not find firebase uid"
            print("fetchCurrentUser(): Could not find firebase uid")
            return }
        
        // Finds the uid in Firebase Firestore
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
            
            // places the data in the current user
            self.currentUser = .init(data: data)
        }
    }
    
    func fetchAllInventoryProducts() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "fetchAllInventoryProducts(): Could not find firebase uid"
            print ("fetchAllInventoryProducts(): Could not find firebase uid")
            return }
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection("inventory")
            .order(by: "name") //Need to order using category then product name
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch inventory product: \(error)"
                    print("Failed to fetch inventory product: \(error)")
                    return
                }
                
                // changes product view
                querySnapshot?.documentChanges.forEach( { change in
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
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        print("Current user has been signed out")
    }
    
    func removeInventoryProduct(){
        self.products = []
        print("Previous products removed from view")
    }
}

struct InventoryView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = InventoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                //delete later on, for testing purposes
                Text ("Current User ID: \(vm.currentUser?.email ?? "")")
                
                topNavigationBar
                
                productListView
                
            }
            .overlay(
                newProductButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    // Includes pop up to log out
    private var topNavigationBar: some View {
        HStack{
            
            Text("Your Inventory")
                .font(.system(size: 24, weight: .bold))
            Spacer()
            
            // Profile icon button, which allows users to log out
            Button{
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "person")
                    .font(.system(size: 30))
                    .foregroundColor(Color("Colour5"))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text ("Settings"),
                  message: Text("Are you sure you want to sign out?"),
                  buttons: [.destructive(Text("Sign Out"), action: {
                vm.handleSignOut()
            }),
                            .cancel()])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil){
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
                self.vm.removeInventoryProduct()
                self.vm.fetchAllInventoryProducts()
            })
        }
    }
    
    //LISTING OF PRODUCTS
    private var productListView: some View {
        ScrollView {
            // TODO: when categroies are added, edit how items are displayed - Main Product
            ForEach(vm.products) { product in
                ProductRow(product: product)
            }.padding(.bottom, 50)
            
        }
    }
    
    @State var shouldShowAddProductScreen = false
    
    //NEW PRODUCT BUTTON
    private var newProductButton: some View {
        Button {
            shouldShowAddProductScreen.toggle()
        }
    label: {
        HStack() {
            Spacer()
            Text ("New Product")
                .font(.system(size: 16, weight: .bold))
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.vertical)
        .background(Color("Colour5"))
        .cornerRadius(32)
        .padding(.horizontal, 100)
    }.fullScreenCover(isPresented: $shouldShowAddProductScreen){
        AddInventoryProductView()
    }
    }
    
}

struct ProductRow: View {
    
    let product: ProductDetails
    
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
                
                NavigationLink(destination: EditView(productID: product.id, productImage: product.image)) {
                    //Text("Edit")
                    Image(systemName: "square.and.pencil") // change icon
                        .font(.system(size: 20))
                    .foregroundColor(Color(.label)) }
                
                /*
                NavigationLink(destination: EditInventoryProductView(productID: product.id, productName: product.name, productBrand: product.brand, productShade: product.shade, productStock: product.stock, productNote: product.note, productImage: product.image)) {
                    //Text("Edit")
                    Image(systemName: "square.and.pencil") // change icon
                        .font(.system(size: 20))
                    .foregroundColor(Color(.label)) } */
                
            }
            Divider()
                .padding(.vertical, 2)
        }.padding(.horizontal)
    }
}
struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InventoryView()
        }
    }
}
