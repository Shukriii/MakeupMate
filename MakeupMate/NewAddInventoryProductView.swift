//
//  NewDesign.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 09/04/2023.
//

/*
  The file is the authors' own code other than where specificed. It provides the user with the view to add an inventory product.
  Sections have been used to create the design of the view.
 */

import SwiftUI
import SDWebImageSwiftUI

struct NewAddInventoryProductView: View {
    
    @State var image: UIImage?
    @State private var name = ""
    @State private var brand = ""
    @State private var categoryField = ""
    @State private var shade = ""
    @State private var note = ""
    @State private var dateSet = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var shouldShowImagePicker = false
    
    @State private var selectedCategory: CategoryDetails?
    @ObservedObject private var af = AddFunctionalityViewModel()
    @ObservedObject private var cf = CategoryFunctionalityViewModel()
    
    var body: some View {
        VStack {
            Form {
                
                Section(footer: Text("Click to add a photo")){
                    // The boolean becomes true and the Image Picker is displayed
                    Button {
                        shouldShowImagePicker.toggle()
                    } label: {
                        VStack {
                            if let image = self.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .scaledToFill()
                            } else {
                                Image(systemName: "photo.on.rectangle.angled").font(.system(size:120))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .listRowInsets(EdgeInsets())
                .background(Color(red: 0.949, green: 0.949, blue: 0.97))
                
                Section(header: Text("Product Name")){
                    TextField("E.g. Blush", text: $name)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Product Brand")){
                    TextField("E.g. MAC", text: $brand)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Product Shade")){
                    TextField("E.g. News Flash", text: $shade)
                        .disableAutocorrection(true)
                }
                
                // NavigationLink to CategoryView
                Section(header: Text("Product Category"), footer: Text("Click to select a category")){
                    NavigationLink(destination: CategoryView(selectedCategory: $selectedCategory)) {
                        HStack {
                            //displays categoryField if it is not empty, or the placeholder text
                            Text(categoryField.isEmpty ? "E.g. Powder Blushes" : categoryField)
                                .foregroundColor(categoryField.isEmpty ? Color(red: 0.784, green: 0.784, blue: 0.793) : Color.black)
                        }
                        // the categoryField being displayed is set to the category.categoryName, if a category has been selected
                        .onAppear {
                            if let category = selectedCategory {
                                categoryField = category.categoryName
                            }
                        }
                    }
                }
                
                Section(header: Text("Note")){
                    TextField("E.g. Running out soon", text: $note)
                        .disableAutocorrection(true)
                }
                
                // Buttons
                Section{
                    // Remove photo button
                    Button {
                        image = nil
                    } label: {
                        Text("Remove Photo")
                    }
                    .foregroundColor(.red)
                    
                    // Save product button
                    Button{
                        // Display an alert if the product name is empty
                        if (name == "") {
                            cf.displayMessage(title: "Add Name", message: "A product must have a name.") }
                        // Display an alert if the product category is empty
                        else if (categoryField == "") {
                            cf.displayMessage(title: "Add Category", message: "A product must have a category.") }
                        // Else save the product
                        else {
                            // uses variable af to access the class and passes the varibles into addProduct
                            af.uploadProduct(fromCollection: "inventory", name: name, brand: brand, categoryField: categoryField, shade: shade, note: note, image: image, presentationMode: presentationMode)
                        }

                    } label: {
                        Text("Save Product")
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationBarTitle("New Product")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // Displays the users photo library to select an image
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
}

struct NewDesign_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}


