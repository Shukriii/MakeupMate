//
//  EditView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 14/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI

// only 3 textfields can be shown at a time, could be because on appear is over used
// do image then updat firebase

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
    @State var storageImage: UIImage?
    @State var image: UIImage?
    @State var showInventoryView = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        /*
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: { if let product = product {
                            
                            if !product.image.isEmpty {
                                WebImage(url: URL(string: product.image))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 180)
                                    .clipped()
                                let storageImage = product.image
                                
                            } else {
                                Image(systemName: "photo").font(.system(size:30))
                            }
                        }
                        } */
                        
                        
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let product = product {
                                    if let image = self.storageImage {
                                        //WebImage(url: URL(string: image))
                                        Image(uiImage: image) // use the stored image
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .scaledToFill()
                                    
                                } else {
                                    Image(systemName: "photo").font(.system(size:120))
                                }
                            }
                            }
                        }
                        
                    }.sheet(isPresented: $shouldShowImagePicker, onDismiss: updateImage) {
                        ImagePicker(image: $storageImage)
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
                            
                            Text(product.stock)
                            Text(product.note)
                            
                            /* //STOCK
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
    
    private func updateImage() {
        if let storageImage = self.storageImage {
            self.storageImage = storageImage } else {
                guard let url = URL(string: productImage) else { return }
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async {
                        self.storageImage = UIImage(data: data)
                    }
                }.resume()
                
            }
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

