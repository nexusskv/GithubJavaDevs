//
//  ListViewController.swift
//  GithubJavaDevList
//
//  Created by Rost on 16.12.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

import UIKit
import CoreData
import AERecord


class ListViewController: UITableViewController {
    var dataArray: [Developer] = []
    var bgColor: UIColor!
        
    
    /// ---> View life cycle <--- ///
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate             = UIApplication.shared.delegate as! AppDelegate
        self.bgColor                = appDelegate.viewColor
        self.view.backgroundColor   = self.bgColor

        loadDevsListLocally()
    }
    
    
    /// ---> Function for load data from local database <--- ///
    
    func loadDevsListLocally() {
        let context = AERecord.defaultContext
        
        if !context.isEqual(nil) {
            let defaultSorters = [NSSortDescriptor(key: "name", ascending: true)]
            if let allExistsDevs = Developer.all(sortDescriptors: defaultSorters, context: context) as? Array<Developer> {
                if allExistsDevs.count > 0 {
                    self.dataArray = allExistsDevs
                    self.tableView.reloadData()
                    
                    var userDefaults: UserDefaults!
                    
                    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                    
                    if appDelegate.isBlueScheme == true {
                        userDefaults = UserDefaults.init(suiteName: "group.GithubJavaDevListBlue")
                    } else {
                        userDefaults = UserDefaults.init(suiteName: "group.GithubJavaDevListBlack")
                    }
                    
                    var namesArray: [Dictionary<String, String>] = []
                    
                    for developer in self.dataArray {
                        var devValues: [String: String] = [:]
                        
                        if let name = developer.name {
                            devValues["name"] = name
                        }
                        
                        if let avatar = developer.avatar {
                            devValues["avatar"] = avatar
                        }
                        
                        namesArray.append(devValues)
                    }

                    userDefaults?.set(namesArray, forKey:"NamesList")
                    userDefaults?.synchronize()
                }
            } else {
                let startPageValues = ["start_page":  Int64(1)]
                _ = Page.saveObject(values: startPageValues)
                
                loadDataFromApi()
            }
        }
    }
    
    
    /// ---> Functioin for load data from API <--- ///
    
    func loadDataFromApi() {
        ApiConnector.shared.sendRequest(method: .GET,
                                        completion: { result in

            if (result as? String) != nil {
                let error = (result as? String)!
                AlertPresenter.showAlert(vc: self, title: "Error", message: error, completion:nil)
                
            } else if (result as? Bool) != nil {
                DispatchQueue.main.async(execute: {
                    self.loadDevsListLocally()
                })
            }
        })
    }
    
    
    /// ---> TableView delegate and dataSource functions <--- ///
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell",
                                                 for: indexPath) as? ListCell

        let bgView = UIView()
        bgView.backgroundColor = self.bgColor
        
        cell?.backgroundColor = self.bgColor
        cell?.backgroundView  = bgView
        
        let developer: Developer = self.dataArray[indexPath.section]
        
        if let avatar = developer.avatar {
            cell?.avatarImageView.downloadedImage(link: avatar)
        }
        
        if let name = developer.name {
            cell?.nameLabel.text = name
        }
        
        if let date = developer.reg_date {
            cell?.dateLabel.text = date
        }

        cell?.layer.cornerRadius    = 3.0
        cell?.layer.shadowOffset    = CGSize(width: -1, height: 1)
        cell?.layer.shadowOpacity   = 0.5
        cell?.layer.masksToBounds   = true
        
        
        if indexPath.section == self.dataArray.count - 3 {
            loadDataFromApi()
        }
        
        
        return cell ?? ListCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) {
            self.performSegue(withIdentifier: "ShowDetails", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    /// ---> Storyboard segues <--- ///
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            if let detailsVC: DetailsViewController = segue.destination as? DetailsViewController {
                let selectedIndex = self.tableView.indexPathForSelectedRow
                
                let selectedDeveloper = self.dataArray[(selectedIndex?.section)!]
                
                detailsVC.selectedDeveloper = selectedDeveloper
            }
        }
    }
    
    
    /// ---> Memory warning <--- ///

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
