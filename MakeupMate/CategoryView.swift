//
//  CategoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 24/03/2023.
//

/*
 Alert with textfield https://www.youtube.com/watch?v=NJDBb4sOfNE&ab_channel=Kavsoft
 */

import SwiftUI

struct CategoryView: View {
    
    @State private var categoryName = ""
    @State private var showAlert = false
    @ObservedObject private var vm = ViewModel(collectionName: "inventory")
    
    @Binding var selectedCategory: CategoryDetails?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Form {
            ForEach (vm.categories) { category in
                CategoryRow(category: category)
                    .onTapGesture {
                        withAnimation {
                            selectedCategory = category
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
        .navigationBarTitle("Pick a Category")
        .navigationBarItems(trailing: Button(action: {
            alertView()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color.green)
                .imageScale(.large)
        }))
    }

    func alertView() {
        
        let alert = UIAlertController(title: "Add Category", message: "Enter the name of the new category:", preferredStyle: .alert)
        
        alert.addTextField{ (name) in
            name.placeholder = "Name"
        }
        
        //Buttons
        let save = UIAlertAction(title: "Save", style: .default) { (_) in
            // place textfield value into category
            categoryName = alert.textFields![0].text!
            //storeCategory()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (_) in
            print("Cancel")
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
        })
    }
    
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
}

struct CategoryRow: View {
    
    let category: CategoryDetails
    
    @ObservedObject private var vm = ViewModel(collectionName: "inventory")
    
    var body: some View {
        Text(category.categoryName)
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
} 
