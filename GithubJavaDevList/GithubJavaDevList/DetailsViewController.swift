//
//  DetailsViewController.swift
//  GithubJavaDevList
//
//  Created by Rost on 17.12.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

import Foundation
import UIKit
import MessageUI



class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followersValue: UILabel!
    
    var cellTitles: [String] = []
    var selectedDeveloper: Developer!
    var bgColor: UIColor!
    
    
    /// ---> View life cycle <--- ///
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellTitles = ["", "Email", "Blog", "Repositories", "Gists", "Following"]
        
        let appDelegate             = UIApplication.shared.delegate as! AppDelegate
        self.bgColor                = appDelegate.viewColor
        self.view.backgroundColor   = self.bgColor
        
        self.dataTable.tableFooterView = UIView()
        self.dataTable.backgroundColor = self.bgColor
        
        let bgView                     = UIView()
        bgView.backgroundColor         = self.bgColor
        self.dataTable.backgroundView  = bgView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let name = self.selectedDeveloper.name {
            self.title = name
        }
        
        if let followers = self.selectedDeveloper.followers {
            self.followersValue.text = String(format: "%d", followers)
        }
    
        if UIDevice.current.model.hasPrefix("iPad") {
            changeConstraint(view: followersTitle, constant: 10.0, identifier:"FollowerTitleMarginX")
            changeConstraint(view: followersValue, constant: 5.0, identifier:"FollowerValueMarginX")
            
            self.followersValue.textAlignment = .right
        }
    }
    
    
    /// ---> TableView delegate and dataSource functions <--- ///
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell()
        
        switch indexPath.row {
            case 0:
                var cell = tableView.dequeueReusableCell(withIdentifier: "GeneralDetailsCell",
                                                         for: indexPath) as? GeneralDetailsCell
                
                cell = setColorForCell(cell: cell!) as? GeneralDetailsCell
                
                if let avatar = selectedDeveloper.avatar {
                    cell?.avatarImageView.downloadedImage(link: avatar)
                }
                
                if let location = selectedDeveloper.location {
                    cell?.locationLabel.text = location
                }
                
                if let company = selectedDeveloper.company {
                    cell?.companyLabel.text = company
                }
                
                if let regDate = selectedDeveloper.reg_date {
                    cell?.dateLabel.text = regDate
                }
                
                cell?.selectionStyle = .none
                
                return cell! 

            case 1, 2, 3, 4, 5:
                var cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell",
                                                         for: indexPath) as? DetailsCell

                cell = setColorForCell(cell: cell!) as? DetailsCell
                
                cell?.headerLabel.text = self.cellTitles[indexPath.row]
                
                if indexPath.row > 2 {
                    cell?.selectionStyle = .none
                } else {
                    cell?.accessoryType = .disclosureIndicator
                }
                
                switch indexPath.row {
                    case 1:
                        if let email = selectedDeveloper.email {
                            cell?.valueLabel.text = email
                        }
                    
                    case 2:
                        if let blog = selectedDeveloper.blog {
                            cell?.valueLabel.text = blog
                        }
                    
                    case 3:
                        if let repos = selectedDeveloper.public_repos {
                            cell?.valueLabel.text = String(format: "%d", repos)
                        }
                    
                    case 4:
                        if let gists = selectedDeveloper.public_gists {
                            cell?.valueLabel.text = String(format: "%d", gists)
                        }
                    
                    case 5:
                        if let following = selectedDeveloper.following {
                            cell?.valueLabel.text = String(format: "%d", following)
                        }

                    default:
                        break
                }
            
                return cell ?? DetailsCell()
                
            default:
                break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
            case 0:
                return 136.0
                
            case 1:
                if selectedDeveloper.email != nil {
                    return 60.0
                } else {
                    return 0.0
                }
                
            case 2:
                if selectedDeveloper.blog != nil {
                    return 60.0
                } else {
                    return 0.0
                }
                
            case 3:
                if selectedDeveloper.public_repos != nil {
                    return 60.0
                } else {
                    return 0.0
                }
                
            case 4:
                if selectedDeveloper.public_gists != nil {
                    return 60.0
                } else {
                    return 0.0
                }
                
            case 5:
                if selectedDeveloper.following != nil {
                    return 60.0
                } else {
                    return 0.0
                }
                
            default:
                break
        }
        
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 1:
                if let emailAddress = self.selectedDeveloper.email {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([emailAddress])
                    mail.setSubject("Message for Java Developer.")
                    mail.setMessageBody("<b>Hello!</b>", isHTML: true)
                    
                    if MFMailComposeViewController.canSendMail() {
                        present(mail, animated: true, completion: nil)
                    } else {
                        AlertPresenter.showAlert(vc: self, title: "Error", message: "Cannot send mail", completion:nil)
                    }
                }
            case 2:
                if let blogUrl = selectedDeveloper.blog {                
                    UIApplication.shared.open(URL(string: blogUrl)!,
                                              options: [:],
                                              completionHandler: nil)
                }
            default:
                break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    /// ---> Email composer delegate function <--- ///
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            AlertPresenter.showAlert(vc: self, title: "Message Sent Results", message: "Message send was cancelled.", completion:nil)
        case MFMailComposeResult.saved.rawValue:
            AlertPresenter.showAlert(vc: self, title: "Message Sent Results", message: "Message was saved successfully.", completion:nil)
        case MFMailComposeResult.sent.rawValue:
            AlertPresenter.showAlert(vc: self, title: "Message Sent Results", message: "Message was sent successfully.", completion:nil)
        case MFMailComposeResult.failed.rawValue:
            AlertPresenter.showAlert(vc: self, title: "Message Send Error",
                                     message: "Error: \(error?.localizedDescription).",
                                     completion:nil)
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    /// ---> Function for set custom color for cell <--- ///
    
    func setColorForCell(cell: UITableViewCell) -> UITableViewCell {
        let bgView = UIView()
        bgView.backgroundColor = self.bgColor
        
        cell.backgroundColor = self.bgColor
        cell.backgroundView  = bgView
        
        return cell
    }
    
    
    /// ---> Function for change constraint for follovers labels <--- ///
    
    func changeConstraint(view: UIView, constant: CGFloat, identifier: String) {
        let superview = view.superview
        
        let constaints = superview?.constraints.enumerated()
        
        for (_, value) in constaints! {
            let constraint = value as NSLayoutConstraint
            
            let valueId = constraint.identifier
            
            if valueId != nil {
                if valueId == identifier {
                    constraint.constant = constant
                }
            }
            
        }
    }
}
