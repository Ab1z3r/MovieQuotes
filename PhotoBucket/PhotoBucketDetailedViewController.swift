//
//  PhotoBucketDetailedViewController.swift
//  PhotoBucket
//
//  Created by CSSE Department on 5/11/20.
//  Copyright © 2020 CSSE Department. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class PhotoBucketDetailedViewController:UIViewController{
    
    @IBOutlet weak var CaptionLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    
     var photoBucket : PhotoBucket?
    var photoBucketRef: DocumentReference!
    var photoBucketListener: ListenerRegistration!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            

        }
        
        @objc func showEditDialog() {
            let alertController = UIAlertController(title: "Edit this Photo Bucket",
                                                    message: "",
                                                    preferredStyle: .alert)
            // Configure
            alertController.addTextField{ (textField) in
                textField.placeholder = "Caption"
                textField.text = self.photoBucket?.caption
            }

            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(UIAlertAction(title: "Submit",
                                                    style: .default) { (action) in
                                                        let captionTextField = alertController.textFields![0] as UITextField
                                                       
                                                         self.photoBucketRef.updateData(
                                                                       [
                                                                           "Caption" :captionTextField.text!
                                                                       ])
            })
            
            present(alertController, animated: true, completion: nil)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            photoBucketListener = photoBucketRef.addSnapshotListener { (documentSnapshot, error) in
                if let error = error{
                    print("Error Getting Photo Bucket \(error)")
                    return
                }
                if documentSnapshot!.exists{
                    self.photoBucket = PhotoBucket(documentSnapshot: documentSnapshot!)
                    if(Auth.auth().currentUser!.uid == self.photoBucket!.authID){
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit,
                         target: self,
                         action:#selector(self.showEditDialog))
                     }
                    if let imgString = self.photoBucket?.imageURL {
                                    if let imgUrl = URL(string: imgString) {
                                      DispatchQueue.global().async { // Download in the background
                                        do {
                                          let data = try Data(contentsOf: imgUrl)
                                          DispatchQueue.main.async { // Then update on main thread
                                            self.ImageView.image = UIImage(data: data)
                                          }
                                        } catch {
                                          print("Error downloading image: \(error)")
                                        }
                                      }
                                    }
                        
                                  }

                    self.updateView()
                }else{
                    //Deleted Documn=ent
                }
            }

        }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           photoBucketListener.remove()
       }
        
        func updateView() {
            CaptionLabel.text = photoBucket?.caption
        }
}
