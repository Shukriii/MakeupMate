//
//  CategoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 24/03/2023.
//

/*
  This view displays all the categories and gives users the option to add and delete a category
 
  The code for alertView has been reused from: https://www.youtube.com/watch?v=NJDBb4sOfNE&ab_channel=Kavsoft
 */

import SwiftUI

struct CategoryView: View {
    
    @State private var categoryName = ""
    @Binding var selectedCategory: CategoryDetails?
    
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject private var af = AddFunctionalityViewModel()
    
    var body: some View {
        VStack {
            Form {
                ForEach (af.categories) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(category.categoryName)
                    }
                }.onDelete(perform: delete)
            }
            .navigationBarTitle("Pick a Category")
            .navigationBarItems(trailing: Button(action: {
                alertView()
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color("Colour5"))
                    .imageScale(.large)
            }))
            .onAppear{
                // calls the fethcCategory funtion
                af.fetchCategories()
            }
            
            Text("Swipe a category to delete it")
                .font(.callout)
        }
        .background(Color(red: 0.949, green: 0.949, blue: 0.97))
    }
    
    // This fucntion displays an alert on screen and calls the storeCategory function
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
    
    // Using the categoryName it adds a new document to the collection "categories"
    private func storeCategory(){
        print(categoryName)
        let categoryData = ["Name": categoryName] as [String : Any]
            
        FirebaseManager.shared.firestore.collection("categories").document().setData(categoryData) { error in
            if let error = error {
                print("Failed to save category: \(error)")
                return
                
            }
            print ("Successfully added the category")
        }
    }
    
    // This function removes the document from Firestore and remove the category from the array of categories
    private func delete(at offsets: IndexSet) {
        
        offsets.forEach { index in
            let category = af.categories[index]
            FirebaseManager.shared.firestore.collection("categories").document(category.id).delete { error in
                if let error = error {
                    print("Failed to delete:", error)
                    return
                } else {
                    print("Category deleted")
                }
            }
        }
        af.categories.remove(atOffsets: offsets)
    }
    
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
} 

