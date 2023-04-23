//
//  DateValue.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/04/2023.
//

/*
  The Structs used to create the calendar and fuction getProductExpireDateFromDateString were adpated from - https://www.youtube.com/watch?v=UZI2dvLoPr8&ab_channel=Kavsoft
  
  The OO ExpiryProductViewModel fetches the products from Firestore and places them into the array expiredProducts of type ExpiryProductMetaData which is used by CalendarDisplayView
 */

import SwiftUI

// This struct is used to hold the date value model
// The extractDate function uses it to return a day and a date depending on the current month
struct DateValue: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

// The variables are later used to place the data fetched, from the fetched product data only the productID, name, shade, brand are needed
struct ExpiryProduct: Identifiable{
    var id = UUID().uuidString
    var productID: String
    var name: String
    var shade: String
    var brand: String
}

// The expire date for the product is stored serapetly from the array ExpireProduct, into expireDate
struct ExpiryProductMetaData: Identifiable {
    var id = UUID().uuidString
    var expiryProduct: [ExpiryProduct]
    var expireDate: Date
}

// This function take product.expireDate which is a String and returns a Date
func getProductExpireDateFromDateString(dateString: String) -> Date {
    
    // E.g. takes the date "28 Apr 2023 at 14:47:00 GMT+1" and make into "28 Apr 2023"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy"
    
    // stores the Date formart of product.expiryDate into date
    guard let date = dateString.components(separatedBy: " at ").first.flatMap({ dateFormatter.date(from: $0) })
        // Provide a default value in case date calculation fails
        else { return Date() }
    
    // Figures out offset from todays date to the product.expiry date variable
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let otherDate = calendar.startOfDay(for: date)
    let components = calendar.dateComponents([.day], from: today, to: otherDate)

    // Calculates expire date using the offset
    let calendarNow = Calendar.current
    
    // the Date to appear on the calendar is stored into productExpireDate
    let productExpireDate = calendarNow.date(byAdding: .day, value: components.day!, to: Date())
    
    // return a default value in case product expire date calculation fails
    return productExpireDate ?? Date()
}

class ExpiryProductViewModel: ObservableObject {
    
    @Published var statusMessage = ""
    @Published var products = [ProductDetails]()
    @Published var expiredProducts = [ExpiryProductMetaData]()
    
    init(){
        fetchExpiryProducts()
    }
    
    func fetchExpiryProducts() {
        // START - The following code was been reused from FetchFunctionalityViewModel. Was unable to reuse the fetchProducts function
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
                
                // checks if a product has a expire date, if not it removed the array products
                for product in self.products {
                    if product.expiryDate.isEmpty {
                        if let index = self.products.firstIndex(where: { $0.documentID == product.documentID }) {
                            self.products.remove(at: index)
                            
                        }
                    }
                }
                // END
                
                // the array is emptied, so when the function is recalled it doesnt keep appending products
                self.expiredProducts = []
                
                // places the products into the expiredProducts array
                self.products.forEach { product in
                    // the product data is placed into ExpiryProduct array
                    // a Date is returned by getProductExpireDateFromDateString and it is placed into expireDate
                    self.expiredProducts.append(ExpiryProductMetaData(expiryProduct: [
                        ExpiryProduct(productID: product.id, name: product.name, shade: product.shade, brand: product.brand),
                    ], expireDate: getProductExpireDateFromDateString(dateString: product.expiryDate)))
                }
            }
    }
    
}
