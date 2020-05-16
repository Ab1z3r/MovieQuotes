//
//  PhotoBucketTableViewController.swift
//  PhotoBucket
//
//  Created by CSSE Department on 5/11/20.
//  Copyright © 2020 CSSE Department. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class PhotoBucketTableViewController:UITableViewController{
    
    
    let photoBucketCellidentifier = "PhotoBucketCell"
    let detailSegueIdentifier = "DetailSegue"
    var photoBuckets = [PhotoBucket]()
    var PhotoBucketsRef: CollectionReference!
    var PhotoBucketsListener:ListenerRegistration!
    var authListener:AuthStateDidChangeListenerHandle!
    var isShowAllMode = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
       // navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
        //                                                    target: self,
        //                                                    action: #selector(showAddDialogue))

            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(showMenu))
        
        PhotoBucketsRef = Firestore.firestore().collection("NewPhotoBuckets")
    }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authListener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if(Auth.auth().currentUser == nil){ self.navigationController?.popViewController(animated: true)}
            else{print("Signed in")}
            }
        
            self.startListening()
       }
    
    func startListening(){
        if (PhotoBucketsListener != nil){
            PhotoBucketsListener.remove()
        }
        
        var query = PhotoBucketsRef.order(by: "created", descending: true).limit(to: 50)
        if(!isShowAllMode){
            query = query.whereField("AuthID", isEqualTo: Auth.auth().currentUser!.uid)
            }
        
        PhotoBucketsListener = query.addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot{
                self.photoBuckets.removeAll()
                querySnapshot.documents.forEach { (documentSnapshot) in
                self.photoBuckets.append(PhotoBucket(documentSnapshot: documentSnapshot))
                }
                self.tableView.reloadData()
            }else{
                print("Error getting movie Quotes \(error!)")
                return
            }
        }
    }
       
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           PhotoBucketsListener.remove()
        Auth.auth().removeStateDidChangeListener(authListener)
       }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoBuckets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: photoBucketCellidentifier, for: indexPath)
        cell.textLabel?.text = photoBuckets[indexPath.row].caption
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           let photBucket  = photoBuckets[indexPath.row]
           return Auth.auth().currentUser?.uid == photBucket.authID
       }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let photBucketTodelete = photoBuckets[indexPath.row]
            PhotoBucketsRef.document(photBucketTodelete.id!).delete()
        }
    }
    
    @objc func showMenu(){
        let alertController = UIAlertController(title: "Photo Bucket Options", message: "", preferredStyle: .actionSheet)
                
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Add Photo", style: .default) { (action) in
            self.showAddDialogue()
        })
        
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .default) { (action) in
            do{
                try Auth.auth().signOut()
            }catch{
                print("SignOut Error")
            }
        })
        
        alertController.addAction(UIAlertAction(title:isShowAllMode ?  "Show Only My Quotes": "Show All Quotes", style: .default) { (action) in
            self.isShowAllMode = !self.isShowAllMode
            
            self.startListening()
        })
               
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showAddDialogue(){
        let alertController = UIAlertController(title: "Create a new Photo Bucket",
                                                      message: "",
                                                      preferredStyle: .alert)
              // Configure
              alertController.addTextField{ (textField) in
                  textField.placeholder = "Caption"
              }
              
              alertController.addTextField{ (textField) in
                  textField.placeholder = "ImageURL"
              }
              
              let cancelAction = UIAlertAction(title: "Cancel",
                                               style: .cancel,
                                               handler: nil)
              alertController.addAction(cancelAction)
              alertController.addAction(UIAlertAction(title: "Create Photo Bucket",
                                                      style: .default) { (action) in
                                                          let captionTextField = alertController.textFields![0] as UITextField
                                                          let URLTextField = alertController.textFields![1] as UITextField
                                                        var URL = URLTextField.text!
                                                        if URL.isEmpty{
                                                            URL = self.getRandomImageUrl()
                                                        }
                                                        //self.photoBuckets.insert(PhotoBucket(caption: captionTextField.text!, imageURL: URL), at: 0)
                                                        
                                                        self.PhotoBucketsRef.addDocument(data:
                                                            [
                                                                "Caption" : captionTextField.text!,
                                                                "ImageURL" : URL,
                                                                "created" : Timestamp.init(),
                                                                "AuthID": Auth.auth().currentUser!.uid
                                                        ])
              })
              
              present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! PhotoBucketDetailedViewController).photoBucketRef = PhotoBucketsRef.document(photoBuckets[indexPath.row].id!)
            }
        }
    }
    
    func getRandomImageUrl() -> String {
        let testImages = ["https://upload.wikimedia.org/wikipedia/commons/0/04/Hurricane_Isabel_from_ISS.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/0/00/Flood102405.JPG",
            "https://upload.wikimedia.org/wikipedia/commons/6/6b/Mount_Carmel_forest_fire14.jpg"]
        let randomIndex = Int(arc4random_uniform(UInt32(testImages.count)))
        return testImages[randomIndex];
    }

}
