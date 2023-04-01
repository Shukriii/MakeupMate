//
//  TopNavigationBar.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

import SwiftUI

/*
 - Displays title of view and an icon to logout
 - Uses the boolean isUserCurrentlyLoggedOut to check wether the user is logged in. If not it uses the closure didCompleteLoginProcess to all the functions to populate the view.
 
 -  Adapted from this video: https://www.youtube.com/watch?v=pPsKTTd55xI&list=PL0dzCUj1L5JEN2aWYFCpqfTBeVHcGZjGw&index=6&ab_channel=LetsBuildThatApp
 */

struct TopNavigationBar: View {

    var navigationName: String
    
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var am = AccountFunctionalityViewModel()
    
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
        // When the shouldShowLogOutOptions is true a sheet appears with the option to Sign out
        // The AccountFunctionalityViewModel handles the sign out 
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text ("Settings"),
                  message: Text("Are you sure you want to sign out?"),
                  buttons: [.destructive(Text("Sign Out"), action: {
                am.handleSignOut()
            }),
                            .cancel()])
        }
    }
}
