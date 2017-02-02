//
//  LoginScreen.swift
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
class LoginScreen: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var bSignInFB: FBSDKLoginButton!
    var friends : [FBFriends] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.facebookAccessToken()
    }

    //----------------------------------Check access token---------------------------------------------------
    
    func facebookAccessToken(){
        if (FBSDKAccessToken.current() != nil){
            print("Authorize complete!")
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "tvScreen") as! TableViewScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            print("Don't authorize")
            bSignInFB.readPermissions = ["public_profile", "email", "user_friends"]
            self.bSignInFB.delegate = self
            
        }
    }

    //----------------------------------Login button---------------------------------------------------
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if ((error) != nil){
            print(error)
        }else if result.isCancelled {
            print("Cancell")
        }else {
            if result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile") && result.grantedPermissions.contains("user_friends"){
                fetchFriends()
                
            }
        }
    }

    //----------------------------------Fetching FB Friends and writing to CoreData---------------------------------------------------
    func fetchFriends(){
        let parameters =  ["fields": "id, name, email, picture.type(large), gender", "limit": "1000"]
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "tvScreen") as! TableViewScreen
        FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: parameters).start(completionHandler: { (connection, result, error) -> Void in
            if (error != nil){
                print("Error: \(error)")
            }
            if result != nil{
                let data1:[String:AnyObject] = result as! [String : AnyObject]
                var name = ""
                for friendDict in data1["data"] as! [NSDictionary]{
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let task = FBFriends(context: context)
                    let imageDict = friendDict["picture"] as! NSDictionary
                    let imageDataDict = imageDict["data"] as! NSDictionary
                    let imageURL =  imageDataDict["url"] as! String
                    name = friendDict["name"] as! String
                    task.name = name
                    task.imageUrl = imageURL
                    print(task.name!)
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    
                    vc.dataTset = result as! [String : AnyObject]
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
            
                let refreshAlert = UIAlertController(title: "Notification messege", message: "You didn't have any friends, contionue?", preferredStyle: UIAlertControllerStyle.alert)
    
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    self.navigationController?.pushViewController(vc, animated: true)
                }))
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    do{
                        print("Log out from FB")
                        let loginManager = FBSDKLoginManager()
                        loginManager.logOut()
                    }
                }))
                self.present(refreshAlert, animated: true, completion: nil)
            }
            
        })
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    

    
}
