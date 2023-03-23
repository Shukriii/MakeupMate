//
//  NavigationBar.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 15/03/2023.
//

/*
 https://www.youtube.com/watch?v=9lVLFlyaiq4
 */

import SwiftUI

struct NavigationBars: View {
    
    @State var selectedIndex = 0
    
    let tabBarImageNames = ["bag", "cart", "speedometer", "calendar"]
    
    var body: some View {
        VStack {
            
            ZStack {
                switch selectedIndex {
                case 0:
                    InventoryView()
                case 1:
                    WishlistView()
                case 2:
                    Text("Compare")
                case 3:
                    Text("Calendar")
                default:
                    Text("Remaining tabs")
                }
            }
            
            Spacer()
            
            Divider()
            HStack {
                ForEach(0..<4) { num in
                    Button(action: {
                        selectedIndex = num
                    }, label: {
                        Spacer()
                        Image(systemName: tabBarImageNames[num])
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color("Colour5"))
                        Spacer()
                    }).padding(.top, 5.0)
                }
            }
        }
    }
}

// Displays title of view and a button to logout, it also uses the boolean isUserCurrentlyLoggedOut to check wether the user is logged in. If not it uses the closure didCompleteLoginProcess to all the functions to populate the view.
// Adapted from Video 1
struct topNavigationBar: View {
    
    @State var shouldShowLogOutOptions = false
    var navigationName: String
    
    @ObservedObject private var vm = ViewModel(collectionName: "wishlist")// OKAY?
    
    var body: some View {
        HStack{
            Text(navigationName)
                .font(.system(size: 24, weight: .bold))
            
            Spacer()
            
            // Profile icon button, which allows users to log out
            Button{
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "person")
                    .font(.system(size: 30))
                    .foregroundColor(Color("Colour5"))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text ("Settings"),
                  message: Text("Are you sure you want to sign out?"),
                  buttons: [.destructive(Text("Sign Out"), action: {
                vm.handleSignOut()
            }),
                            .cancel()])
        }
        
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBars()
    }
}
