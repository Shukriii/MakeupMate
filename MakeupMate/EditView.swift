//
//  EditView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 14/03/2023.
//

import SwiftUI


struct EditView: View {
    
    @State var products = [ProductDetails]()
        let productID, productName, productBrand, productShade, productStock,  productNote: String
        @State var product: ProductDetails? // Declare product as optional and @State
        
    init(productID: String, productName: String, productBrand: String, productShade: String, productStock: String, productNote: String) {
            self.productID = productID
            self.productName = productName
            self.productBrand = productBrand
            self.productShade = productShade
            self.productStock = productStock
            self.productNote = productNote
            self._product = State(initialValue: nil) // Initialize product as nil
    }
    
    @State private var name = ""
    @State private var brand = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var note = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        // Image here
                    }
                    
                    Spacer ()
                    
                    VStack (spacing: 16){
                        Text(productID)

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
}

