//
//  TableViewScreen.swift
//  AppFellas_Test
//
//  Created by Kiril Trembovetskiy on 2/1/17.
//  Copyright © 2017 Kiril Trembovetskiy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import CoreData

@available(iOS 10.0, *)
class TableViewScreen: UITableViewController {

    let section = ["MY ACCOUNT", "LOG OUT", "FRIENDS"]
    var friends : [FBFriends] = []
    var data : [String: AnyObject] = [:]
    var userID = ""
    var dataTset : [String: AnyObject] = [:]
    var firstAndLastName2 : String?
    var mail : String?
    var link : String?
    var myImageURL : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    override func viewWillAppear(_ animated: Bool) {
        friends = getFriendsData()
        self.tableView.reloadData()
    }
    
    //------------------------------------Fetching data from CoreData------------------------------------
    
    func getFriendsData() -> Array<FBFriends>{
        var userFriends : [FBFriends] = []
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request:NSFetchRequest<FBFriends> = FBFriends.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        do{
            request.sortDescriptors = sortDescriptors
            userFriends = try context.fetch(request)
        }
        catch{
            print("FETCHING FAILED")
        }
        
        return userFriends
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

    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 13)
        header.textLabel?.textColor = UIColor.darkGray
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 50
        }else if indexPath.section == 1{
            return 44
        }
        return 55
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2{
            return friends.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if indexPath.section == 1{
            print("Go logout")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            do{
                print("Log out from FB")
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
            }
            self.deleteCoreData()
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "loginScreen") as! LoginScreen
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if (indexPath.section == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "myAccountCell", for: indexPath) as! MyAccountCell
             (cell as! MyAccountCell).imMyAvatar?.layer.masksToBounds = true
             (cell as! MyAccountCell).imMyAvatar?.layer.cornerRadius = ((cell as! MyAccountCell).imMyAvatar?.frame.size.height)!/2
        
        //------------------------------------FB Request for normal size picture------------------------------------
            
            let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?width=1080&height=1080&redirect=false", parameters: nil)
            pictureRequest!.start(completionHandler: {
                (connection, result, error) -> Void in
                if error == nil {
                    print("\(result)")
                    self.data = result as! [String : AnyObject]
                    let imageDict = self.data["data"] as! NSDictionary
                    let imageURL =  imageDict["url"]
                    self.myImageURL = (imageURL as! String)
            
                    //------------------------------------Image Loader method------------------------------------
                    
                    if let link = URL(string: self.myImageURL!){
                        ImageLoader.sharedLoader.imageForUrl(urlString: String(describing: link), completionHandler: { (image, url) in
                            if image != nil{
                                (cell as! MyAccountCell).imMyAvatar?.image = image!
                            }
                        })
                    }
                    else{
                        (cell as! MyAccountCell).imMyAvatar?.image = UIImage(named:  self.myImageURL! )!
                    }
                    
                }else {
                    print("\(error)")
                }
            })
        //------------------------------------FB Request for user data and with bad size picture------------------------------------
            
            let parameters =  ["fields":"first_name, last_name, email, picture.type(large), id, name, link"]
            let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if (error != nil){
                    // Process error
                    print("Error: \(error)")
                }
                self.data = result as! [String : AnyObject]
                self.userID = self.data["id"] as! String
                self.firstAndLastName2 = self.data["name"] as? String
                self.mail =  self.data["email"] as? String
                self.link = self.data["link"] as? String
                (cell as! MyAccountCell).lMyName?.text = self.firstAndLastName2
            })

        }else if (indexPath.section == 1) {
           
            cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath) as! LogOutCell // just
            
        }else if (indexPath.section == 2) {
            
            cell = self.tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsCell
            (cell as! FriendsCell).lFriendName?.text = friends[indexPath.row].name!
            (cell as! FriendsCell).imFrinedAvatar?.layer.masksToBounds = true
            (cell as! FriendsCell).imFrinedAvatar?.layer.cornerRadius = ((cell as! FriendsCell).imFrinedAvatar?.frame.size.height)!/2

            //------------------------------------Image Loader method------------------------------------
            if let link = URL(string: friends[indexPath.row].imageUrl!){
                ImageLoader.sharedLoader.imageForUrl(urlString: String(describing: link), completionHandler: { (image, url) in
                    if image != nil{
                         (cell as! FriendsCell).imFrinedAvatar?.image = image!
                    }
                })
            }
            else{
                (cell as! FriendsCell).imFrinedAvatar?.image = UIImage(named: "noimage.jpg")!
            }
        }
        
        return cell
    }
    
}
