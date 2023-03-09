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

// Creating constants which ProductDetails uses
struct FirebaseConstants {
    static let uid = "uid"
    static let name = "name"
    static let brand = "brand"
    static let category = "category"
    static let shade = "shade"
    static let stock = "stock"
    static let expiryDate = "expiryDate"
    static let note = "note"
}

// Decodes the data retrieved from Firestore and places them into variables
struct ProductDetails: Identifiable {
    
    var id: String { documentID }
    
    let documentID: String
    
    let uid, name, brand, category, shade, stock, expiryDate, note: String
    
    init(documentID: String, data: [String: Any]){
        self.documentID = documentID
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.name = data[FirebaseConstants.name] as? String ?? ""
        self.brand = data[FirebaseConstants.brand] as? String ?? ""
        self.category = data[FirebaseConstants.category] as? String ?? ""
        self.shade = data[FirebaseConstants.shade] as? String ?? ""
        self.stock = data[FirebaseConstants.stock] as? String ?? ""
        self.expiryDate = data[FirebaseConstants.expiryDate] as? String ?? ""
        self.note = data[FirebaseConstants.note] as? String ?? ""
    }
}

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
        // If the user is logged out set the uid to nil,
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
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
                
                // adds products to view when they are added
                querySnapshot?.documentChanges.forEach( { change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.products.append(.init(documentID: change.document.documentID, data: data))
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
                // TODO: add function to clear inventory products before fetching them again
                self.vm.fetchAllInventoryProducts()
            })
        }
    }
    
    // LISTING OF PRODUCTS
    private var productListView: some View {
        ScrollView {
            // TODO: when categroies are added, edit how items are displayed - Main Product
            ForEach(vm.products) { product in
                VStack{
                    HStack {
                        // TODO: add photo for product
                        Image(systemName: "photo").font(.system(size:30))
                        // Video 6, 25 minutes
                        //WebImage(url: URL(string: )).resizeable()
                        
                        VStack (alignment: .leading){
                            Text(product.name)
                                .font(.system(size: 17, weight: .semibold))
                            Text(product.shade)
                                .foregroundColor(Color(.lightGray))
                            Text(product.brand)
                        }

                        Spacer ()
                        
                        // TODO: add edit button functionality
                        Button{
                            
                        } label: {
                            Image(systemName: "square.and.pencil") // change icon
                                .font(.system(size: 20))
                                .foregroundColor(Color(.label))
                        }
                        
                    }
                    Divider()
                        .padding(.vertical, 2)
                }.padding(.horizontal)
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


struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InventoryView()
        }
    }
}
