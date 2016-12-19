//
//  TodayViewController.swift
//  TodayExtForJavaDevListBlue
//
//  Created by Rost on 16.12.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

import UIKit
import NotificationCenter
import AERecord
import CoreData



class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var developerTitle: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var userDefaults: UserDefaults!
        
        let targetInfo: Dictionary<String, AnyObject> = Bundle.main.infoDictionary as! Dictionary<String, AnyObject>
        
        if let blueContainerFlag = targetInfo["isBlueColor"] as? Bool {
            if blueContainerFlag == true {
                userDefaults = UserDefaults.init(suiteName: "group.GithubJavaDevListBlue")
            }
        } else {
            userDefaults = UserDefaults.init(suiteName: "group.GithubJavaDevListBlack")
        }
        
        let namesList = userDefaults?.array(forKey: "NamesList")
        
        if (namesList?.count)! > 0 {
            let randomUserIndex = Int(arc4random_uniform(UInt32(((namesList?.count)! - 1))))
            
            let selectedDeveloper = namesList?[randomUserIndex] as! Dictionary<String, String>
            
            self.developerTitle.text = selectedDeveloper["name"]
            
            if let avatar = selectedDeveloper["avatar"] {
                self.avatarImageView.downloadedImage(link: avatar)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {        
        
        completionHandler(NCUpdateResult.newData)
    }
}

public extension UIImageView {
    func downloadedImage(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        
        guard let url = URL(string: link) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
}
