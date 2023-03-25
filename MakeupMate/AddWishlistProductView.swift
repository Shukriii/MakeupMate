//
//  AddWishlistProductView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 22/03/2023.
//

import SwiftUI

struct AddWishlistProductView: View {
    
    @State var image: UIImage?
    @State private var name = ""
    @State private var brand = ""
    @State private var categoryField = ""
    @State private var shade = ""
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
                        
                        AddTextFieldView(AddDisplayName: "Note", AddVariableName: $note)
                        
                    }
                    .padding(12)
                    
                    HStack{
                        Button{
                            af.addProduct(fromCollection: "wishlist", name: name, brand: brand, categoryField: categoryField, note: note, image: image, presentationMode: presentationMode)
                            //addProduct()
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 30))
                                .foregroundColor(Color("Colour5"))
                        }
                    }
                }
            }.navigationTitle("New Wishlist Product")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
}

struct AddWishlistProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddWishlistProductView()
    }
}
