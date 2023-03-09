//
//  InventoryProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/03/2023.
//

import SwiftUI

struct AddInventoryProductView: View {
    
    @State private var name = ""
    @State private var brand = ""
    @State private var category = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var expiryDate = Date.now
    @State private var note = ""
    
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView{
                    VStack {
                        HStack{
                            Image(systemName: "photo").font(.system(size:120))
                        }
                        
                        Spacer()
                        
                        VStack (spacing: 16){
                            
                            //NAME
                            VStack (alignment: .leading) {
                                if !name.isEmpty {
                                    Text("Name")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Name", text: $name)
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //BRAND
                            VStack (alignment: .leading) {
                                if !brand.isEmpty {
                                    Text("Brand")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Brand", text: $brand)
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //CATEGORY
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
                            //.padding(.horizontal, 155)
                            //.padding(12)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //SHADE
                            VStack (alignment: .leading) {
                                if !shade.isEmpty {
                                    Text("Shade")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Shade", text: $shade)
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //STOCK
                            VStack (alignment: .leading) {
                                if !stock.isEmpty {
                                    Text("Stock")
                                        .font(.subheadline)
                                    .foregroundColor(.purple)
                                }
                                TextField("Stock", text: $stock)
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                            //EXPIRY DATE, needs to become optional 
                            VStack {
                                DatePicker(selection: $expiryDate, in: ...Date.distantFuture, displayedComponents: .date) {
                                    Text("Expiry Date")
                                }
                            }
                            
                            //NOTE - fix layout
                            VStack (alignment: .leading) {
                                if !note.isEmpty {
                                    Text("Note")
                                        .font(.subheadline)
                                        .foregroundColor(.purple)
                                        .multilineTextAlignment(.center)
                                }
                                TextField("Note", text: $note)
                            }
                            .padding(50)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                        }
                        .padding(12)

                        HStack{
                            
                            Button{
                                storeProduct()
                            } label: {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 30))
                                    .foregroundColor(Color("Colour5"))
                            }
                       }
                    }
                }
            }
            .navigationTitle("Inventory Product")
            .navigationViewStyle(StackNavigationViewStyle())
            //CANCEL BUTTON
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading){
                    Button {
                        presentationMode.wrappedValue.dismiss()
  
                    } label: {
                        Text ("Cancel").foregroundColor(.blue)
                    }
                }
            }
        }
        
    }
    
    @State var statusMessage = ""
    
    private func storeProduct(){
        // set the uid to the uid of the user logged in
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        //database setup
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection("inventory")
            .document()
        
        //dictionary of data to be stored
        let productData = ["uid": uid, "name": self.name, "brand": self.brand, "category": self.category, "shade": self.shade, "stock": self.stock, "expiryDate": self.expiryDate, "note": self.note] as [String : Any]
        
        document.setData(productData) { error in
            if let error = error {
                print(error)
                self.statusMessage = "Failed to save product into Firestore: \(error)"
                return
                
            }
            print ("success")
        }
        presentationMode.wrappedValue.dismiss()
    }
}


struct InventoryProductView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
