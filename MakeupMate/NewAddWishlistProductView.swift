//
//  NewAddWishlistProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 14/04/2023.
//

/*
  The file is the authors' own code . It provides the user with the view to add a wishlist product.
  Sections have been used to create the design of the view.
 */
 
import SwiftUI

struct NewAddWishlistProductView: View {
    
    @State var image: UIImage?
    @State private var name = ""
    @State private var brand = ""
    @State private var categoryField = ""
    @State private var shade = ""
    @State private var webLink = ""
    @State private var note = ""
    
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
                    TextField("E.g. Concealer", text: $name)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Product Brand")){
                    TextField("E.g. Too Faced", text: $brand)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Product Shade")){
                    TextField("E.g. Chestnut", text: $shade)
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
                
                Section(header: Text("Product URL")){
                    TextField("https://www.boots.com", text: $webLink)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Note")){
                    TextField("Note", text: $note)
                        .disableAutocorrection(true)
                }
                
                Section{
                    // remove photo button
                    Button {
                        image = nil
                    } label: {
                        Text("Remove Photo")
                    }
                    .foregroundColor(.red)
                    
                    // save product button
                    Button{
                        // if product name is emoty display the alert
                        if (name == "") {
                            cf.displayMessage(title: "Add Name", message: "A product must have a name.")
                        // if product category is empty display the alert
                        } else if (categoryField == "") {
                            cf.displayMessage(title: "Add Category", message: "A product must have a category.")
                        // save the product
                        } else {
                            // uses variable af to access the class and passes the varibles into addProduct
                            af.uploadProduct(fromCollection: "wishlist", name: name, brand: brand, categoryField: categoryField, shade: shade, webLink: webLink, note: note, image: image, presentationMode: presentationMode)
                        }
                    } label: {
                        Text("Save Product")
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationBarTitle("New Wishlist Product")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: nil){
            // Displays the users photo library to select an image
            ImagePicker(image: $image)
        }
    }
}

struct NewAddWishlistProductView_Previews: PreviewProvider {
    static var previews: some View {
        NewAddWishlistProductView()
    }
}
