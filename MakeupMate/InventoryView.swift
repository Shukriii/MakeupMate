//
//  InventoryView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 04/03/2023.
//

import SwiftUI

struct InventoryView: View {
    
    @State var shouldShowLogOutOptions = false
    
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
                Image(systemName: "gear") // change icon
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text ("Settings"),
                  message: Text("Are you sure you want to sign out?"),
                  buttons: [.destructive(Text("Sign Out"), action: {
                    print("handle sign out")}),
                            .cancel()])
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
            
                topNavigationBar
                
                productListView
    
            }
            .overlay(
                newProductButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    // listing of products
    private var productListView: some View {
        ScrollView {
            //show 10 products need to change later
            ForEach(0..<10, id: \.self) {num in
                VStack{
                    HStack {
                        //Text("Product image")
                        Image(systemName: "person.fill").font(.system(size:32))
                        VStack (alignment: .leading){
                            Text("Product Name")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Product Shade")
                                .foregroundColor(Color(.lightGray))
                            Text("Product Brand")
                        }

                        Spacer ()
                        Text ("Edit button")
                    }
                    Divider()
                        .padding(.vertical, 5)
                }.padding(.horizontal)
            }.padding(.bottom, 50)
   
        }
    }
    
    // new product button
    private var newProductButton: some View {
        Button {
            
        }
        label: {
            
        HStack {
            Spacer()
            Text ("New Product")
                .font(.system(size: 16, weight: .bold))
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.vertical)
            .background(Color.purple)
            .cornerRadius(32)
            .padding(.horizontal, 100) // needs to moved right
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
