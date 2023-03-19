//
//  EditInventoryProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 14/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditInventoryProductView: View {
    
    @State var products = [ProductDetails]()
    let productID, productImage: String
    @State var product: ProductDetails?

    init(productID: String, productImage: String) {
        self.productID = productID
        self._product = State(initialValue: nil)
        self.productImage = productImage
    }
    
    @State private var name = ""
    @State private var brand = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var note = ""
    @State var shouldShowImagePicker = false
    @State var updatedImage: String?
    @State var image: UIImage?
    @State var showInventoryView = false
    
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
                                // if theres a new image selected display the image
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .scaledToFill()
                                    // if product.image is not empty display the products image
                                } else if !productImage.isEmpty {
                                    WebImage(url: URL(string: productImage))
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .scaledToFill()
                                    // display the photo
                                } else {
                                    Image(systemName: "photo").font(.system(size:120))
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
                            
                            // NAME
                            VStack (alignment: .leading) {
                                if !product.name.isEmpty {
                                    Text("Name")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Name", text: $name)
                                    .onAppear {
                                        name = product.name.isEmpty ? "" : product.name
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //BRAND
                            VStack (alignment: .leading) {
                                if !product.brand.isEmpty {
                                    Text("Brand")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Brand", text: $brand)
                                    .onAppear {
                                        brand = product.brand.isEmpty ? "" : product.brand
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
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
                            
                            //SHADE
                            VStack (alignment: .leading) {
                                if !product.shade.isEmpty {
                                    Text("Shade")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Shade", text: $shade)
                                    .onAppear {
                                        shade = product.shade.isEmpty ? "" : product.shade
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            // STOCK
                            VStack (alignment: .leading) {
                                if !product.stock.isEmpty {
                                    Text("Stock")
                                        .font(.subheadline)
                                        .foregroundColor(.purple)
                                }
                                TextField("Stock", text: $stock)
                                    .onAppear {
                                        stock = product.stock.isEmpty ? "" : product.stock
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)

                            //NOTE
                            VStack (alignment: .leading) {
                                if !product.note.isEmpty {
                                    Text("Note")
                                        .font(.subheadline)
                                        .foregroundColor(.purple)
                                        .multilineTextAlignment(.center)
                                }
                                TextField("Note", text: $note)
                                    .onAppear {
                                        note = product.note.isEmpty ? "" : product.note
                                }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
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
         FirebaseManager.shared.firestore.collection("products").document(uid).collection("inventory").document(id).getDocument {
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
                    // call storeProduct with proudctID and url of image
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
        
        var productData = ["uid": uid, "name": name, "brand": brand, "shade": shade, "stock": stock, "note": note] as [String : Any]
        
        if let imageProfileUrl = imageProfileUrl {
            productData["image"] = imageProfileUrl.absoluteString
        }
        
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection("inventory")
            .document(id)
            
            document.setData(productData) { error in
                if let error = error {
                    print("Failed to save product into Firestore: \(error)")
                    return
                } else {
                    print("product updated")
                    self.showInventoryView = true
                }
            }
        presentationMode.wrappedValue.dismiss()
    }
    
    // this function finds the document in Firestore and deletes the document
    private func deleteProduct() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        // id of product
        let id = self.productID
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection("inventory").document(id).delete { error in
                if let error = error {
                    print("Failed to delete:", error)
                    return }
            else {
                print("product deleted")
                self.showInventoryView = true
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

