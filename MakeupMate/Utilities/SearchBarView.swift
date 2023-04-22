//
//  SearchBar.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 22/04/2023.
//

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
