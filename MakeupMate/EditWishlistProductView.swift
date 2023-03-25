//
//  EditWishlistProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 22/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditWishlistProductView: View {
    
    @State var product: ProductDetails?
    let productID: String

    init(productID: String) {
        self.productID = productID
        self._product = State(initialValue: nil)
    }
    
    @State private var name = ""
    @State private var brand = ""
    @State private var shade = ""
    @State private var note = ""
    @State var image: UIImage?
    
    @State var showWishlistView = false
    @State var shouldShowImagePicker = false
    
    @Environment(\.presentationMode) var presentationMode
    
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
                                if let product = product {
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
                        if let product = product {
                            
                            EditTextFieldView(listKey: product.name, displayName: "Name", variableName: $name)
                            
                            EditTextFieldView(listKey: product.brand, displayName: "Brand", variableName: $brand)
                            
                            // CATEGORY
                            Button {
                                print("category view appears")
                            } label:  {
                                HStack {
                                    Text("Category")
                                    Spacer()
                                    Image(systemName: "chevron.right.circle")
                                }
                                .padding(15)
                                    
                            }
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            EditTextFieldView(listKey: product.shade, displayName: "Shade", variableName: $shade)
                            
                            EditTextFieldView(listKey: product.note, displayName: "Note", variableName: $note)
                        }
                    }
                    .onAppear {
                        // Load the product details from Firestore
                        fetchProduct()
                    }
                    .padding(12)
                    
                    HStack{
                         Button{
                             deleteProduct()
                         } label: {
                             Image(systemName: "trash")
                                 .font(.system(size: 30))
                                 .foregroundColor(.red)
                         }

                         Spacer()
                             .frame(width: 90)

                         Button{
                             uploadImageToStorage()
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
    
   // This function uses the productID passed into EditInventoryProdcut to find the document with the id
    private func fetchProduct() {
         // uid of user logged in
         guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
         
         // id of product
         let id = self.productID
         
         // to find in Firestore
         FirebaseManager.shared.firestore.collection("products").document(uid).collection("wishlist").document(id).getDocument {
             snapshot, error in
                 if let error = error {
                     print("Failed to fetch current user:", error)
                     return }
             
             guard let data = snapshot?.data() else {
                 print("No data found")
                 return }
             
             print(data)
             // stores the data into a product, using ProductDetails to decode the data
             self.product = ProductDetails(documentID: id, data: data)
         }
     }
    
    @State var statusMessage = ""
    
    // This function uploads the image being displayed to Firebase Storage, if no image has been chosen it calls updateProduct with nil
    private func uploadImageToStorage() {
        let id = self.productID
        
        let reference = FirebaseManager.shared.storage.reference(withPath: id)
        print("Firebase Storage reference: \(reference)")
        
        if let imageData = self.image?.jpegData(compressionQuality: 0.5) {
            reference.putData(imageData, metadata: nil) { metadata, err in
                if let err = err {
                    self.statusMessage = "Error uploading image: \(err)"
                    return
                }
            
                reference.downloadURL { url, err in
                    if let err = err {
                        self.statusMessage = "Failed to retrieve downloadURL: \(err)"
                        return
                    }
                    
                    self.statusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                    print(statusMessage)
                    
                    guard let url = url else { return }
                    // call updateProduct with proudctID and url of image
                    self.updateProduct(imageProfileUrl: url)
                }
            }
        } else {
            self.updateProduct(imageProfileUrl: nil)
        }
    }
    
    // This fuction updates the product in Firestore
    private func updateProduct(imageProfileUrl: URL?) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let id = self.productID
        
        var productData = ["uid": uid, "name": name, "brand": brand, "shade": shade, "note": note] as [String : Any]
        
        if let product = product {
            // if no new image was picked
            if imageProfileUrl == nil && !product.image.isEmpty {
                productData["image"] = product.image
                // if a new image was pciked, which is either the url or nil
            } else if let imageProfileUrl = imageProfileUrl {
                productData["image"] = imageProfileUrl.absoluteString
            }
        }
        
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection("wishlist")
            .document(id)
            
            document.setData(productData) { error in
                if let error = error {
                    print("Failed to save product into Firestore: \(error)")
                    return
                } else {
                    print("product updated")
                    self.showWishlistView = true
                }
            }
        presentationMode.wrappedValue.dismiss()
    }
    
    // this function finds the document in Firestore and deletes the document
    private func deleteProduct() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        // id of product
        let id = self.productID
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection("wishlist").document(id).delete { error in
                if let error = error {
                    print("Failed to delete:", error)
                    return }
            else {
                print("product deleted")
                self.showWishlistView = true
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    
}

