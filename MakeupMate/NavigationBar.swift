//
//  NavigationBar.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 15/03/2023.
//

import SwiftUI

struct NavigationBar: View {
    
    @State var selectedIndex = 0
    
    let tabBarImageNames = ["bag", "cart", "speedometer", "calendar"]
    
    var body: some View {
        VStack {
            
            ZStack {
                switch selectedIndex {
                case 0:
                    InventoryView()
                case 1:
                    Text("Wishlist")
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

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
    }
}
