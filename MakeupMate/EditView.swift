//
//  EditView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 14/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI

// only 3 textfields can be shown at a time, could be because on appear is over used
struct EditView: View {
    
    @State var products = [ProductDetails]()
    let productID, productImage: String
    @State var product: ProductDetails?// Declare product as optional and @State

        
    init(productID: String, productImage: String) {
        self.productID = productID
        self._product = State(initialValue: nil) // Initialize product as nil
        self.productImage = productImage
    }
    
    @State private var name = ""
    @State private var brand = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var note = ""
    @State var shouldShowImagePicker = false
    @State var updatedImage: UIImage?
    @State var image: UIImage?
    @State var showInventoryView = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    
                    HStack {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let product = product {
                                    if !product.image.isEmpty {
                                        WebImage(url: URL(string: product.image))
                                            .resizable()
                                            .frame(width: 180, height: 180)
                                            .scaledToFill()
                                    }
                                    else {
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
                        Text(productID)
                        
                        if let product = product {
                            //Text(product.name)
                            
                            VStack (alignment: .leading) {
                                if !product.name.isEmpty {
                                    Text("Name")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Name", text: $name)
                                    .onAppear {
                                        name = product.name.isEmpty ? "" : product.name
                                        //name = product.name
                                    }

                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            VStack (alignment: .leading) {
                                if !product.brand.isEmpty {
                                    Text("Brand")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Brand", text: $brand)
                                    .onAppear {
                                        brand = product.brand.isEmpty ? "" : product.brand
                                        //brand = product.brand
                                    }
                            }
                            .padding(15)
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
                                        //shade = product.shade
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //let stock = product.stock
                            //Text(stock)
                            //let note = product.note
                            //Text(note)
                            
                            /*STOCK
                            VStack (alignment: .leading) {
                                if !product.stock.isEmpty {
                                    Text("Stock")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Stock", text: $stock)
                                onAppear {
                                    stock = product.stock.isEmpty ? "" : product.stock
                                    //stock = product.stock
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
                                    .multilineTextAlignment(.leading)
                                onAppear {
                                    note = product.note
                                }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5) */
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
                             saveProduct()
                             //updateProduct(imageProfileUrl: url)
                             
                         } label: {
                             Image(systemName: "checkmark.circle")
                                 .font(.system(size: 30))
                                 .foregroundColor(Color("Colour5"))
                         }
                    }
                }
            }
        }
    }

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
             self.product = ProductDetails(documentID: id, data: data)
         }
     }
    
    private func saveProduct() {
        uploadImageToStorage()
    }
    
    @State var statusMessage = ""
    
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
        //NavigationLink(destination: InventoryView(), isActive: $showInventoryView)
    }
}

