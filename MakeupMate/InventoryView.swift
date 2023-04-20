//
//  InventoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 04/03/2023.
//

/* - View of the Inventory, it displays the products in Firestore. Has navigation links to AddInventoryProduct and EditInventoryProduct.
   - If the user is not logged in, a fullScreenCover of LoginView will appear (line 189)
 
   No code has been copied directly, the code has been adapted from the following tutorial.
 
   Created a template of displaying the product on screen using: https://www.youtube.com/watch?v=pPsKTTd55xI&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=6&ab_channel=LetsBuildThatApp
 */


import SwiftUI
import SDWebImageSwiftUI

// This struct calls TopNavigationBar and provides it with the navigationName, displays a full screen cover if the user is logged out
// ProductListView provides ProductRow with the array of products fetched
struct InventoryView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var productsForCategory = [ProductDetails]()
    
    @ObservedObject private var vm = FetchFunctionalityViewModel(collectionName: "inventory")
    @ObservedObject private var am = AccountFunctionalityViewModel()
    @ObservedObject private var af = AddFunctionalityViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {

                    TopNavigationBar(navigationName: "Your Makeup Collection")
                        .fullScreenCover(isPresented: $am.isUserCurrentlyLoggedOut, onDismiss: nil){
                            LoginView(didCompleteLoginProcess: {
                                self.am.isUserCurrentlyLoggedOut = false
                                self.am.fetchCurrentUser()
                                self.vm.removeProducts()
                                self.vm.fetchProducts(fromCollection: "inventory")
                                self.af.fetchCategories()
                            })
                        }

                    ForEach(af.categories) { category in
                        let hasProducts = vm.products.contains(where: { $0.category == category.categoryName })
                        
                        let productsForCategory = vm.products.filter { $0.category == category.categoryName }
                        
                        // if the category has products
                        if hasProducts {
                            CategoryRow(category: category, categoryProducts: productsForCategory) }
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
                        .padding(.horizontal, 120)
                }, alignment: .bottom)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

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
                ForEach(categoryProducts) { product in
                    if product.category == category.categoryName {
                        ProductRow(product: product)
                    }
                }
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

