//
//  TextFieldView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 25/03/2023.
//

/*
 Displays a TextField which is utilised when products are being editied.
 
 Uses Binding so the varibaleName is accesible by other views, this variable is first set to the product key, or the empty string.
 variableName is later used by views to store the updated information
 */

import SwiftUI

struct EditTextFieldView: View {

    var listKey: String //e.g. product.name
    var displayName: String //e.g, "Name"

    @Binding var variableName: String //e.g. name

    var body: some View {
        TextField(displayName, text: $variableName)
            .disableAutocorrection(true)
            .onAppear {
                variableName = listKey.isEmpty ? "" : listKey
            }
    }
}



