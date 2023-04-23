//
//  NewEditWishlistProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 14/04/2023.
//

/*
 This view has been created by the auhtor, it is passed in a productID which is then used to fetch the product from Firestore.
 
 The fetched data populates the view, if the variable is not empty
 */

import SwiftUI
import SDWebImageSwiftUI

struct NewEditWishlistProductView: View {
    
    @State private var selectedCategory: CategoryDetails?
    @State var product: ProductDetails?
    let productID: String

    // The initialiser init takes a parameter of productID (provided by InventoryView) and sets it to productID (the string created). The initial value of product is set to nil to be later changed.
    
    init(productID: String) {
        self.productID = productID
        self._product = State(initialValue: nil)
    }
    
    @State private var name = ""
    @State private var brand = ""
    @State private var category = ""
    @State private var categoryField = ""
    @State private var shade = ""
    @State private var note = ""
    @State private var webLink = ""
    @State private var image: UIImage?
    
    @State var shouldShowImagePicker = false
    @State var goesToCategories = false
    @State var editURL = false
    @State var dataFetched = false
    @State var displayInvalidURL = false

    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var ef = EditFunctionalityViewModel()
    
    var body: some View {
        VStack {
            Form {
                
                Section(footer: Text("Click to add a photo")){
                    // The boolean becomes true and the Image Picker is displayed
                    Button {
                        shouldShowImagePicker.toggle()
                    } label: {
                        VStack {
                            if let product = ef.product {
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .scaledToFill()
                                    // if product.image is not empty display the products image
                                } else if !product.image.isEmpty {
                                    WebImage(url: URL(string: product.image))
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .scaledToFill()
                                    // else display the photo
                                } else {
                                    Image(systemName: "photo.on.rectangle.angled").font(.system(size:120))
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .listRowInsets(EdgeInsets())
                .background(Color(red: 0.949, green: 0.949, blue: 0.97))
                
                
                if let product = ef.product {
                    
                    Section(header: Text("Product Name")){
                        EditTextFieldView(listKey: product.name, displayName: "Name", variableName: $name)
                    }
                    
                    Section(header: Text("Product Brand")){
                        EditTextFieldView(listKey: product.brand, displayName: "Brand", variableName: $brand)
                    }
                    
                    Section(header: Text("Product Shade")){
                        EditTextFieldView(listKey: product.shade, displayName: "Shade", variableName: $shade)
                    }
                    
                    // Navigation link to CategoryView and displays either product.category or the selected category
                    Section(header: Text("Product Category"), footer: Text("Click to select a category")){
                        NavigationLink(destination: CategoryView(selectedCategory: $selectedCategory)) {
                            HStack {
                                Text(categoryField.isEmpty ? "E.g. Powder Blushes" : categoryField)
                                    .foregroundColor(categoryField.isEmpty ? Color(red: 0.784, green: 0.784, blue: 0.793) : Color.black)
                            }
                            .onAppear {
                                if let category = selectedCategory {
                                    categoryField = category.categoryName
                                } else if !product.category.isEmpty {
                                    categoryField = product.category
                                }
                            }
                        }
                    }
                    
                    // Hyperlink found her  - https://stackoverflow.com/questions/48048651/difference-between-openurl-canopenurl
                    Section(header: Text("Product URL"), footer: displayInvalidURL ? Text("This URL is not valid").foregroundColor(.red) : Text("")){

                        // if editUrl is false, and product.weblink is not empty, displays the URL as Text and on tap open the url
                        if (!product.webLink.isEmpty && !editURL) {
                            HStack {
                                // if url is valid
                                if let url = URL(string: product.webLink),
                                   // a boolean that check if the url can open
                                    UIApplication.shared.canOpenURL(url) {
                                    Text("\(product.webLink)")
                                        .foregroundColor(.blue)
                                        .onTapGesture{
                                            //opens the url
                                            UIApplication.shared.open(url)
                                        }
                                }
                                // The URL is not valid, display it as a Textfield and the boolean displayInvalidURL is set to true, displaying the footer error message
                                else {
                                    Text("\(product.webLink)")
                                        .foregroundColor(.blue)
                                        .onAppear() {
                                            displayInvalidURL.toggle()
                                        }
                                }
                        
                                Spacer()
                                
                                // a button to remove the url
                                Button {
                                    editURL.toggle()
                                    print("product.webLink date has been removed")
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .foregroundColor(Color.gray)
                                }
                            }
                            // product.weblink is empty or editUrl is true, a TextiField is dislpayed
                        } else if (product.webLink.isEmpty || editURL){
                            HStack {
                                TextField("https://www.boots.com", text: $webLink)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                        }
                    }
                    
                    Section(header: Text("Note")){
                        EditTextFieldView(listKey: product.note, displayName: "Note", variableName: $note)
                    }
                    
                    Section{
                        // IMAGE button
                        Button {
                            image = nil
                            ef.product?.image = ""
                        } label: {
                            Text("Remove Photo")
                        }
                        
                        // DELETE button
                        Button {
                            ef.deleteProduct(fromCollection: "wishlist", productID: productID, presentationMode: presentationMode)
                        } label: {
                            Text("Delete Product")
                        }
                        .foregroundColor(.red)
                        
                        // SAVE button
                        Button{
                            // if webLink has not been edited, keep it the same
                            if(!product.webLink.isEmpty && !editURL) {
                                webLink = product.webLink
                            }
                            
                            ef.uploadImageToStorage(fromCollection: "wishlist", productID: productID, name: name, brand: brand, categoryField: categoryField, shade: shade, webLink: webLink, note: note, image: image, presentationMode: presentationMode)
                            
                        } label: {
                            Text("Save Product")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Edit Product")
            .onAppear {
                // Load the product details from Firestore
                if !dataFetched {
                    ef.fetchProduct(fromCollection: "wishlist", productID: productID)
                    print("data has been fetched")
                    dataFetched = true
                }
            }
        }
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            // Displays the users photo library to select an image
            ImagePicker(image: $image)
        }
    }
}


