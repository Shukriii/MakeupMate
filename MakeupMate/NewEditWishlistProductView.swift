//
//  NewEditWishlistProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 14/04/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewEditWishlistProductView: View {
    
    @State private var selectedCategory: CategoryDetails?
    @State var product: ProductDetails?
    let productID: String

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
    @State var image: UIImage?
    
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
                    
                    Section(header: Text("Product URL"), footer: displayInvalidURL ? Text("This URL is not valid").foregroundColor(.red) : Text("")){

                        // editUrl is false, and product.weblink is not empty
                        if (!product.webLink.isEmpty && !editURL) {
                            HStack {
                                // if url is valid
                                if let url = URL(string: product.webLink), UIApplication.shared.canOpenURL(url) {
                                    Text("\(product.webLink)")
                                        .foregroundColor(.blue)
                                        .onTapGesture{
                                            UIApplication.shared.open(url)
                                        }
                                } else {
                                    // The URL is not valid or cannot be opened
                                    Text("\(product.webLink)")
                                        .foregroundColor(.blue)
                                        .onAppear() {
                                            displayInvalidURL.toggle()
                                        }
                                    
                                }
                        
                                Spacer()
                                
                                Button {
                                    editURL.toggle()
                                    print("product.webLink date has been removed")
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .foregroundColor(Color.gray)
                                }
                            }
                            // product.weblink is emptty or editUrl is true
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
                        // IMAGE
                        Button {
                            image = nil
                            ef.product?.image = ""
                        } label: {
                            Text("Remove Photo")
                        }
                        
                        // DELETE
                        Button {
                            ef.deleteProduct(fromCollection: "wishlist", productID: productID, presentationMode: presentationMode)
                        } label: {
                            Text("Delete Product")
                        }
                        .foregroundColor(.red)
                        
                        // SAVE
                        Button{
                            // webLink has not been edited
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


