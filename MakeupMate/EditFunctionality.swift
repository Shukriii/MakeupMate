//
//  EditFunctionality.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

import Foundation
import SwiftUI

class EditFunctionalityViewModel: ObservableObject {
    
    @Published var statusMessage = ""
    @Published var product: ProductDetails?
    
    // As soon as the EditView is displayed this function is called
    func fetchProduct(fromCollection collectionName: String, productID: String) {
         // uid of user logged in
         guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
         // to find in Firestore
         FirebaseManager.shared.firestore.collection("products").document(uid).collection(collectionName).document(productID).getDocument {
             snapshot, error in
                 if let error = error {
                     print("Failed to fetch current user:", error)
                     return }
             
             guard let data = snapshot?.data() else {
                 print("No data found")
                 return }
             
             //print(data)
             
             // stores the data into a product, using ProductDetails to decode the data
             self.product = ProductDetails(documentID: productID, data: data)
         }
     }
    
    // Whave the save button is clicked, this function uploads the image being displayed to Firebase Storage, if no image has been chosen it calls updateProduct with nil
    func uploadImageToStorage(fromCollection collectionName: String, productID: String, name: String, brand: String, categoryField: String, shade: String, stock: String? = nil, note: String, image: UIImage?, presentationMode: Binding<PresentationMode>? = nil) {
        
        let reference = FirebaseManager.shared.storage.reference(withPath: productID)
        
        if let imageData = image?.jpegData(compressionQuality: 0.5) {
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
                    print(self.statusMessage)
                    
                    guard let url = url else { return }
                    
                    // call updateProduct with proudctID and url of image
                    self.updateProduct(fromCollection: collectionName, productID: productID, imageProfileUrl: url, name: name, brand: brand, categoryField: categoryField, shade: shade, stock: stock, note: note, image: image, presentationMode: presentationMode)
                }
            }
        } else {
            self.updateProduct(fromCollection: collectionName, productID: productID, imageProfileUrl: nil, name: name, brand: brand, categoryField: categoryField, shade: shade, stock: stock, note: note, image: image, presentationMode: presentationMode)
        }
    }
    
    func updateProduct(fromCollection collectionName: String, productID: String, imageProfileUrl: URL?, name: String, brand: String, categoryField: String, shade: String, stock: String? = nil, note: String, image: UIImage?, presentationMode: Binding<PresentationMode>? = nil) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        var productData = ["uid": uid, "name": name, "brand": brand, "category": categoryField, "shade": shade, "note": note] as [String : Any]
        
        if collectionName == "inventory" {
            productData["stock"] = stock
        }
        
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
            .collection(collectionName)
            .document(productID)
            
            document.setData(productData) { error in
                if let error = error {
                    print("Failed to save product into Firestore: \(error)")
                    return
                } else {
                    print("product updated")
                    //self.showWishlistView = true
                }
            }
        presentationMode?.wrappedValue.dismiss()
    }
    
    // this function finds the document in Firestore and deletes the document
    func deleteProduct(fromCollection collectionName: String, productID: String, presentationMode: Binding<PresentationMode>? = nil) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection(collectionName).document(productID).delete { error in
                if let error = error {
                    print("Failed to delete:", error)
                    return }
            else {
                print("product deleted")
            }
        }
        
        presentationMode?.wrappedValue.dismiss()
    }
}
