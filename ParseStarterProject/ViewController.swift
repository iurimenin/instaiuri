/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var signUpActive = true
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func login(sender: AnyObject) {
    
        if signUpActive == true {
            
            signUpActive = false
            registerButton.setTitle("Entrar", forState: UIControlState.Normal)
            registerLabel.text = "Nova conta?"
            loginButton.setTitle("Criar", forState: UIControlState.Normal)
            
        } else {
            
            signUpActive = true
            registerButton.setTitle("Registrar", forState: UIControlState.Normal)
            registerLabel.text = "Já possui uma conta?"
            loginButton.setTitle("Entrar", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
    
        if userName.text == "" || password.text == "" {
            
            displayAlert("Oopss", msg: "Por favor preencha usuário e senha")
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Por favor tente novamente mais tarde"

            if signUpActive == true {
                
                let user = PFUser()
                user.username = userName.text
                user.password = password.text
                
                user.signUpInBackgroundWithBlock({ (success, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        // signup successful
                        self.performSegueWithIdentifier("login", sender: self)
                    } else {
                        
                        if let errorString = error!.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                        }
                        
                        self.displayAlert("Oopss", msg: errorMessage)
                    }
                })
                
            } else {
                
                
                PFUser.logInWithUsernameInBackground(userName.text!, password: password.text!, block: { (user, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if user != nil {
                        
                        print(user)
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    } else {
                        
                        if let errorString = error!.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                        }

                        self.displayAlert("Oopss", msg: errorMessage)

                    }
                })
            }
        }
    }
    
    func displayAlert(title:String, msg:String) {
        
        if #available(iOS 8.0, *) {
            
            let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        
        print(PFUser.currentUser())
        if PFUser.currentUser() != nil && PFUser.currentUser()?.objectId != nil {
            self.performSegueWithIdentifier("login", sender: self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
