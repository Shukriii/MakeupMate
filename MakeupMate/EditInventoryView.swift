//
//  EditInventoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 11/04/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditInventoryView: View {
    
    @State private var selectedCategory: CategoryDetails?
    @State var product: ProductDetails?
    let productID: String

    init(productID: String) {
        self.productID = productID
        self._product = State(initialValue: nil)
    }
    
    @State private var name = ""
    @State private var brand = ""
    @State private var category = ""
    @State private var categoryField = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var stockInt = 1
    @State private var expiryDate = Date.now
    @State private var expiryDateString = ""
    @State private var note = ""
    @State var image: UIImage?
    
    @State var shouldShowImagePicker = false
    @State var goesToCategories = false
    @State private var dateSet = false

    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var ef = EditFunctionalityViewModel()
    
    var body: some View {
        VStack {
            Form {
                
                Section(footer: Text("Click to add a photo")){
                    // The boolean becomes true and the Image Picker is displayed
                    Button {
                        shouldShowImagePicker.toggle()
                    } label: {
                        VStack {
                            if let product = ef.product {
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .scaledToFill()
                                    // if product.image is not empty display the products image
                                } else if !product.image.isEmpty {
                                    WebImage(url: URL(string: product.image))
                                        .resizable()
                                        .frame(width: 180, height: 180)
                                        .scaledToFill()
                                    // else display the photo
                                } else {
                                    Image(systemName: "photo").font(.system(size:120))
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .listRowInsets(EdgeInsets())
                .background(Color(red: 0.949, green: 0.949, blue: 0.97))
                
                
                if let product = ef.product {
                    
                    Section(header: Text("Product Name")){
                        EditTextFieldView(listKey: product.name, displayName: "Name", variableName: $name)
                    }
                    
                    Section(header: Text("Product Brand")){
                        EditTextFieldView(listKey: product.brand, displayName: "Brand", variableName: $brand)
                    }
                    
                    Section(header: Text("Product Shade")){
                        EditTextFieldView(listKey: product.shade, displayName: "Shade", variableName: $shade)
                    }

                    Section(header: Text("Product Category"), footer: Text("Click to select a category")){
                        NavigationLink(destination: CategoryView(selectedCategory: $selectedCategory)) {
                            if let selectedCategory = selectedCategory {
                                Text(selectedCategory.categoryName)
                            }
                            else if !product.category.isEmpty {
                                Text(product.category)
                            }
                        }
                    }
                    
                    Section(header: Text("Product Stock"), footer: Text("How many items of the product you own")){
                        
                        Stepper(value: $stockInt, in: 1...100){
                            Text("\(stockInt) item\(stockInt > 1 ? "s" : "")")
                        }
                        .onAppear() {
                            stockInt = Int(product.stock) ?? 0
                        }
                    }
                    
                    Section(header: Text("Product Expiry Date"), footer: Text("The date the product will expire")){
                        
                        // Display expiry date picker
                        if(!product.expiryDate.isEmpty && !dateSet){
                            HStack {
                                DatePicker(selection: $expiryDate, in: ...Date.distantFuture, displayedComponents: .date) {
                                    Text("Expiry Date")
                                }
                                .onAppear {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd MMM yyyy 'at' HH:mm:ss zzz"
                                    if let date = dateFormatter.date(from: product.expiryDate) {
                                        expiryDate = date
                                        print(expiryDate)
                                    }
                                }
                                //Button to get rid of date
                                Button {
                                    dateSet.toggle()
                                    print("product.expiry date has been removed")
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .foregroundColor(Color.gray)
                                }
                            }
                        } else if(dateSet) {
                            // Display button with "<tap to set>" message
                            Button {
                                print("expiry date picked")
                                dateSet.toggle()
                            } label : {
                                HStack {
                                    Text("Expiry Date")
                                    Spacer()
                                    Text("<tap to set>")
                                }
                                .padding(.vertical, 7)
                            }
                        } else {
                            HStack {
                                DatePicker(selection: $expiryDate, in: ...Date.distantFuture, displayedComponents: .date) {
                                    Text("Expiry Date")
                                }
                                //Button to get rid of date
                                Button {
                                    dateSet.toggle()
                                    print("expiry date has been removed")
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .foregroundColor(Color.gray)
                                }
                            }
                        }
                    }

                    Section(header: Text("Note")){
                        EditTextFieldView(listKey: product.note, displayName: "Note", variableName: $note)
                    }
                    
                    Section{
                        // IMAGE
                        Button {
                            image = nil
                            ef.product?.image = ""
                        } label: {
                            Text("Remove Photo")
                        }
                        
                        // DELETE
                        Button {
                            ef.deleteProduct(fromCollection: "inventory", productID: productID, presentationMode: presentationMode)
                        } label: {
                            Text("Delete Product")
                        }
                        .foregroundColor(.red)
                        
                        // SAVE
                        Button{
                            // for category
                            if let product = ef.product {
                                // if a category has been picked from the dropdown then category = selectedCategory
                                if let selectedCategory = selectedCategory {
                                    self.category = selectedCategory.categoryName
                                // if a category hasn't been chosen then category = product.category 
                                } else if !product.category.isEmpty {
                                    self.category = product.category
                                }
                            }
                            
                            // for stock
                            let stock = String(stockInt)
                            
                            // for expiry date
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd MMM yyyy 'at' HH:mm:ss zzz"
                            
                            let date = dateFormatter.date(from: product.expiryDate)

                            let calendar = Calendar.current
                            _ = calendar.dateComponents([.year, .month, .day], from: expiryDate)
                            _ = calendar.dateComponents([.year, .month, .day], from: Date.now)
                            

                            if calendar.isDate(expiryDate, inSameDayAs: date ?? Date.now) {
                                expiryDateString = ""
                                print("in if")
                            } else {
                                expiryDateString = dateFormatter.string(from: expiryDate)
                                print("in else")
                            }
                            
                            ef.uploadImageToStorage(fromCollection: "inventory", productID: productID, name: name, brand: brand, categoryField: category, shade: shade, stock: stock, expiryDateString: expiryDateString, note: note, image: image, presentationMode: presentationMode)
                            
                        } label: {
                            Text("Save Product")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Edit Product")
            .onAppear {
                // Load the product details from Firestore
                ef.fetchProduct(fromCollection: "inventory", productID: productID)
            }
        }
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            // Displays the users photo library to select an image
            ImagePicker(image: $image)
        }
    }
}

struct EditInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}

