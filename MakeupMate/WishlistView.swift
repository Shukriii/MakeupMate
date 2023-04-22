//
//  WishlistView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 21/03/2023.
//

/*
 Code has been adapted from InvenotryView, displays the users Wishlist products
 */

import SwiftUI
import SDWebImageSwiftUI

// Logout only works on InventoryView 
struct WishlistView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var productsForCategory = [ProductDetails]()
    
    @ObservedObject private var vm = FetchFunctionalityViewModel(collectionName: "wishlist")
    @ObservedObject private var am = AccountFunctionalityViewModel()
    @ObservedObject private var af = AddFunctionalityViewModel()
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack (spacing: 15) {
                
                TopNavigationBar(navigationName: "Your Wishlist")
                    .fullScreenCover(isPresented: $am.isUserCurrentlyLoggedOut, onDismiss: nil){
                        LoginView(didCompleteLoginProcess: {
                            self.am.isUserCurrentlyLoggedOut = false
                            self.am.fetchCurrentUser()
                            self.vm.removeProducts()
                            self.vm.fetchProducts(fromCollection: "wishlist")
                            self.af.fetchCategories()
                        })
                    }
                
                SearchBarView(searchText: $searchText)
                    .frame(width: 370, height: 10, alignment: .center)
                    .padding()
                
                VStack {
                    ScrollView {
                        if searchText == "" {
                            VStack {
                                ForEach(af.categories) { category in
                                    let hasProducts = vm.products.contains(where: { $0.category == category.categoryName })
                                    
                                    let productsForCategory = vm.products.filter { $0.category == category.categoryName }
                                    
                                    // if the category has products
                                    if hasProducts {
                                        WishlistCategoryRow(category: category, categoryProducts: productsForCategory) }
                                }
                            }
                            .padding(.bottom, 50)
                        } else {
                            VStack {
                                ForEach(arrayOfProducts) { product in
                                    WishlistRow(product: product)
                                }
                            }
                            .padding(.bottom, 50)
                        }
                    }
                }
            }
            // An overlay of a HStack, which displays "New Product" which is a Navigation link to AddWishlistProductView
            .overlay(
                NavigationLink(destination: NewAddWishlistProductView()) {
                    HStack() {
                        Spacer()
                        Text ("New Product")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                    }.foregroundColor(.white)
                        .padding(.vertical)
                        .background(Color("Colour5"))
                        .cornerRadius(32)
                        .frame(width: 170)
                }, alignment: .bottom)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
    
    var arrayOfProducts: [ProductDetails] {
        return searchText == "" ? vm.products : vm.products.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    struct WishlistCategoryRow: View {
        
        let category: CategoryDetails
        let categoryProducts: [ProductDetails]
        
        var body: some View {
            VStack {
                HStack {
                    Text("\(category.categoryName)")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color(red: 0.784, green: 0.784, blue: 0.793, opacity: 0.369))
            
            Spacer()
            
            VStack {
                ForEach(categoryProducts) { product in
                    if product.category == category.categoryName {
                        WishlistRow(product: product)
                    }
                }
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
                        Image(systemName: "photo.on.rectangle.angled").font(.system(size:30))
                    }
                    
                    VStack (alignment: .leading){
                        Text(product.name)
                            .font(.system(size: 17, weight: .semibold))
                        Text(product.shade)
                            .foregroundColor(Color(.lightGray))
                        Text(product.brand)
                    }
                    
                    Spacer ()
                    
                    if (!product.webLink.isEmpty) {
                        if let url = URL(string: product.webLink), UIApplication.shared.canOpenURL(url) {
                            Image(systemName: "safari")
                                .font(.system(size: 20))
                                .onTapGesture{
                                    UIApplication.shared.open(url)
                                }
                        }
                    }
                    
                    NavigationLink(destination: NewEditWishlistProductView(productID: product.id)) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                        .foregroundColor(Color(.label)) }
                    
                }
                Divider()
                    .padding(.vertical, 2)
            }.padding(.horizontal)
            
        }
    }
}

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        WishlistView()
    }
}
