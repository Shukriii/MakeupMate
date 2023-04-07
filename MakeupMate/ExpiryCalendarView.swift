//
//  CalendarView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/04/2023.
//

import SwiftUI

struct ExpiryCalendarView: View {
    
    @State var currentDate: Date = Date()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 20) {
                
                // The calendar will appear here
                CalendarDisplayView(currentDate: $currentDate)
                
                
            }
        }
    }
}

struct ExpiryCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ExpiryCalendarView()
    }
}
