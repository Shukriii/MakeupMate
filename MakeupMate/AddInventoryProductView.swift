//
//  AddInventoryProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/03/2023.
//

/*
  InventoryView calls this function when the New Product button is clicked
  
  No code has been copied directly
  Tutorials used -
  Adding a DatePicker (Calendar): https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-date-picker-and-read-values-from-it
 */

import Firebase
import SwiftUI
import SDWebImageSwiftUI

// This struct creates the view and uses variable to store the details entered
struct AddInventoryProductView: View {
    
    @State var image: UIImage?
    @State private var name = ""
    @State private var brand = ""
    @State private var categoryField = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var expiryDate = Date.now
    @State private var expiryDateString = ""
    @State private var note = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var shouldShowImagePicker = false
    
    @State private var selectedCategory: CategoryDetails?
    
    @ObservedObject private var af = AddFunctionalityViewModel()
    
    var body: some View {
        VStack {
            ScrollView{
                VStack {
                    HStack{
                        // The boolean becomes true and the Image Picker is displayed
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "photo").font(.system(size:120))
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack (spacing: 16){
                        
                        // Using the struct to create TextFields
                        AddTextFieldView(AddDisplayName: "Name", AddVariableName: $name)
                        
                        AddTextFieldView(AddDisplayName: "Brand", AddVariableName: $brand)
                        
                        //TODO: Add category dropdow or make it a new view - Main Product
                        NavigationLink(destination: CategoryView(selectedCategory: $selectedCategory)) {
                            HStack {
                                Text("Click to pick a category")
                                
                            }
                            .padding(.horizontal)
                            .cornerRadius(5)
                        }
                        
                        if let category = selectedCategory {
                            VStack (alignment: .leading) {
                                
                                if !category.categoryName.isEmpty {
                                    Text("Category")
                                        .font(.subheadline)
                                        .foregroundColor(.purple)
                                }
                                TextField("Category", text: $categoryField)
                                    .onAppear {
                                        categoryField = category.categoryName.isEmpty ? "" : category.categoryName
                                    }
                            }
                            .padding(15)
                            .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                            .cornerRadius(5)
                        }
                        
                        AddTextFieldView(AddDisplayName: "Shade", AddVariableName: $shade)
                        
                        AddTextFieldView(AddDisplayName: "Stock", AddVariableName: $stock)
                        
                        //EXPIRY DATE
                        //TODO: Let no date be an option
                        VStack {
                            DatePicker(selection: $expiryDate, in: ...Date.distantFuture, displayedComponents: .date) {
                                Text("Expiry Date")
                            }
                        }
    
                        AddTextFieldView(AddDisplayName: "Note", AddVariableName: $note)
                    }
                    .padding(12)
                    
                    HStack{
                        Button{
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd MMM yyyy 'at' HH:mm:ss zzz"

                            let expiryDateString = dateFormatter.string(from: expiryDate)
                            
                            // uses variable af to access the class and passes the varibles into addProduct
                            af.uploadProduct(fromCollection: "inventory", name: name, brand: brand, categoryField: categoryField, shade: shade, stock: stock, expiryDateString: expiryDateString, note: note, image: image, presentationMode: presentationMode)
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 30))
                                .foregroundColor(Color("Colour5"))
                        }
                    }
                }
            }.navigationTitle("New Inventory Product")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil){
            // Displays the users photo library to select an image
            ImagePicker(image: $image)
        }
    }
    
}
    
struct InventoryProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddInventoryProductView()
    }
}
