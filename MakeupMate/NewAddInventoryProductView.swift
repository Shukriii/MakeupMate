//
//  NewDesign.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 09/04/2023.
//

// Stepper https://www.youtube.com/watch?v=jrAA9Gt-jqw&t=300s&ab_channel=DesignCode
// Hidden expiry date https://www.youtube.com/watch?v=Utkdlpo8T6w&ab_channel=GoingWalkabout
import SwiftUI
import SDWebImageSwiftUI

struct NewAddInventoryProductView: View {
    
    @State var image: UIImage?
    @State private var name = ""
    @State private var brand = ""
    @State private var categoryField = ""
    @State private var shade = ""
    @State private var stock = ""
    @State private var stockInt = 1
    @State private var expiryDate = Date.now
    @State private var expiryDateString = ""
    @State private var note = ""
    @State private var dateSet = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var shouldShowImagePicker = false
    
    @State private var selectedCategory: CategoryDetails?
    @ObservedObject private var af = AddFunctionalityViewModel()
    
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
                }
                
                Section(header: Text("Product Brand")){
                    TextField("E.g. MAC", text: $brand)
                }
                
                Section(header: Text("Product Shade")){
                    TextField("E.g. News Flash", text: $shade)
                }
                
                Section(header: Text("Product Category"), footer: Text("Click to select a category")){
                    NavigationLink(destination: CategoryView(selectedCategory: $selectedCategory)) {
                        HStack {
                            Text(categoryField.isEmpty ? "E.g. Powder Blushes" : categoryField)
                                .foregroundColor(categoryField.isEmpty ? Color(red: 0.784, green: 0.784, blue: 0.793) : Color.black)
                        }
                        .onAppear {
                            if let category = selectedCategory {
                                categoryField = category.categoryName
                            }
                        }
                    }
                }
                
                Section(header: Text("Product Stock"), footer: Text("How many items of the product you own")){
                    Stepper(value: $stockInt, in: 1...100){
                        Text("\(stockInt) item\(stockInt > 1 ? "s" : "")")
                    }
                }
                
                Section(header: Text("Product Expiry Date"), footer: Text("The date the product will expire")){
                    // True display expiry date
                    if(dateSet){
                        HStack {
                            DatePicker(selection: $expiryDate, in: ...Date.distantFuture, displayedComponents: .date) {
                                Text("Expiry Date")
                            }
                            //Button to get rid of date
                            Button {
                                dateSet.toggle()
                                //expiryDateString = ""
                                print("expiry date has been removed")
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .frame(width: 20, height: 20, alignment: .center)
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                    else {
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
                    }
                    
                }
                
                //try to make bigger
                Section(header: Text("Note")){
                    TextField("E.g. Running out soon", text: $note)
                }
                
                Section{
                    Button {
                        image = nil
                    } label: {
                        Text("Remove Photo")
                    }
                    .foregroundColor(.red)
                    
                    Button{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd MMM yyyy 'at' HH:mm:ss zzz"

                        // if false no date has been picked
                        if (!dateSet) {
                            expiryDateString = ""
                            print("in if")
                        } else {
                            expiryDateString = dateFormatter.string(from: expiryDate)
                            print("in else")
                        }
                        
                        let stock = String(stockInt)
                        
                        if (name == "") {
                            af.displayMessage(title: "Add Name", message: "A product must have a name.")
                        } else if (categoryField == "") {
                            af.displayMessage(title: "Add Category", message: "A product must have a category.")
                        } else {
                            // uses variable af to access the class and passes the varibles into addProduct
                            af.uploadProduct(fromCollection: "inventory", name: name, brand: brand, categoryField: categoryField, shade: shade, stock: stock, expiryDateString: expiryDateString, note: note, image: image, presentationMode: presentationMode)
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
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: nil){
            // Displays the users photo library to select an image
            ImagePicker(image: $image)
        }
    }
}

struct NewDesign_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}

