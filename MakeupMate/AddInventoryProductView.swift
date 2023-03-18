//
//  InventoryProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/03/2023.
//

/*
  InventoryView calls this function when the New Product button is clicked
  
 No code has been copied directly
  Tutorials used -
  Floating label for text boxes: https://www.youtube.com/watch?v=Sg0rfYL3utI&t=649s&ab_channel=PeterFriese
  Adding a DatePicker (Calendar): https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-date-picker-and-read-values-from-it
  Storing product into Firestore: https://www.youtube.com/watch?v=dA_Ve-9gizQ&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=12&ab_channel=LetsBuildThatApp
  Storing image to Firebase Storage: https://www.youtube.com/watch?v=5inXE5d2MUM&ab_channel=LetsBuildThatApp
 */

import Firebase
import SwiftUI
import SDWebImageSwiftUI

struct AddInventoryProductView: View {
    
    @State private var name = ""
    @State private var brand = ""
    @State private var category = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var expiryDate = Date.now
    @State private var note = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView{
                    VStack {
                        HStack{
                            //
                            Button {
                                shouldShowImagePicker.toggle()
                            } label: {
                                VStack {
                                    if let image = self.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 180, height: 180)
                                            .scaledToFill()

                                    } else {
                                        Image(systemName: "photo").font(.system(size:120))
                                    }
                                }
                            }
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
                            //TODO: Add category dropdow or make it a new view - Main Product
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
                            
                            //EXPIRY DATE
                            //TODO: Let no date be an option
                            VStack {
                                DatePicker(selection: $expiryDate, in: ...Date.distantFuture, displayedComponents: .date) {
                                    Text("Expiry Date")
                                }
                            }
                            
                            //NOTE
                            // TODO: how to make textfields expand
                            VStack (alignment: .leading) {
                                if !note.isEmpty {
                                    Text("Note")
                                        .font(.subheadline)
                                        .foregroundColor(.purple)
                                        .multilineTextAlignment(.center)
                                }
                                TextField("Note", text: $note)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                            
                        }
                        .padding(12)

                        HStack{
                            Button{
                                addProduct()
                                //uploadImageToStorage()
                                //self.storeProduct(imageProfileUrl: URL)
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
            //Cancel button
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarLeading){
                    Button {
                        presentationMode.wrappedValue.dismiss()
  
                    } label: {
                        Text ("Cancel").foregroundColor(.blue)
                    }
                }
            }
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil){
                ImagePicker(image: $image)
            }
        }
        
    }
    
    @State var statusMessage = ""
    
    var productID: String?
    
    private func addProduct() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
       
        // Create a document
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection("inventory")
            .document()
        
        print("This is the document ID: \(document.documentID)")
        
        let productID = document.documentID // assign the documentId to productID
        let reference = FirebaseManager.shared.storage.reference(withPath: productID)
        print("Firebase Storage reference: \(reference)")
        
        // If theres an image
        if let imageData = self.image?.jpegData(compressionQuality: 0.5) {
            // upload data to Storage if an image is selected
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
                    self.storeProduct(productID: productID, imageProfileUrl: url)
                }
            }
        } else {
            self.storeProduct(productID: productID, imageProfileUrl: nil)
        }
    }
    
    private func storeProduct(productID: String, imageProfileUrl: URL?) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection("inventory")
            .document(productID)
        
        //dictionary of data to be stored
        var productData = ["uid": uid, "name": self.name, "brand": self.brand, "category": self.category, "shade": self.shade, "stock": self.stock, "expiryDate": self.expiryDate, "note": self.note] as [String : Any]
        
        // Check if image URL is nil and update the dictionary accordingly
        if let imageProfileUrl = imageProfileUrl {
            productData["image"] = imageProfileUrl.absoluteString
        }
        
        document.setData(productData) { error in
            if let error = error {
                print(error)
                self.statusMessage = "Failed to save product into Firestore: \(error)"
                return
                
            }
            print ("Successfully added the product")
        }
        presentationMode.wrappedValue.dismiss()
    }
}
    /*
    private func uploadImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        // path of image is the user's uid
        let reference = FirebaseManager.shared.storage.reference(withPath: uid)
        
        if let imageData = self.image?.jpegData(compressionQuality: 0.5) {
            print("in if")
            // upload data to Storage if an image is selected
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
                    //print(url?.absoluteString)
                    
                    guard let url = url else { return }
                    self.storeProduct(imageProfileUrl: url)
                }
            }
        } else {
            storeProduct(imageProfileUrl: nil)
            print("No url")
        }
    }
    
    // Retireves uid from Firebase Auth, then uses it to create collection in Firestore
    // stores all the products details into Firestore
    private func storeProduct(imageProfileUrl: URL?){
        // set the uid to the uid of the user logged in
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection("inventory")
            .document()
        
        //dictionary of data to be stored
        var productData = ["uid": uid, "name": self.name, "brand": self.brand, "category": self.category, "shade": self.shade, "stock": self.stock, "expiryDate": self.expiryDate, "note": self.note] as [String : Any]
        
        // Check if image URL is nil and update the dictionary accordingly
        if let imageProfileUrl = imageProfileUrl {
            productData["image"] = imageProfileUrl.absoluteString
        }
        
        document.setData(productData) { error in
            if let error = error {
                print(error)
                self.statusMessage = "Failed to save product into Firestore: \(error)"
                return
                
            }
            print ("success")
        }
        presentationMode.wrappedValue.dismiss()
    }*/
    
struct InventoryProductView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
