//
//  DateValue.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/04/2023.
//

import SwiftUI


struct DateValue: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

// A expiry product has an Id, name and date
struct ExpiryProduct: Identifiable{
    var id = UUID().uuidString
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

var expiredProducts: [ExpiryProductMetaData] = [
    ExpiryProductMetaData(expiryProduct: [
        ExpiryProduct(name: "Product 1", shade: "1", brand: "1"),
        ExpiryProduct(name: "Product 2", shade: "2", brand: "2"),
        ExpiryProduct(name: "Product 3", shade: "3", brand: "3"),
    ], expireDate: getSampleDateFromDateString(dateString: "28 Apr 2023 at 14:47:00 GMT+1")),

    ExpiryProductMetaData(expiryProduct: [
        ExpiryProduct(name: "Product 4", shade: "4", brand: "4"),
    ], expireDate: getSampleDateFromDateString(dateString: "9 Apr 2023 at 14:47:00 GMT+1")),

    ExpiryProductMetaData(expiryProduct: [
        ExpiryProduct(name: "Product 5", shade: "5", brand: "5"),
    ], expireDate: getSampleDateFromDateString(dateString: "1 Apr 2023 at 14:47:00 GMT+1")),
]

//var expiredProducts2: [ExpiryProductMetaData] = []

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
    @Published var expiredProducts2 = [ExpiryProductMetaData]()
    
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
                })
                self.statusMessage = "Fetched expired products successfully"
                print (self.statusMessage)
                
                for product in self.products {
                    if product.expiryDate.isEmpty {
                        if let index = self.products.firstIndex(where: { $0.documentID == product.documentID }) {
                            self.products.remove(at: index)
                            
                        }
                    }
                }
                
                print("products with expiry date \(self.products)")

                self.products.forEach { product in
                    self.expiredProducts2.append(ExpiryProductMetaData(expiryProduct: [
                        ExpiryProduct(name: product.name, shade: product.shade, brand: product.brand),
                    ], expireDate: getSampleDateFromDateString(dateString: product.expiryDate)))
                }

            }
    }
    
}
