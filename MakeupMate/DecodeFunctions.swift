//
//  DecodeFunctions.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 11/03/2023.
//

/*
 This file contains various Structs that are used to decode a dictionary of data, and places the data into variable to they can be easily accessed
 
 The CurrentUser Struct is used to decode data fetched from the "users" collection in Firestore
 The FirebaseConstant creates variable to prevent accidental spelling mistakes when fetching
 The ProductDetails Struct is used to decode data fetched from the "products" collection in Firestore
 Lastly, the CategoryDetail is used to decode data fetched from the "categories" collection in Firestore
 
 ProductDetails and CategoryDetails make the decoded data identifable with a documentID

 The code was adpated from this tutorial: https://www.letsbuildthatapp.com/videos/7874
 */

import Foundation

struct CurrentUser {
    let uid, email: String
    
    //decoding the properties
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
    }
}

// Creating constants which ProductDetails and CategoryDetails use
struct FirebaseConstants {
    static let uid = "uid"
    static let image = "image"
    static let name = "name"
    static let brand = "brand"
    static let category = "category"
    static let shade = "shade"
    static let stock = "stock"
    static let expiryDate = "expiryDate"
    static let webLink = "webLink"
    static let note = "note"
}

struct ProductDetails: Identifiable {
    
    var id: String { documentID }
    
    let documentID: String
    
    var uid, image, name, brand, category, shade, stock, expiryDate, webLink, note: String
    
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
        self.webLink = data[FirebaseConstants.webLink] as? String ?? ""
        self.note = data[FirebaseConstants.note] as? String ?? ""
    }
}

struct CategoryDetails: Identifiable {

    var id: String { documentID }
    
    let documentID: String
    
    var categoryName: String
    
    init(documentID: String, data: [String: Any]){
        self.documentID = documentID
        self.categoryName = data[FirebaseConstants.name] as? String ?? ""
    }
}

