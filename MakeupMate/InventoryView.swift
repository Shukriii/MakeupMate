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
 
   No code has been copied directly, the code has been adapted from the following tutorials
   Video 1 - Creating inventory view: https://www.youtube.com/watch?v=pPsKTTd55xI&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=6&ab_channel=LetsBuildThatApp
   Video 2 - To fetch the current user from Firestore: https://www.youtube.com/watch?v=yHngqpFpVZU&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=7&ab_channel=LetsBuildThatApp
   Video 3 - Log in and log out: https://www.youtube.com/watch?v=NLOKRKvnHCo&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=8&ab_channel=LetsBuildThatApp
   Video 4 - Fetch inventory products from Firestore: https://www.youtube.com/watch?v=G0AyApE2w1c&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=13&ab_channel=LetsBuildThatApp
 */


import SwiftUI
import SDWebImageSwiftUI


// Class with 4 functions
// fetchCurrentUser() - fetchs the current user
// fetchAllInventoryProducts() - fetchs the inventory products of the current user
// handleSignOut() - Uses firebase Auth to sign current user out
// removeInventoryProduct() - Removes inventory products from the view
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
    
    // 
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
    func removeInventoryProduct(){
        self.products = []
        print("Previous products removed from view")
    }
}

// This struct calls topNavigationBar and productListView to populate the VStack, and has a button to add a new product. The variable vm calls the class InventoryViewModel, it has an overlay that adds a new product
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
    
    // Displays title of view and a button to logout, it also uses the boolean isUserCurrentlyLoggedOut to check wether the user is logged in. If not it uses the closure didCompleteLoginProcess to all the functions to populate the view.
    // Adapted from Video 1
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
        // Adapted from Video 3
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
    
    // Using vm it counts the number of products stored in Firestore and using a ForEach displays the product using ProductRow
    private var productListView: some View {
        ScrollView {
            // TODO: when categroies are added, edit how items are displayed - Main Product
            ForEach(vm.products) { product in
                ProductRow(product: product)
            }.padding(.bottom, 50)
            
        }
    }
    
    @State var shouldShowAddProductScreen = false
    
    //This function is called by the overlay and displays a button to allow users to add a product. A full screen over is presented that calls AddInventoryProductView()
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
        .padding(.horizontal, 120)
    }.fullScreenCover(isPresented: $shouldShowAddProductScreen){
        AddInventoryProductView()
    }
    }
}

// This struct is passed a product which is a list, and using the ProductDetails struct it uses a variable to access the data. Is displays the product image, along with product name, shade and brand if avaliable. It has an Edit icon which redirects the user to EditView
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
