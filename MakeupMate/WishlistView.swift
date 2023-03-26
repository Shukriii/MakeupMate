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
    
    @ObservedObject private var vm = FetchFunctionalityViewModel(collectionName: "wishlist")
    @ObservedObject private var am = AccountFunctionalityViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                //delete later on, for testing purposes
                Text ("Current User ID: \(am.currentUser?.email ?? "")")
                
                //topNavigationBar
                TopNavigationBar(navigationName: "Your Wishlist")
                    .fullScreenCover(isPresented: $am.isUserCurrentlyLoggedOut, onDismiss: nil){
                        LoginView(didCompleteLoginProcess: {
                            self.am.isUserCurrentlyLoggedOut = false
                            self.am.fetchCurrentUser()
                            self.vm.removeProducts()
                            
                        })
                    }
                //self.vm.fetchProducts(fromCollection: "wishlist")
                productListView

            }
            // An overlay of a HStack, which displays "New Product" which is a Navigation link to AddWishlistProductView
            .overlay(
                NavigationLink(destination: AddWishlistProductView()) {
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

    private var productListView: some View {
        ScrollView {
            ForEach(vm.products) { product in
                WishlistRow(product: product)
            }.padding(.bottom, 50)
        }
    }
    
}


struct WishlistRow: View {
    
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

                NavigationLink(destination: EditWishlistProductView(productID: product.id)) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                    .foregroundColor(Color(.label)) }
    
            }
            Divider()
                .padding(.vertical, 2)
        }.padding(.horizontal)
    }
}

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        WishlistView()
    }
}
