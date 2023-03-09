//
//  LoginView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 16/02/2023.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                //Picker
                VStack (spacing: 16){
                    Picker(selection: $isLoginMode,  label: Text("Picker")){
                        Text("Login")
                            .tag(true)
                            
                        Text("Sign Up")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    //Image
                    Image("loginImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    
                    // Text boxes for email and password
                    Group {
                        TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(15)
                    .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                    .cornerRadius(10)
 
                    // button to login or create account
                    Button {
                        handleAction ()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Sign Up")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                        }.background(Color("Colour5"))
                         .cornerRadius(32)
                        
                    }
                    
                    // message that is displayed once buttton is clicked
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                    
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Sign Up")
            .background(Color.white)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // button functionality
    private func handleAction () {
        if isLoginMode {
            loginUser()
            //print ("Add account to Firebase")
        } else {
            createNewAccount()
            //print ("Logins to firebase")
        }
    }
    
    // firebase auth code to check if login is valid
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){ result, err in
            
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return }
            
            print ("Successfully logged in user as: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in user as: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
            
        }
    }
    
    @State var loginStatusMessage = ""
    
    // firebase code to check if sign up is valid 
    private func createNewAccount(){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){ result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return }
            
            print ("Successfully created user: \(result?.user.uid ?? "")")
            self.storeUserInformation()
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")" }
    }
    
    // when an account is created this stores the users email and id
    private func storeUserInformation(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        // the data of the user we are storing, uid and email
        let userData = ["uid": uid, "email": self.email]
        
        // create a collection of users, and document there uid
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData){err in
            if let err = err {
                print(err)
                self.loginStatusMessage = "\(err)"
                return
            }
            print ("success")
            
            self.didCompleteLoginProcess()
        }
    }
    
}

struct LoginView_Previews: PreviewProvider { 
    static var previews: some View {
        LoginView(didCompleteLoginProcess: {})
    }
}
