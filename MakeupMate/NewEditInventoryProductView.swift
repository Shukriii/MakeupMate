//
//  EditInventoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 11/04/2023.
//

/*
 This view has been created by the auhtor, it is passed in a productID which is then used to fetch the product from Firestore.
 
 The fetched data populates the view, if the variable is not empty
 */

import SwiftUI
import SDWebImageSwiftUI

struct NewEditInventoryProductView: View {
    
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
    @State private var image: UIImage?
    @State private var shouldShowImagePicker = false
    @State private var goesToCategories = false
    @State private var dataFetched = false

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
                                // Display image chosen from photo album
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
                
                // Displays theStrings stored in the ef.product using PrdocutDetails
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
                    
                    // NavigationLink to CategoryView
                    Section(header: Text("Product Category"), footer: Text("Click to select a category")){
                        NavigationLink(destination: CategoryView(selectedCategory: $selectedCategory)) {
                            HStack {
                                //displays categoryField if it is not empty, or the placeholder text
                                Text(categoryField.isEmpty ? "Category" : categoryField)
                                    .foregroundColor(categoryField.isEmpty ? Color(red: 0.784, green: 0.784, blue: 0.793) : Color.black)
                            }
                            // Sets categoryField to the selectedCategory or product.category
                            .onAppear {
                                if let category = selectedCategory {
                                    categoryField = category.categoryName
                                } else if !product.category.isEmpty {
                                    categoryField = product.category
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Note")){
                        EditTextFieldView(listKey: product.note, displayName: "Note", variableName: $note)
                    }
                    
                    Section{
                        // button to remove image
                        Button {
                            image = nil
                            ef.product?.image = ""
                        } label: {
                            Text("Remove Photo")
                        }
                        
                        // button to delete product
                        Button {
                            ef.deleteProduct(fromCollection: "inventory", productID: productID, presentationMode: presentationMode)
                        } label: {
                            Text("Delete Product")
                        }
                        .foregroundColor(.red)
                        
                        // button to save product
                        Button{
                            ef.uploadImageToStorage(fromCollection: "inventory", productID: productID, name: name, brand: brand, categoryField: categoryField, shade: shade, note: note, image: image, presentationMode: presentationMode)
                        } label: {
                            Text("Save Product")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                // Load the product details from Firestore                
                if !dataFetched {
                    ef.fetchProduct(fromCollection: "inventory", productID: productID)
                    print("data has been fetched")
                    dataFetched = true
                }
            }
            .navigationTitle("Edit Product")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            // Displays the users photo library to select an image
            ImagePicker(image: $image)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct EditInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}

