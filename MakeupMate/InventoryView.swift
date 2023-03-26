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

// This struct calls topNavigationBar and productListView to populate the VStack, and has a button to add a new product. The variable vm calls the class InventoryViewModel, it has an overlay that adds a new product
struct InventoryView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = FetchFunctionalityViewModel(collectionName: "inventory")
    @ObservedObject private var am = AccountFunctionalityViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                //delete later on, for testing purposes
                Text ("Current User ID: \(am.currentUser?.email ?? "")")
                
                TopNavigationBar(navigationName: "Your Inventory")
                    .fullScreenCover(isPresented: $am.isUserCurrentlyLoggedOut, onDismiss: nil){
                        LoginView(didCompleteLoginProcess: {
                            self.am.isUserCurrentlyLoggedOut = false
                            self.am.fetchCurrentUser()
                            self.vm.removeProducts()
                            //self.vm.fetchProducts(fromCollection: "inventory")
                        })
                    }
                
                productListView
                
            }
            // An overlay of a HStack, which displays "New Product" which is a Navigation link to AddInventoryProductView
            .overlay(
                NavigationLink(destination: AddInventoryProductView()) {
                    HStack() {
                        Spacer()
                        Text ("New Product")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                    }.foregroundColor(.white)
                        .padding(.vertical)
                        .background(Color("Colour5"))
                        .cornerRadius(32)
                        .padding(.horizontal, 120)
                }, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    // Using vm it counts the number of products stored in Firestore and using a ForEach displays the product using ProductRow
    private var productListView: some View {
        ScrollView {
            ForEach(vm.products) { product in
                ProductRow(product: product)
            }.padding(.bottom, 50)
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

                NavigationLink(destination: EditInventoryProductView(productID: product.id)) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                    .foregroundColor(Color(.label)) }
    
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
