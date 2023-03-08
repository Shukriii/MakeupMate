//
//  InventoryProducts.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/03/2023.
//

import Foundation

struct InventoryProducts: Identifiable {
    
    var id: String { uid }
    
    let uid, name, brand, category, shade, stock, expiryDate, note: String
    
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.brand = data["brand"] as? String ?? ""
        self.category = data["catgory"] as? String ?? ""
        self.shade = data["shade"] as? String ?? ""
        self.stock = data["stock"] as? String ?? ""
        self.expiryDate = data["expiryDate"] as? String ?? ""
        self.note = data["note"] as? String ?? ""
    }
} 
