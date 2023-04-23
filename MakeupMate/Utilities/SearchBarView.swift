//
//  SearchBar.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 22/04/2023.
//

/*
  The design of the custom search bar has been resued + edited from: https://www.youtube.com/watch?v=p-arH7VO4jk&ab_channel=SwiftfulThinking
 
  A custom search bar was used as the swift method .searchable, only works with List views. Which has not been used in my code, a custom search bar allowed me to keep the design of my Inventory and Wishlist views.
 
  A Binding variable, searchText has been used to make the text in the TextField accesisible to the other views.
 */

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for products..", text: $searchText)
                .disableAutocorrection(true)
                .overlay(
                    // To get rid of text in Textfield
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundColor(.gray)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture{
                            searchText = ""
                        }
                    , alignment: .trailing
            )
            
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 0)
        )
        .padding()
        
    }
    
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
    }
}
