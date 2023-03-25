//
//  AddTextFieldView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

/*
 A resuable View, displaying a Textfield to enter a products details
 */

import SwiftUI

struct AddTextFieldView: View {
    
    var AddDisplayName: String //"Name"
    
    @Binding var AddVariableName: String //name
    
    var body: some View {
        
        VStack (alignment: .leading) {
            if !AddVariableName.isEmpty {
                Text(AddDisplayName)
                    .font(.subheadline)
                .foregroundColor(.purple)
            }
            TextField(AddDisplayName, text: $AddVariableName)
        }
        .padding(15)
        .background(Color(red: 0.914, green: 0.914, blue: 0.914))
        .cornerRadius(5)
    }
    
}

