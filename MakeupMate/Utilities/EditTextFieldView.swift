//
//  TextFieldView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

/*
 A struct to display the Textfield when a product is being edited.
 It first checks if the product key being passed in is empty, if not is displays the name in a purple subheading text. This has been done so the user knows what the textfield is for. 
 */

import SwiftUI

struct EditTextFieldView: View {
    
    var listKey: String //product.name
    var displayName: String //"Name"
    
    @Binding var variableName: String //name
    
    var body: some View {
        TextField(displayName, text: $variableName)
            .onAppear {
                variableName = listKey.isEmpty ? "" : listKey
            }
    }
}




