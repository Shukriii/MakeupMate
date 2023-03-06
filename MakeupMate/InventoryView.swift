//
//  InventoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 04/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI

// observable object is used to fetch the user
class InventoryViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        /* uncomment later, this is functionality to sign in after logging out
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }*/
        
        fetchCurrentUser()
    }
    
    //fetchs the users id from sign using auth
    func fetchCurrentUser(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else {
            self.errorMessage = "Could not find firebase uid"
            return }
        
        //fetching the user from firestore users collection
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return }
            
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct InventoryView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = InventoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                //delete later on, for testing purposes
                Text ("Current User ID: \(vm.chatUser?.email ?? "")")

                topNavigationBar
                
                productListView
    
            }
            .overlay(
                newProductButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    // top navigation bar
    private var topNavigationBar: some View {
        HStack{
            
            Text("Your Inventory")
                .font(.system(size: 24, weight: .bold))
            Spacer()
            
            // settings icon button
            Button{
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "person")
                    .font(.system(size: 30))
                    .foregroundColor(Color("Colour5"))
            }
        }
        .padding()
        //pop up when person is clicked
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text ("Settings"),
                  message: Text("Are you sure you want to sign out?"),
                  buttons: [.destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                vm.handleSignOut()
            }),
                            .cancel()])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil){
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    // listing of products
    private var productListView: some View {
        ScrollView {
            //show 10 products need to change later
            ForEach(0..<10, id: \.self) {num in
                VStack{
                    HStack {
                        //Photo for product
                        Image(systemName: "photo").font(.system(size:30))
                        // Video 6, 25 minutes
                        //WebImage(url: URL(string: )).resizeable()
                        
                        VStack (alignment: .leading){
                            Text("Product Name")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Product Shade")
                                .foregroundColor(Color(.lightGray))
                            Text("Product Brand")
                        }

                        Spacer ()
                        
                        Button{
                            
                        } label: {
                            Image(systemName: "square.and.pencil") // change icon
                                .font(.system(size: 20))
                                .foregroundColor(Color(.label))
                        }
                        
                    }
                    Divider()
                        .padding(.vertical, 2)
                }.padding(.horizontal)
            }.padding(.bottom, 50)
   
        }
    }
    
    // new product button
    private var newProductButton: some View {
        Button {
        }
        label: {
            
            HStack() {
            Spacer()
            Text ("New Product")
                .font(.system(size: 16, weight: .bold))
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.vertical)
            //.background(Color.purple)
            .background(Color("Colour5"))
            .cornerRadius(32)
            .padding(.horizontal, 100)
        }
    }
}


struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InventoryView()
        }
    }
}
