//
//  EditInventoryProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 11/03/2023.
//

import SwiftUI

struct EditInventoryProductView: View {
    
    let productID, productName, productBrand, productCategory, productShade, productStock,  productNote, productImage: String
    
    @State private var name = ""
    @State private var brand = ""
    @State private var category = ""
    @State private var shade = ""
    @State private var stock = ""
    //@State private var expiryDate = Date.now
    @State private var note = ""
    @State private var image = ""
    
    @State var shouldShowImagePicker = false
    @State var storageImage: UIImage?
    
    @ObservedObject private var vm = InventoryViewModel()
    
    init(productID: String, productName: String, productBrand: String, productCategory: String, productShade: String, productStock: String, productNote: String, productImage: String) {
           self.productID = productID
           self.productName = productName
           self.productBrand = productBrand
           self.productCategory = productCategory
           self.productShade = productShade
           self.productStock = productStock
           
           self.productNote = productNote
           self.productImage = productImage
           
           _name = State(initialValue: productName)
           _brand = State(initialValue: productBrand)
           _shade = State(initialValue: productShade)
       }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            //IMAGE
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
                            updateImage() // load the stored image
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
                            
                            //just a botton with label
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
                            
                            //EXPIRY DATE
                            //TODO: Let no date be an option
                            VStack {
                                DatePicker(selection: $expiryDate, in: ...Date.distantFuture, displayedComponents: .date) {
                                    Text("Expiry Date")
                                }
                            }
                            
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
                            vm.fetchAllInventoryProducts()
                        }
                        .padding(12)
                        
                    }
                }
            }
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


