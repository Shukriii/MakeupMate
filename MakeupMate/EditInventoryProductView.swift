//
//  EditInventoryProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 11/03/2023.
//

import SwiftUI

struct EditInventoryProductView: View {
    // left out category and expiry date
    let productID, productName, productBrand, productShade, productStock,  productNote, productImage: String
    
    
    @State private var name = ""
    @State private var brand = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var note = ""
    @State private var image = ""
    
    @State var shouldShowImagePicker = false
    @State var storageImage: UIImage?
    
    @ObservedObject private var vm = InventoryViewModel()
    
    init(productID: String, productName: String, productBrand: String, productShade: String, productStock: String, productNote: String, productImage: String) {
           self.productID = productID
           self.productName = productName
           self.productBrand = productBrand
           self.productShade = productShade
           self.productStock = productStock
           self.productNote = productNote
           self.productImage = productImage
           
           _name = State(initialValue: productName)
           _brand = State(initialValue: productBrand)
           _shade = State(initialValue: productShade)
           _stock = State(initialValue: productStock)
           _note = State(initialValue: productNote)
       }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            
                            /*IMAGE
                            Button {
                                shouldShowImagePicker.toggle()
                            } label: {
                                VStack {
                                    if let image = self.storageImage {
                                        Image(uiImage: image) // use the stored image
                                            .resizable()
                                            .frame(width: 180, height: 180)
                                            .scaledToFill()
                                        
                                    } else {
                                        Image(systemName: "photo").font(.system(size:120))
                                    }
                                }
                            }
                        }.sheet(isPresented: $shouldShowImagePicker, onDismiss: updateImage) {
                            ImagePicker(image: $storageImage)
                        }
                        .onAppear {
                            // Load the product details from Firestore
                            vm.fetchAllInventoryProducts()
                            updateImage() // load the stored image */
                        }
                        
                        Spacer ()
                        
                        VStack (spacing: 16){
                            Text(productID)
                            //NAME
                            VStack (alignment: .leading) {
                                if !productName.isEmpty {
                                    Text("Name")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Name", text: $name)
                                    .onAppear {
                                        name = productName
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //BRAND
                            VStack (alignment: .leading) {
                                if !productBrand.isEmpty {
                                    Text("Brand")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Brand", text: $brand)
                                    .onAppear {
                                        brand = productBrand
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //SHADE
                            VStack (alignment: .leading) {
                                if !productShade.isEmpty {
                                    Text("Shade")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Shade", text: $shade)
                                    .onAppear {
                                        shade = productShade
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            /*
                            //STOCK
                            VStack (alignment: .leading) {
                                if !productStock.isEmpty {
                                    Text("Stock")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Stock", text: $stock)
                                onAppear {
                                    stock = productStock
                                }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //NOTE
                            VStack (alignment: .leading) {
                                if !productNote.isEmpty {
                                    Text("Note")
                                        .font(.subheadline)
                                        .foregroundColor(.purple)
                                        .multilineTextAlignment(.center)
                                }
                                TextField("Note", text: $note)
                                    .multilineTextAlignment(.leading)
                                onAppear {
                                    note = productNote
                                }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5) */
                        
                        }
                        .onAppear {
                            // Load the product details from Firestore
                            fetchProduct()
                        }
                        .padding(12)
                        
                        HStack{
                             Button{
                                 print("returns back to inventory view")
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
}

struct EditInventoryProductView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InventoryView()
        }
    }
}
