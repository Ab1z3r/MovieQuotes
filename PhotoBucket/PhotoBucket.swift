//
//  PhotoBucket.swift
//  PhotoBucket
//
//  Created by CSSE Department on 5/11/20.
//  Copyright © 2020 CSSE Department. All rights reserved.
//

import Foundation
import Firebase
class PhotoBucket {
    var caption:String
    var imageURL:String
    var id:String?
    var authID:String
    
    init(documentSnapshot:DocumentSnapshot){
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.caption = data["Caption"] as! String
        self.imageURL = data["ImageURL"] as! String
        self.authID = data["AuthID"] as! String
    }
}
