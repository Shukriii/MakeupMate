//
//  CalendarView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/04/2023.
//

import SwiftUI

struct ExpiryCalendarView: View {
    
    @ObservedObject private var am = AccountFunctionalityViewModel()
    @State var currentDate: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading, spacing: 15) {
            
                TopNavigationBar(navigationName: "Expiry Calendar")
                    .fullScreenCover(isPresented: $am.isUserCurrentlyLoggedOut, onDismiss: nil){
                        LoginView(didCompleteLoginProcess: {
                            self.am.isUserCurrentlyLoggedOut = false
                        })
                    }
            
                ScrollView(.vertical, showsIndicators: false){
                    
                    // The calendar will appear here
                    CalendarDisplayView(currentDate: $currentDate)
                    
                }
                .padding(.vertical)
            }.navigationBarHidden(true)
        }
    }
}

struct ExpiryCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ExpiryCalendarView()
    }
}
