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
    
    @ObservedObject private var vm = ViewModel(collectionName: "inventory")
    
    var body: some View {
        NavigationView {
            VStack {
                
                //delete later on, for testing purposes
                Text ("Current User ID: \(vm.currentUser?.email ?? "")")
                
                //topNavigationBar
                topNavigationBar(navigationName: "Your Inventory")
                    .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil){
                        LoginView(didCompleteLoginProcess: {
                            self.vm.isUserCurrentlyLoggedOut = false
                            self.vm.fetchCurrentUser()
                            self.vm.removeProducts()
                            self.vm.fetchProducts(fromCollection: "inventory")
                        })
                    }
                
                productListView
                
            }
            .overlay(
                newProductButton, alignment: .bottom)
            .navigationBarHidden(true)
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
        AddInventoryProductView() }
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

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InventoryView()
        }
    }
}
