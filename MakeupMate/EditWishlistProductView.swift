//
//  EditWishlistProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 22/03/2023.
//

/*
 Adapted from EditInventoryProduct View has the same functionality 
 */
import SwiftUI
import SDWebImageSwiftUI

struct EditWishlistProductView: View {
    
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
    @State private var shade = ""
    @State private var note = ""
    @State var image: UIImage?
    
    @State var shouldShowImagePicker = false
    @State var goesToCategories = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var ef = EditFunctionalityViewModel()
    
    // Creates deisgn of view, which is similar to the view to add a product
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                // TODO: add a button to remove the image
                                if let product = ef.product {
                                    // if theres a new image selected display the image
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
                                        Image(systemName: "photo").font(.system(size:120))
                                    }
                                }
                            }
                        }
                    }.sheet(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                        ImagePicker(image: $image)
                    }
                    
                    Spacer ()
                    
                    VStack (spacing: 16){
                        
                        // Displays the textFields and if anything is stored in the associated variable displays that
                        if let product = ef.product {
                            
                            EditTextFieldView(listKey: product.name, displayName: "Name", variableName: $name)
                            
                            EditTextFieldView(listKey: product.brand, displayName: "Brand", variableName: $brand)
                            
                            NavigationLink(destination: CategoryView(selectedCategory: $selectedCategory), isActive: $goesToCategories) {
                                EmptyView()
                            }

                            Button(action: {
                                goesToCategories = true
                            }) {
                                if let selectedCategory = selectedCategory {
                                    Text("Category Selected: \(selectedCategory.categoryName)")
                                }
                                else if !product.category.isEmpty {
                                    Text("Category Selected: \(product.category)")
                                }
                                else {
                                    Text("No Category Selected, Click here to change category")
                                }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                 
                            EditTextFieldView(listKey: product.shade, displayName: "Shade", variableName: $shade)
                            
                            EditTextFieldView(listKey: product.note, displayName: "Note", variableName: $note)
                        }
                    }
                    .onAppear {
                        // Load the product details from Firestore
                        ef.fetchProduct(fromCollection: "wishlist", productID: productID)
                    }
                    .padding(12)
                    
                    HStack{
                         Button{
                             ef.deleteProduct(fromCollection: "wishlist", productID: productID, presentationMode: presentationMode)
                         } label: {
                             Image(systemName: "trash")
                                 .font(.system(size: 30))
                                 .foregroundColor(.red)
                         }

                         Spacer()
                             .frame(width: 90)

                         Button{
                             if let product = ef.product {
                                 if let selectedCategory = selectedCategory {
                                     self.category = selectedCategory.categoryName
                                     print("category is selected \(category)")
                                 } else if !product.category.isEmpty {
                                     self.category = product.category
                                     print("category is product \(category)")
                                 }
                             }
                             
                             ef.uploadImageToStorage(fromCollection: "wishlist", productID: productID, name: name, brand: brand, categoryField: category, shade: shade, note: note, image: image, presentationMode: presentationMode)
                         } label: {
                             Image(systemName: "checkmark.circle")
                                 .font(.system(size: 30))
                                 .foregroundColor(Color("Colour5"))
                         }
                    }
                }
            }.navigationTitle("Edit Product")
        }
    }
}

