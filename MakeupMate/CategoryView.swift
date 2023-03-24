//
//  CategoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 24/03/2023.
//

import SwiftUI

struct CategoryView: View {
    
    @State private var showAlert = false
    @State private var categoryName = ""
    
    var body: some View {
        NavigationView {
            
            Form {
                ForEach (0..<10) { num in
                    Text("Category")
                    
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
            print(categoryName)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (_) in
            print("Cancel")
            
        }
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
            
        })
    }
}

/*
 .alert(isPresented: $showingAlert) {
     Alert(title: Text("Add Category"), message: Text("Enter a name for the category"), primaryButton: .default(Text("Save")) {
         // Save the category here
         print("Category saved: \(self.category)")
     }, secondaryButton: .cancel())
 }
 


struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(, dismissAction: <#() -> Void#>)
    }
} */
