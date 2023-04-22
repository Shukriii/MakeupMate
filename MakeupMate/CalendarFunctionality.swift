//
//  DateValue.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/04/2023.
//

import SwiftUI

struct CalendarFunctionality: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

// A expiry product has an Id, name and date
struct ExpiryProduct: Identifiable{
    var id = UUID().uuidString
    var productID: String
    var name: String
    var shade: String
    var brand: String
    var time : Date = Date()
}

struct ExpiryProductMetaData: Identifiable {
    var id = UUID().uuidString
    var expiryProduct: [ExpiryProduct]
    var expireDate: Date
}

func getSampleDateFromDateString(dateString: String) -> Date {
    // Takes the date "28 Apr 2023 at 14:47:00 GMT+1" and make into "28 Apr 2023"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy"
    guard let date = dateString.components(separatedBy: " at ").first.flatMap({ dateFormatter.date(from: $0) }) else {
        return Date() // Provide a default value in case date calculation fails
    }
    
    // Figures out offset
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let otherDate = calendar.startOfDay(for: date)
    let components = calendar.dateComponents([.day], from: today, to: otherDate)

    // Calculates sample date using the offset
    let calendarNow = Calendar.current
    
    let sampleDate = calendarNow.date(byAdding: .day, value: components.day!, to: Date()) //components.day ?? 0

    return sampleDate ?? Date() // Provide a default value in case sample date calculation fails
}

class ExpiryProductViewModel: ObservableObject {
    
    @Published var statusMessage = ""
    @Published var products = [ProductDetails]()
    @Published var expiredProducts = [ExpiryProductMetaData]()
    
    init(){
        fetchExpiryProducts()
    }
    
    func fetchExpiryProducts() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("products").document(uid).collection("inventory")
            .order(by: "name")
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    self.statusMessage = "Failed to fetch expired products: \(error)"
                    print(self.statusMessage)
                    return
                }
                
                // The snapshot listener querySnapshot listens for changes
                querySnapshot?.documentChanges.forEach( { change in
                    // if a category is added
                    if change.type == .added {
                        let data = change.document.data()
                        self.products.append(.init(documentID: change.document.documentID, data: data))
                    }
                    
                    //if product is deleted
                    if change.type == .removed {
                        if let index = self.products.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            self.products.remove(at: index)
                        }
                    }
                    // if a product is modified
                    if change.type == .modified {
                        if let index = self.products.firstIndex(where: { $0.documentID == change.document.documentID }) {
                            let data = change.document.data()
                            self.products[index] = .init(documentID:change.document.documentID, data: data)
                            }
                        }
                })
                self.statusMessage = "Fetched expired products successfully"
                print (self.statusMessage)
                
                // if product has no expire date, remove it from the list
                for product in self.products {
                    if product.expiryDate.isEmpty {
                        if let index = self.products.firstIndex(where: { $0.documentID == product.documentID }) {
                            self.products.remove(at: index)
                            
                        }
                    }
                }
                
                //print("products with expiry date \(self.products)")
                self.expiredProducts = []
                
                // place the prodcuts into the expiredProducts array
                self.products.forEach { product in
                    self.expiredProducts.append(ExpiryProductMetaData(expiryProduct: [
                        ExpiryProduct(productID: product.id, name: product.name, shade: product.shade, brand: product.brand),
                    ], expireDate: getSampleDateFromDateString(dateString: product.expiryDate)))
                    //print("expiredProductsList \(self.expiredProducts)")
                }

            }
    }
    
}
