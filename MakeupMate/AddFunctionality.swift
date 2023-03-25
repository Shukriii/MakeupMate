//
//  AddFunctionality.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

import Foundation
import UIKit
import SwiftUI

class AddFunctionalityViewModel: ObservableObject {
    
    @Published var statusMessage = ""
    
    func addProduct(fromCollection collectionName: String, name: String, brand: String, categoryField: String, shade: String? = nil, stock: String? = nil, note: String, image: UIImage?, presentationMode: Binding<PresentationMode>? = nil) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
       
        // Create a document, in the collection passed in
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
            
                reference.downloadURL { url, err in
                    if let err = err {
                        self.statusMessage = "Failed to retrieve downloadURL: \(err)"
                        return
                    }
                    
                    self.statusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                    print(self.statusMessage)
                    
                    guard let url = url else { return }
                    // call storeProduct with proudctID and url of image
                    //self.storeProduct(productID: productID, imageProfileUrl: url)
                    self.storeProduct(fromCollection: collectionName, productID: productID, imageProfileUrl: url, name: name, brand: brand, categoryField: categoryField, shade: shade, stock: stock, note: note, presentationMode: presentationMode)
                }
            }
            // if no image then call storeProduct with productID and no url
        } else {
            //self.storeProduct(productID: productID, imageProfileUrl: nil)
            self.storeProduct(fromCollection: collectionName, productID: productID, imageProfileUrl: nil, name: name, brand: brand, categoryField: categoryField, shade: shade, stock: stock, note: note, presentationMode: presentationMode)
        }
    }
    
    // This function stores the product into Firestore, finding the document created with productID
    func storeProduct(fromCollection collectionName: String, productID: String, imageProfileUrl: URL?, name: String, brand: String, categoryField: String, shade: String? = nil, stock: String? = nil, note: String, presentationMode: Binding<PresentationMode>? = nil) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("products")
            .document(uid)
            .collection(collectionName)
            .document(productID)
        
        //dictionary of data to be stored, common to both Inventory and Wishlist
        var productData = ["uid": uid, "name": name, "brand": brand, "category": categoryField, "note": note] as [String : Any]
        
        if collectionName == "inventory" {
            productData["shade"] = shade
            productData["stock"] = stock
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
