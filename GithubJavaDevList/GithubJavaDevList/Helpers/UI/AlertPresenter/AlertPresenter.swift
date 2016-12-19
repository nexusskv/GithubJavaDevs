//
//  AlertPresenter.swift
//  GithubJavaDevList
//
//  Created by Rost on 18.12.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

import Foundation
import UIKit


class AlertPresenter {
    
    
    /// ---> Function for show alerts <--- ///
    
    class func showAlert(vc: UIViewController, title: String, message: String, completion:((UIAlertAction) -> Void)?) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:completion))
            
            vc.present(alert, animated: true, completion:nil)
        })
    }
}
