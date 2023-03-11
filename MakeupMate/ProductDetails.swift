//
//  ProductDetails.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 11/03/2023.
//

import Foundation

// Creating constants which ProductDetails uses
struct FirebaseConstants {
    static let uid = "uid"
    static let image = "image"
    static let name = "name"
    static let brand = "brand"
    static let category = "category"
    static let shade = "shade"
    static let stock = "stock"
    static let expiryDate = "expiryDate"
    static let note = "note"
}

// Decodes the data retrieved from Firestore and places them into variables
struct ProductDetails: Identifiable {
    
    var id: String { documentID }
    
    let documentID: String
    
    let uid, image, name, brand, category, shade, stock, expiryDate, note: String
    
    init(documentID: String, data: [String: Any]){
        self.documentID = documentID
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.image = data[FirebaseConstants.image] as? String ?? ""
        self.name = data[FirebaseConstants.name] as? String ?? ""
        self.brand = data[FirebaseConstants.brand] as? String ?? ""
        self.category = data[FirebaseConstants.category] as? String ?? ""
        self.shade = data[FirebaseConstants.shade] as? String ?? ""
        self.stock = data[FirebaseConstants.stock] as? String ?? ""
        self.expiryDate = data[FirebaseConstants.expiryDate] as? String ?? ""
        self.note = data[FirebaseConstants.note] as? String ?? ""
    }
}
