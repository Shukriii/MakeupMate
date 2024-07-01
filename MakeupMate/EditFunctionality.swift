//
//  EditFunctionality.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

/*
 The author developed this class themselves using the knowledge and approach from the FetchFunctionalityViewModel and AddFunctionalityViewModel previously created. No sources were used.
 
 uploadImageToStorage and updateProduct functions have been paramterised, some parameteres are optional e.g. expiryDate. So the function can be reused
 */

import Foundation
import SwiftUI

class EditFunctionalityViewModel: ObservableObject {
    
    @Published var statusMessage = ""
    @Published var product: ProductDetails?
    
    // As soon as the EditView is displayed this function is called, and it fetches the product from Firestore and ProductDetails is used to decode it
    func fetchProduct(fromCollection collectionName: String, productID: String) {
        // uid of user logged in
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                
        // use productID to find in Firestore
        FirebaseManager.shared.firestore.collection("products").document(uid).collection(collectionName).document(productID).getDocument {
            snapshot, error in
            if let error = error {
                print("Failed to fetch product to edit:, \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found")
                return
            }

            // stores the data into a product, using ProductDetails to decode the data
            self.product = ProductDetails(documentID: productID, data: data)
        }
    }
    
    // Whave the save button is clicked, this function uploads the image being displayed to Firebase Storage, if no image has been chosen it calls updateProduct with nil
    func uploadImageToStorage(fromCollection collectionName: String, productID: String, name: String, brand: String, categoryField: String, shade: String, webLink: String? = nil, note: String, image: UIImage?, presentationMode: Binding<PresentationMode>? = nil) {
        
        // productID is used to create a reference
        let reference = FirebaseManager.shared.storage.reference(withPath: productID)
        
        // compress image and place into imageData
        if let imageData = image?.jpegData(compressionQuality: 0.5) {
            //create a reference
            reference.putData(imageData, metadata: nil) { metadata, err in
                if let err = err {
                    self.statusMessage = "Error uploading image: \(err)"
                    return
                }
                //download the reference URL
                reference.downloadURL { url, err in
                    if let err = err {
                        self.statusMessage = "Failed to retrieve downloadURL: \(err)"
                        return
                    }
                    
                    self.statusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                    print(self.statusMessage)
                    
                    guard let url = url else { return }
                    
                    // call updateProduct with proudctID and url of image
                    self.updateProduct(fromCollection: collectionName, productID: productID, imageProfileUrl: url, name: name, brand: brand, categoryField: categoryField, shade: shade, webLink: webLink, note: note, image: image, presentationMode: presentationMode)
                }
            }
        } else {
            // else call updateProdcut with url set to nil
            self.updateProduct(fromCollection: collectionName, productID: productID, imageProfileUrl: nil, name: name, brand: brand, categoryField: categoryField, shade: shade, webLink: webLink, note: note, image: image, presentationMode: presentationMode)
        }
    }
    
    func updateProduct(fromCollection collectionName: String, productID: String, imageProfileUrl: URL?, name: String, brand: String, categoryField: String, shade: String, webLink: String? = nil, note: String, image: UIImage?, presentationMode: Binding<PresentationMode>? = nil) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        // dictionary of data to store
        var productData = ["uid": uid, "name": name, "brand": brand, "category": categoryField, "shade": shade, "note": note] as [String : Any]
        
        if collectionName == "wishlist" {
            productData["webLink"] = webLink
        }
        
        if let product = product {
            // if no new image was picked, keep the previous data in product.image
            if imageProfileUrl == nil && !product.image.isEmpty {
                productData["image"] = product.image
                // if a new image was picked, which is either the url or nil
            } else if let imageProfileUrl = imageProfileUrl {
                productData["image"] = imageProfileUrl.absoluteString
            }
        }
        
        // find the document
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection(collectionName)
            .document(productID)
            
         // use setDate to store th new product data
            document.setData(productData) { error in
                if let error = error {
                    print("Failed to update product in Firestore: \(error)")
                    return
                } else {
                    print("product updated")

                }
            }
        
        // dismisses the view
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
        
        // dismisses the view
        presentationMode?.wrappedValue.dismiss()
    }
}
