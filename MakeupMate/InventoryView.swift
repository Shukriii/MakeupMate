//
//  InventoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 04/03/2023.
//

/*  View of the Inventory, it displays categories and the associated products in Firestore. Has navigation links to AddInventoryProduct and EditInventoryProduct.
   If the user is not logged in, a fullScreenCover of LoginView will appear
 
   No code has been copied directly, the code has been adapted from the following tutorial.
 
   Created a template of displaying the product on screen using: https://www.youtube.com/watch?v=pPsKTTd55xI&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=6&ab_channel=LetsBuildThatApp
 */

import SwiftUI
import SDWebImageSwiftUI


struct InventoryView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var productsForCategory = [ProductDetails]()
    
    @ObservedObject private var vm = FetchFunctionalityViewModel(collectionName: "inventory")
    @ObservedObject private var am = AccountFunctionalityViewModel()
    @ObservedObject private var cf = CategoryFunctionalityViewModel()
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack (spacing: 15) {
                
                // calls TopNavigationBar and provides it with the navigationName, displays a full screen cover if variable isUserCurrentlyLoggedOut is true
                TopNavigationBar(navigationName: "Your Makeup Collection")
                    .fullScreenCover(isPresented: $am.isUserCurrentlyLoggedOut, onDismiss: nil){
                        //calls functions needed once Login is complete
                        LoginView(didCompleteLoginProcess: {
                            self.am.isUserCurrentlyLoggedOut = false
                            self.am.fetchCurrentUser()
                            self.vm.removeProducts()
                            self.vm.fetchProducts(fromCollection: "inventory")
                            self.cf.fetchCategories()
                        })
                    }
                
                // Search bar, with binding variable of searchText
                SearchBarView(searchText: $searchText)
                    .frame(width: 370, height: 10, alignment: .center)
                    .padding()
                    
                VStack {
                    ScrollView {
                        // if search is not be used, displays the categorys and products
                        if searchText == "" {
                            VStack {
                                ForEach(cf.categories) { category in
                                    // if that category has products
                                    let hasProducts = vm.products.contains(where: { $0.category == category.categoryName })
                                    
                                    // products where the product.category matches the categoryName
                                    let productsForCategory = vm.products.filter { $0.category == category.categoryName }
                                    
                                    // if the category has products, call CategoryRow on each of the productsForCategory
                                    if hasProducts {
                                        CategoryRow(category: category, categoryProducts: productsForCategory) }
                                }
                            }
                            .padding(.bottom, 50)
                        }
                        // if search is being used only display the products that statify arrayOfProducts
                        else {
                            VStack {
                                ForEach(arrayOfProducts) { product in
                                    ProductRow(product: product)
                                }
                            }
                            .padding(.bottom, 50)
                        }
                    }
                }
            }
            // An overlay of a HStack, which displays "New Product" which is a Navigation link to AddInventoryProductView
            .overlay(
                NavigationLink(destination: NewAddInventoryProductView()) {
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // products that match the string being searched
    var arrayOfProducts: [ProductDetails] {
        return searchText == "" ? vm.products : vm.products.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    // displays the categoryName and calls ProductRow for each categoryProduct
    struct CategoryRow: View {
        
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
                    // cal product Row to display each product part of categoryRow
                    ForEach(categoryProducts) { product in
                        if product.category == category.categoryName {
                            ProductRow(product: product)
                        }
                    }
                }
        }
    }
    
    // This struct is passed a product and uses the ProductDetails struct it uses a variable to access the data. Is displays the product image, along with product name, shade and brand if avaliable. It has an Edit icon which redirects the user to EditView
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
                        Image(systemName: "photo.on.rectangle.angled").font(.system(size:35))
                    }
                    
                    VStack (alignment: .leading){
                        Text(product.name)
                            .font(.system(size: 17, weight: .semibold))
                        Text(product.shade)
                            .foregroundColor(Color(.lightGray))
                        Text(product.brand)
                    }
                    Spacer ()
                    
                    // Call to Edit view to edit the product details, it passed product.id so the view can fetch the product
                    NavigationLink(destination: NewEditInventoryProductView(productID: product.id)) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                        .foregroundColor(Color(.label))
                    }
                }
                Divider().padding(.vertical, 2)
                
            }
            .padding(.horizontal)
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
