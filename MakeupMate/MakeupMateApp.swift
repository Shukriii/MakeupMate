//
//  MakeupMateApp.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/02/2023.
//

import SwiftUI

@main
struct MakeupMateApp: App {
    var body: some Scene {
        WindowGroup {
            BottomNavigationBar()
        }
    }
}

// Code to be used once login is removed and core storage is used instead of firebase
//TabView {
//    InventoryView()
//        .tabItem {
//            Label("Inventory", systemImage: "bag")
//        }
//    WishlistView()
//        .tabItem {
//            Label("Wishlist", systemImage: "wand.and.stars.inverse")
//        }
//    CompareView()
//        .tabItem {
//            Label("Compare", systemImage: "speedometer")
//        }
//}
