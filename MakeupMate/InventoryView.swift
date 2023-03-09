//
//  InventoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 04/03/2023.
//

// INVENTORY VIEW
// DISPLAYS ALL INVENTORY ITEMS THAT BELONG TO USER

import SwiftUI
import SDWebImageSwiftUI

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

// CLASS WHICH FETCHES CURRENT USER AND PRODUCTS
class InventoryViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    //@Published var loggedInUser: CurrentUser?
    //@Published var inventoryProducts: InventoryProducts?
    @Published var products = [ProductDetails]()
    
    init(){
        //uncomment later, this is functionality to sign in after logging out
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        fetchAllInventoryProducts()
    }
    
    private func fetchAllInventoryProducts() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return } //fetch uid
        
        FirebaseManager.shared.firestore
            .collection("products")
            .document(uid)
            .collection("inventory")
            .order(by: "name") //Need to order using category then product name
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch inventory product: \(error)"
                    print("Failed to fetch inventory product: \(error)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach( { change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.products.append(.init(documentID: change.document.documentID, data: data))
                    }
                })
                
                /*
                querySnapshot?.documents.forEach({ queryDocumentSnapshot in
                    let data = queryDocumentSnapshot.data()
                    let docID = queryDocumentSnapshot.documentID
                    self.products.append(.init(documentID: docID, data: data))
            }) */
            self.errorMessage = "Fetched products successfully"
        }
        
    }
    
    //fetchs the users id from sign using auth
    func fetchCurrentUser(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else {
            self.errorMessage = "Could not find firebase uid"
            return }
        
        //fetching the user from firestore users collection
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return }
            
            self.chatUser = .init(data: data)
            //self.loggedInUser = .init(data: data)
        }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct InventoryView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = InventoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                //delete later on, for testing purposes
                Text ("Current User ID: \(vm.chatUser?.email ?? "")")

                topNavigationBar
                
                productListView
    
            }
            .overlay(
                newProductButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    // TOP NAVIGATION BAR
    private var topNavigationBar: some View {
        HStack{
            
            Text("Your Inventory")
                .font(.system(size: 24, weight: .bold))
            Spacer()
            
            // profile icon button
            Button{
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "person")
                    .font(.system(size: 30))
                    .foregroundColor(Color("Colour5"))
            }
        }
        .padding()
        //pop up when person is clicked
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text ("Settings"),
                  message: Text("Are you sure you want to sign out?"),
                  buttons: [.destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                vm.handleSignOut()
            }),
                            .cancel()])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil){
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    // LISTING OF PRODUCTS
    private var productListView: some View {
        ScrollView {
            /*
            ForEach(vm.products) { product in
                Text(product.name)
                
            } */
            // when catgroies are added do for each stuff here
            ForEach(vm.products) { product in
                //Text(product.uid)
                VStack{
                    HStack {
                        //Photo for product
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
                        
                        // EDIT BUTTON
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
                //.background(Color.purple)
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
