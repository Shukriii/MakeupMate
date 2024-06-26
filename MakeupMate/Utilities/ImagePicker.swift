//
//  ImagePicker.swift
//  MakeupMate
//
//  Created by Shukri  Ahmed on 09/03/2023.
//

/*
 Uses UIImagePickerController view controller to allow the user to select an image from their photo library
 and implements a Coordinator class to handle image selection and cancellation events.
 
 Reused code from tutorial: https://www.youtube.com/watch?v=5inXE5d2MUM&ab_channel=LetsBuildThatApp

 Link to souce code: https://www.letsbuildthatapp.com/videos/7125
 */

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    private let controller = UIImagePickerController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
