//
//  LogOutCell.swift
//  AppFellas_Test
//
//  Created by Kiril Trembovetskiy on 2/1/17.
//  Copyright © 2017 Kiril Trembovetskiy. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

@available(iOS 10.0, *)
class LogOutCell: UITableViewCell {

    @IBOutlet weak var bLogout: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func deleteCoreData(){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FBFriends")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = delegate.persistentContainer.viewContext
        do{
            _ = try managedObjectContext.execute(request)
            print("ALL DELETE!!")
            try managedObjectContext.save()
            
        }catch let error as NSError {
            
            print("Fetch failed: \(error.localizedDescription)")
        }
    }

    @IBAction func actionLogOut(_ sender: UIButton) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        do{
            print("Log out from FB")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        self.deleteCoreData()
    }
    
}
