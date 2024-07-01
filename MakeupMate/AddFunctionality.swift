//
//  AddFunctionality.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

/*
  This observable object is used to add products to the inventory and wishlist views.
  Uses Firebase Storage to upload an image to Storage and with a reference of the products' productID.
  The functions have been paramterised and some parameteres are optional e.g. expiryDate, so the function can be reused
 
  No code has been copied directly, only adapted from tutorials
 
  Storing product into Firestore: https://www.youtube.com/watch?v=dA_Ve-9gizQ&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=12&ab_channel=LetsBuildThatApp
  Storing image to Firebase Storage: https://www.letsbuildthatapp.com/videos/7125
 */

import Foundation
import SwiftUI

class AddFunctionalityViewModel: ObservableObject {
    
    @Published var statusMessage = ""
    
    // This function creates a documents and a reference to store the product using the unique documentID
    // calls storeProduct either with a url or a url set to nil
    func uploadProduct(fromCollection collectionName: String, name: String, brand: String, categoryField: String, shade: String, webLink: String? = nil, note: String, image: UIImage?, presentationMode: Binding<PresentationMode>? = nil) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
       
        // Create a document in the collection passed in
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection(collectionName)
            .document()
        
        // assign the documentID to productID
        let productID = document.documentID
        
        // store the image with reference of productID
        let reference = FirebaseManager.shared.storage.reference(withPath: productID)
        
        // If theres an image
        if let imageData = image?.jpegData(compressionQuality: 0.5) {
            // upload data to Storage if an image is selected
            reference.putData(imageData, metadata: nil) { metadata, err in
                if let err = err {
                    self.statusMessage = "Error uploading image: \(err)"
                    return
                }
            
                // download the url of the image
                reference.downloadURL { url, err in
                    if let err = err {
                        self.statusMessage = "Failed to retrieve downloadURL: \(err)"
                        return
                    }
                    
                    self.statusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                    print(self.statusMessage)
                    
                    guard let url = url else { return }
                    // call storeProduct with proudctID and url of image
                    self.storeProduct(fromCollection: collectionName, productID: productID, imageProfileUrl: url, name: name, brand: brand, categoryField: categoryField, shade: shade, webLink: webLink, note: note, presentationMode: presentationMode)
                }
            }
            // if no image then call storeProduct with productID and no url
        } else {
            self.storeProduct(fromCollection: collectionName, productID: productID, imageProfileUrl: nil, name: name, brand: brand, categoryField: categoryField, shade: shade, webLink: webLink, note: note, presentationMode: presentationMode)
        }
    }
    
    // This function stores the product into Firestore, finding the document created with productID
    func storeProduct(fromCollection collectionName: String, productID: String, imageProfileUrl: URL?, name: String, brand: String, categoryField: String, shade: String, webLink: String? = nil, note: String, presentationMode: Binding<PresentationMode>? = nil) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        // uses productID to find the document
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection(collectionName)
            .document(productID)

        //dictionary of data to be stored, common to both Inventory and Wishlist
        var productData = ["uid": uid, "name": name, "brand": brand, "category": categoryField, "shade": shade, "note": note] as [String : Any]
         
        // webLink only exlcusive to Wishlist
        if collectionName == "wishlist" {
            productData["webLink"] = webLink
        }

        // Check if image URL is not nil and add image to the dictionary accordingly
        if let imageProfileUrl = imageProfileUrl {
            productData["image"] = imageProfileUrl.absoluteString
        }
        
        // set productData to the document
        document.setData(productData) { error in
            if let error = error {
                print(error)
                self.statusMessage = "Failed to save product into Firestore: \(error)"
                print(self.statusMessage)
                return
                
            }
            print ("Successfully added the product")
        }
        
        presentationMode?.wrappedValue.dismiss()
    }
}


