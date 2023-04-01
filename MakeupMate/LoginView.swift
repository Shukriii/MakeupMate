//
//  LoginView.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 16/02/2023.
//

/*
  LoginView is called when the user logs out, using the closure didCompleteLoginProcess. 
 
  Code has been resued from following tutorials -
  To create the login view: https://www.youtube.com/watch?v=aVO4EVGvQcw&ab_channel=LetsBuildThatApp
  Setting up Firebase Auth and creating user: https://www.youtube.com/watch?v=xXjYGamyREs&t=612s&ab_channel=LetsBuildThatApp
  Saving user into Firebase Firestore: https://www.youtube.com/watch?v=VtwFwDJvU8w&t=6s&ab_channel=LetsBuildThatApp
 */

import SwiftUI
import Firebase

struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    
    // Creates the UI of LoginView, a picker is used to switch from Login to Sign Up
    var body: some View {
        NavigationView{
            ScrollView{
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
                    
                    // TextField for email and password
                    Group {
                        TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(15)
                    .background(Color(red: 0.914, green: 0.914, blue: 0.914))
                    .cornerRadius(10)
 
                    // Button which functionality depends on isLoginMode boolean
                    Button {
                        handleAction ()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Login" : "Sign Up")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                        }.background(Color("Colour5"))
                         .cornerRadius(32)
                        
                    }
                    
                    // Message that is displayed once buttton is clicked
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                    
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Login" : "Sign Up")
            .background(Color.white)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Calls a function depending on boolean value
    private func handleAction () {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    // Signs in using Firebase Auth, using the email and password inputted into the Texfield by the user. Prints a loginStatusMessage validating the success or failure of logging in.
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
    
    // Creates an account using Firebase Auth, using the email and password inputted into the Texfield by the user. Prints a loginStatusMessage validating the success or failure of creating the account.
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
    
    // Retrives the users uid from Auth suing currentUser, then creates a document in the Users collection in Firestore. The document identifier is the users' uid and stores their uid and email.
    private func storeUserInformation(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        let userData = ["uid": uid, "email": self.email]
        
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
