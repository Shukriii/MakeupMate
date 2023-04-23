//
//  BottomNavigationBar.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 15/03/2023.
//

/*
 To create the bottom navigation bar the author resued the code from this tutorial: https://www.youtube.com/watch?v=9lVLFlyaiq4
 
 Small edits such as variable names and icons used were made. 
 */

import SwiftUI

struct BottomNavigationBar: View {
    
    @State var selectedIndex = 0
    
    // SF Symbols being used
    let tabBarImageNames = ["bag", "wand.and.stars.inverse", "speedometer", "calendar"]
    
    var body: some View {
        VStack {
            // uses a Zstack to place views on top of each other
            ZStack {
                switch selectedIndex {
                case 0:
                    InventoryView()
                case 1:
                    WishlistView()
                case 2:
                    CompareView()
                case 3:
                    ExpiryCalendarView()
                default:
                    InventoryView()
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

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigationBar()
    }
}
