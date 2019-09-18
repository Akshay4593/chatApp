//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Akshay Shedge on 17/09/19.
//  Copyright © 2019 Akshay Shedge. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    private var messageArray = [MessageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUI()
        userIsLoggedIn()
        showSpinner(onView: self.view)
        retrieveMessage()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setUpTableView(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
    }
    
    private func setUI(){
        setUpNavigationBar()
        setTheme()
        setUpTableView()
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpNavigationBar(){
        
        let logOutBtn = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        logOutBtn.tintColor = Color.DeepSeaBlue.value
        navigationItem.rightBarButtonItem = logOutBtn
        title = "Group Chat"

    }
    
    private func setTheme(){
        
        sendBtn.backgroundColor = Color.DeepSeaBlue.value
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.setTitleColor(Color.White.value, for: .normal)
        
        messageTextField.placeholder = "Type Message..."
        AppTheme.applyThemeRegularFont(to: [messageTextField], size: 13.0)
        
    }
    
    
    @IBAction func sendBtnAction(_ sender: UIButton) {
        
        
        
        guard let email = Auth.auth().currentUser?.email,
            let message = messageTextField?.text, !message.isEmpty else {
                return
        }
        
        
        sendBtn.isEnabled = false
        messageTextField.isEnabled = false
        
        // Creating Child db for messages
        let db = Database.database().reference().child("Messages")
        
        let messageDict = ["sender" : email, "message" : message]
        db.childByAutoId().setValue(messageDict){
            (error, user) in
            if error != nil{
                print(error ?? "Error Sending Message")
            }
            else{
                self.sendBtn.isEnabled = true
                self.messageTextField.isEnabled = true
                self.messageTextField.text = nil
            }
        }
        
    }
    
    
    @objc private func handleLogout(){
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.present(loginVc, animated: true, completion: nil)
        
    }
    
    private func userIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    //MARK: Retrive Messages
   private func retrieveMessage(){
        let db = Database.database().reference().child("Messages")
        db.observe(.childAdded) { (snapshot) in
            self.removeSpinner()
            if let snapshotValue = snapshot.value as? [String : String] {
                let messageObj = MessageModel(dict: snapshotValue)
                self.messageArray.append(messageObj)
            }
            //self.setUpTableView()
            self.tableView.reloadData()
            self.scrollToBottomOfTableView()
          
        }
    }
    
    private func scrollToBottomOfTableView(){
        if let lastRow: Int = self.tableView.numberOfRows(inSection: 0) - 1 {
            let indexPath = IndexPath(row: lastRow, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
//MARK: UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
         let messageModel = messageArray[indexPath.row]
        cell.setData(data: messageModel)
        return cell
        
    }
    
    
    
}
//MARK: UITableViewDelegate

extension ChatViewController: UITableViewDelegate {
    
    
}
