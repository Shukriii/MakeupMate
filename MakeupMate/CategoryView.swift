//
//  CategoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 24/03/2023.
//

/*
  This view displays all the categories and gives users the option to add and delete a category
 
  Other than the alertView this is all the auhtors code
 
  The code for alertView has been reused from: https://www.youtube.com/watch?v=NJDBb4sOfNE&ab_channel=Kavsoft
    delete method learnt from - https://www.youtube.com/watch?v=2g1t15bwX44&ab_channel=PaulHudson
 */

import SwiftUI

struct CategoryView: View {
    
    @State private var categoryName = ""
    @Binding var selectedCategory: CategoryDetails?
    
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject private var cf = CategoryFunctionalityViewModel()
    @ObservedObject private var vim = FetchFunctionalityViewModel(collectionName: "inventory")
    @ObservedObject private var vwm = FetchFunctionalityViewModel(collectionName: "wishlist")
    
    var body: some View {
        VStack {
            Form {
                // Displays all the category, if a category is picked it is stored in selectedCategory and the view is dismissed
                ForEach (cf.categories) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(category.categoryName)
                    }
                }.onDelete(perform: delete) // deletes a category
            }
            .padding(.top, 0.3)
            .navigationBarTitle("Pick a Category")
            .navigationBarItems(trailing: Button(action: {
                // alert that lets user add a category
                alertView()
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color("Colour5"))
                    .imageScale(.large)
            }))
            .onAppear{
                // calls the fethcCategory function
                cf.fetchCategories()
            }
            
            Text("Swipe a category to delete it")
                .font(.callout)
        }
        .background(Color(red: 0.949, green: 0.949, blue: 0.97))
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Using the categoryName it adds a new document to the collection "categories"
    private func storeCategory(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        let categoryData = ["name": categoryName] as [String : Any]
            
        FirebaseManager.shared.firestore.collection("categories").document(uid).collection("categories").document().setData(categoryData) { error in
            if let error = error {
                print("Failed to save category: \(error)")
                return
                
            }
            print ("Successfully added the category")
        }
    }
    
    // This function removes the category document from Firestore and remove the category from the array of categories. But before checks if the category has any products
    private func delete(at offsets: IndexSet) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        offsets.forEach { index in
            let category = cf.categories[index]
            
            // if the category has products
            var hasInventoryProducts: Bool {
                vim.products.contains(where: { $0.category == category.categoryName })
            }
            
            var hasWishlistProducts: Bool {
                vwm.products.contains(where: { $0.category == category.categoryName })
            }
            
            // if category has prodcuts displays alert
            if (hasInventoryProducts || hasWishlistProducts){
                cf.displayMessage(title: "Error: Category Deletion Failed", message: "This category has products in it.")
            } else {
                // else delete the category
                FirebaseManager.shared.firestore.collection("categories").document(uid).collection("categories").document(category.id).delete { error in
                    if let error = error {
                        print("Failed to delete:", error)
                        return
                    } else {
                        print("Category deleted")
                    }
                }
                // remove from array
                cf.categories.remove(atOffsets: offsets)
            }
           
        }
    }
    
    // This fucntion displays an alert on screen, that allows the user to enter in a category and calls the storeCategory function
    private func alertView() {
        let alert = UIAlertController(title: "Add Category", message: "Enter the name of the new category:", preferredStyle: .alert)
        
        alert.addTextField{ (name) in
            name.placeholder = "Name"
        }
        
        //Buttons
        let save = UIAlertAction(title: "Save", style: .default) { (_) in
            // place textfield value into category
            categoryName = alert.textFields![0].text!
            storeCategory()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (_) in
            print("Cancel")
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
        })
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
} 

