//
//  WalkthroughView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/02/2023.
//
//

/*
 This file is a walkthrough that provides the users with instructions on how to use the app.
 It is only displayed when the app is first downloaded.
 
 I reused the code from this video: https://www.youtube.com/watch?v=HVAMShhJOUo&ab_channel=Kavsoft
 
 Replaced the tutorial code with my own images, information and colour scheme. 
 */


import SwiftUI

// Once walkthrough is complete redirects to NavigationBar
struct WalkthroughView: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        
        if currentPage > totalPages {
            BottomNavigationBar()
            //InventoryView()
            //LoginView (didCompleteLoginProcess: {})
        }
        else {
            Walkthrough()
        }
    }
}

var totalPages = 3

// Class that provides ScreenView with parameters for each view
struct Walkthrough: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View{
        
        ZStack {
            
            if currentPage == 1 {
                ScreenView(image: "image1", title: "Step 1", detail: "Create an account", bgColor: Color(red: 0.744, green: 0.502, blue: 0.552, opacity: 0.473))
                    .transition(.scale)
            }
            
            if currentPage == 2 {
                ScreenView(image: "image2", title: "Step 2", detail: "Add your makeup inventory and wish list", bgColor: Color(red: 0.998, green: 0.703, blue: 0.637, opacity: 0.592))
                    .transition(.scale)
            }
            
            if currentPage == 3 {
                ScreenView(image: "image3", title: "Step 3", detail: "Enjoy MakeupMate features!", bgColor: Color(red: 0.997, green: 0.803, blue: 0.699, opacity: 0.601))
                    .transition(.scale)
            }
            
        }
        .overlay(
            
            Button (action: {
                withAnimation(.easeInOut){
                    
                    if currentPage <= totalPages{
                        currentPage += 1
                    }
                    else {
                        currentPage = 1
                    }
                }
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 60, height: 100, alignment: .center)
                    .background(Color(red: 0.213, green: 0.279, blue: 0.824, opacity: 0.525))
                    .clipShape(Circle())
                
                // For circular slider
                    .overlay(
                        ZStack{
                            Circle()
                                .stroke(Color.black.opacity(0.04), lineWidth: 4)
                                
                            Circle()
                                .trim(from: 0, to: CGFloat(currentPage) / CGFloat(totalPages))
                                .stroke(Color(red: 0.213, green: 0.279, blue: 0.824, opacity: 0.525), lineWidth: 4)
                                .rotationEffect(.init(degrees: -90))
                        }
                        .padding(-15)
                    )
            })
                .padding(.bottom, 20)
        
            ,alignment: .bottom
        )
    }
}

// The design of each view
struct ScreenView: View {
    
    var image: String
    var title: String
    var detail: String
    var bgColor: Color
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        VStack(spacing: 20){
            HStack{
                
                //Welcome message only on first screen
                if currentPage == 1 {
                    Text ("Welcome!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .kerning(1.4) //for letter spacing
                }
                
                // else show a back button
                else {
                    Button(action: {
                        withAnimation(.easeInOut){
                            currentPage -= 1
                        }
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(10)
                    })
                }
                Spacer ()
                
                Button(action: {
                    withAnimation(.easeInOut){
                        currentPage = 4
                    }
                }, label: {
                    Text("Skip")
                        .fontWeight(.semibold)
                        .kerning(1.2)
                })
            }
            .foregroundColor(.black)
            .padding()
            
            Spacer(minLength: 0)
            
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top)
            
            Text(detail)
                .font(.system(size: 20, weight: .semibold))
                //.fontWeight(.bold)
                .foregroundColor(Color.black)
                .kerning(1.3)
                .multilineTextAlignment(.center)
            
            Spacer(minLength: 120)
        }
        .background(bgColor.cornerRadius(10).ignoresSafeArea())
    }
}

//Connects content previewer
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WalkthroughView()
        }
    }
}
