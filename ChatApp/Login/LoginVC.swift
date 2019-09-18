//
//  LoginVC.swift
//  ChatApp
//
//  Created by Akshay Shedge on 14/09/19.
//  Copyright © 2019 Akshay Shedge. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var userNameTextField: FloatingTextField!
    @IBOutlet weak var emailTextField: FloatingTextField!
    @IBOutlet weak var passTextField: FloatingTextField!
    
    @IBOutlet weak var actionBtn: UIButton!
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
    }
    
    
    private func setTheme(){
        
        
        passTextField.isSecureTextEntry = true
        AppTheme.applyThemeBoldFont(to: [actionBtn], size: 14.0)
        AppTheme.applyTintColor(to: [actionBtn], color: Color.White.value)
        AppTheme.applyThemeRegularFont(to: [userNameTextField,emailTextField,passTextField], size: 14.0)
        actionBtn.backgroundColor = Color.DeepSeaBlue.value
        
        userNameTextField.highlightColour = Color.DeepSeaBlue.value
        emailTextField.highlightColour = Color.DeepSeaBlue.value
        passTextField.highlightColour = Color.DeepSeaBlue.value
        
        segmentController.backgroundColor = Color.White.value
        segmentController.tintColor = Color.DeepSeaBlue.value
        segmentController.selectedSegmentIndex = 1
        
        imgView.image = UIImage(named: "ic_chat")
        
    }
    
    
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            userNameTextField.isHidden = true
            actionBtn.setTitle("Login", for: .normal)
            
        }
        if sender.selectedSegmentIndex == 1 {
            userNameTextField.isHidden = false
            actionBtn.setTitle("Register", for: .normal)
        }
        
    }

    
    @IBAction func registerLogInBtnAction(_ sender: UIButton) {
        
        if segmentController.selectedSegmentIndex == 0 {
            signIn()
        }else {
            createUser()
        }
    }

    private func createUser(){
        
        guard let email = emailTextField.text,
               let password = passTextField.text,
         let name = userNameTextField.text,
             !email.isEmpty,
        !password.isEmpty,
        !name.isEmpty else {
                show(message: "Form is invalid")
                return
        }
        showSpinner(onView: self.view)
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                self.removeSpinner()
                print(error ?? "Error Registering User")
                if let desc = error?.localizedDescription {
                    self.show(message: desc)
                }
            }
            else{
                self.removeSpinner()
                guard let uid = user?.user.uid else {
                    return
                }
                print("User succesfully created.")
                
                let ref = Database.database().reference()
                let userRef = ref.child("Users").child(uid)
                let values = ["name" : name, "email" : email]
                userRef.updateChildValues(values, withCompletionBlock: { error,reference in
                    
                    if error != nil {
                        if let desc = error?.localizedDescription {
                            self.show(message: desc)
                        }
                        return
                    }
                    
                })
                
                self.dismiss(animated: true, completion: nil)
                
            }
        }

    }
    
    
    private func signIn(){
        
        guard let email = emailTextField.text,
            let password = passTextField.text,
            !email.isEmpty,
            !password.isEmpty else {
                show(message: "Form is invalid")
                return
        }
        
        showSpinner(onView: self.view)
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passTextField.text!) { (user, error) in
            if error != nil{
                self.removeSpinner()
                print(error ?? "Error Signing In")
                if let desc = error?.localizedDescription {
                    self.show(message: desc)
                }
            }
            else{
                self.removeSpinner()
                self.dismiss(animated: true, completion: nil)

            }
        }
      
    }
    
}
