//
//  CompareView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 26/03/2023.
//

/*
 https://www.youtube.com/watch?v=0LrP6dv8tHY&ab_channel=JamesHaville
 */
import SwiftUI

struct CompareView: View {
    
    @State private var isExpanded = false
    @State private var selectedCategory = ""
    @State private var categoryID = ""
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var am = AccountFunctionalityViewModel()
    @ObservedObject private var af = AddFunctionalityViewModel()
    
    @State var categories = [CategoryDetails]()
    @State var category: CategoryDetails?

    var body: some View {
        NavigationView {
            VStack (alignment: .leading, spacing: 15){
                
                TopNavigationBar(navigationName: "Compare")
                    .fullScreenCover(isPresented: $am.isUserCurrentlyLoggedOut, onDismiss: nil){
                        LoginView(didCompleteLoginProcess: {
                            self.am.isUserCurrentlyLoggedOut = false
                            self.am.fetchCurrentUser()
                            
                        })
                    }
                
                displayView
                
            }.navigationBarHidden(true)
        }
    }
        
    private var displayView: some View {
        ScrollView {
            VStack {
                Text("Select a category below").padding()
                
                DisclosureGroup("\(selectedCategory)", isExpanded: $isExpanded) {
                    ScrollView {
                        VStack {
                            ForEach(af.categories) { category in
                                Text("\(category.categoryName)")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .onTapGesture {
                                        self.selectedCategory = category.categoryName
                                        self.categoryID = category.documentID
                                        withAnimation {
                                            self.isExpanded .toggle()
                                            fetchCategoryProducts()
                                        }
                                    }
                            }
                        }
                    }.frame(height: 180)
                }
                .padding()
                .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                .cornerRadius(8)
                
                // Spacer()
                
                Text("Display categories here")
            }
            .padding(.horizontal)
            
            HStack{
                VStack {
                    Text("Inventory")
                        .bold()
                    Text("Coloumn 1")
                
                }
                
                Spacer()
                
                VStack {
                    Text("Wishlist")
                        .bold()
                    
                }
            }
            .padding()
            
            ForEach(categories) { category in
                    Text(category.categoryName)
                }
        }
        
    }
    @State var statusMessage = ""
    
    private func fetchCategoryProducts() {
        FirebaseManager.shared.firestore.collection("categories").getDocuments { documentsSnapshot,
            error in
            if let error = error {
                self.statusMessage = "Failed to fetch inventory product: \(error)"
                print(statusMessage)
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                print("data")
                self.categories.append(.init(documentID: snapshot.documentID, data: data))
                print(categories)
            })
            self.statusMessage = "Fetched products successfully"
            print(statusMessage)
            
        }
    }
    
    private func findCategoryProducts(){
        categoryID = self.categoryID
        
        FirebaseManager.shared.firestore.collection("categories").document(categoryID).getDocument { snapshot,
            error in
            if let error = error {
                self.statusMessage = "Failed to fetch inventory product: \(error)"
                print(statusMessage)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found")
                return }
            
            print(data)
            self.category = CategoryDetails(documentID: categoryID, data: data)
            //print(self.category)
        }
    }
        
}

struct CompareView_Previews: PreviewProvider {
    static var previews: some View {
        CompareView()
    }
}
