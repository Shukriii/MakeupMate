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
 
 I reused and edited the code from this video: https://www.youtube.com/watch?v=HVAMShhJOUo&ab_channel=Kavsoft
 
 Replaced the tutorial code with my own images, text and colour scheme.
 */

import SwiftUI

// This struct uses cuurentPage to decide what view to display, once the walkthough is complete it redirects the user to BottomNavigationBar()
struct WalkthroughView: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        
        if currentPage > totalPages {
            BottomNavigationBar()
        }
        else {
            Walkthrough()
        }
    }
}

var totalPages = 4

// Provides Struct ScreenView with parameters for each view
struct Walkthrough: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View{
        
        ZStack {
            
            if currentPage == 1 {
                ScreenView(image: "image3", title: "Create an account", detail: "How To Get Started!", bgColor: Color(red: 0.213, green: 0.28, blue: 0.823, opacity: 0.217))
                    .transition(.scale)
            }
            
            if currentPage == 2 {
                ScreenView(image: "image2", title: "Add Products To Your Makeup Collection and Wishlist", detail: "", bgColor: Color(red: 0.213, green: 0.28, blue: 0.823, opacity: 0.217))
                    .transition(.scale)
            }
            
            if currentPage == 3 {
                ScreenView(image: "image1", title: "Compare Your Makeup Collection and Wishlist", detail: "", bgColor: Color(red: 0.213, green: 0.28, blue: 0.823, opacity: 0.217))
                    .transition(.scale)
            }
            
            if currentPage == 4 {
                ScreenView(image: "image4", title: "Set Expiration Notifications For Products", detail: "", bgColor: Color(red: 0.213, green: 0.28, blue: 0.823, opacity: 0.217))
                    .transition(.scale)
            }
            
        }
        .overlay(
            // Circle button to change view being displayed
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

// The design of each view, the image, title, detail and bgColor are provided as parameters
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
                        currentPage = 5
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
            
            Text(detail)
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(Color.black)
                .kerning(1.3)
                .padding(.bottom, 22.0)
            
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(title)
                .font(.system(size: 30, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer(minLength: 120)
        }
        .background(bgColor.cornerRadius(10).ignoresSafeArea())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WalkthroughView()
        }
    }
}
