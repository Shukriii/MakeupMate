//
//  WishlistView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 21/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI

// Logout only works on InventoryView 
struct WishlistView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = ViewModel(collectionName: "wishlist")
    
    var body: some View {
        NavigationView {
            VStack {
                
                //delete later on, for testing purposes
                Text ("Current User ID: \(vm.currentUser?.email ?? "")")
                
                //topNavigationBar
                topNavigationBar(navigationName: "Your Wishlist")
                    .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil){
                        LoginView(didCompleteLoginProcess: {
                            self.vm.isUserCurrentlyLoggedOut = false
                            self.vm.fetchCurrentUser()
                            self.vm.removeProducts()
                            self.vm.fetchProducts(fromCollection: "wishlist")
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
    
    //This function is called by the overlay and displays a button to allow users to add a product. A full screen over is presented that calls AddWishlistProductView()
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
        AddWishlistProductView() }
    }
    
    private var productListView: some View {
        ScrollView {
            ForEach(vm.products) { product in
                ProductRow(product: product)
            }.padding(.bottom, 50)
        }
    }
    
}

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        WishlistView()
    }
}
