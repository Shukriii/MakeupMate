//
//  AddTextFieldView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//


// THIS CODE IS NOT BEING USED BY THE APPLICATION
// HAS BEEN ARCHIVED, WAS CREATED DURING THE DEVLEOPMENT OF MAKEUPMATE

/*
  Displays a Textfield to enter a products details
 
  Floating label for text boxes reused from: https://www.youtube.com/watch?v=Sg0rfYL3utI&t=649s&ab_channel=PeterFriese
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
