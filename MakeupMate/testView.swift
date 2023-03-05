//
//  testView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 16/02/2023.
//

import SwiftUI
import Firebase

struct testView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    init (){
        FirebaseApp.configure()
    }
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack (spacing: 16){
                    Picker(selection: $isLoginMode,  label: Text("Picker here")){
                        Text("Login")
                            .tag(false)
                        Text("Create Account")
                            .tag(true)
                    }.pickerStyle(SegmentedPickerStyle())
                        
                
                    Image("loginImage") //make this smaller
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color.white)
                    SecureField("Password", text: $password)
                        .padding(12)
                        .background(Color.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Create Account" : "Log In")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                } .padding()
                
            }
            .navigationTitle(isLoginMode ? "Create Account" : "Log In")
            .background(Color("Colour4").cornerRadius(10).ignoresSafeArea()) //when it scrolls goes white, fix
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleAction () {
        if isLoginMode {
    
            print ("Add account to Firebase")
        } else {
            print ("Logins to firebase")
        }
    }
    
}

struct testView_Previews1: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
