//
//  ContentView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 07/02/2023.
//

import SwiftUI


struct WalkthroughView: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        
        if currentPage > totalPages {
            InventoryView()
            //LoginView (didCompleteLoginProcess: {})
        }
        else {
            Walkthrough()
        }
    }
}


// Walkthrough
struct Walkthrough: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View{
        //for slide animation
        ZStack {
            
            if currentPage == 1 {
            ScreenView(image: "image1", title: "Step 1", detail: "Create an account", bgColor: Color("Colour1"))
                    .transition(.scale)
            }
            
            if currentPage == 2 {
            ScreenView(image: "image2", title: "Step 2", detail: "Add your makeup inventory and wishlist", bgColor: Color("Colour3"))
                    .transition(.scale)
            }
            
            if currentPage == 3 {
            ScreenView(image: "image3", title: "Step 3", detail: "Enjoy MakeupMate features!", bgColor: Color("Colour4"))
                    .transition(.scale)
            }
            
        }
        .overlay(
            
            Button (action: {
                //to change views
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
                    .background(Color.white)
                    .clipShape(Circle())
                
                // For circular slider
                    .overlay(
                        ZStack{
                            Circle()
                                .stroke(Color.black.opacity(0.04), lineWidth: 4)
                                
                            Circle()
                                .trim(from: 0, to: CGFloat(currentPage) / CGFloat(totalPages))
                                .stroke(Color.white, lineWidth: 4)
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


//Connects content previewer
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WalkthroughView()
        }
    }
}

// Screen View function
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
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
                .kerning(1.3)
                .multilineTextAlignment(.center)
            
            Spacer(minLength: 120)
        }
        .background(bgColor.cornerRadius(10).ignoresSafeArea())
    }
}

var totalPages = 3
