//
//  Extension+TableView.swift
//  todo_Raghav_C0780996
//
//  Created by Raghav Bobal on 2020-06-29.
//  Copyright © 2020 com.lambton. All rights reserved.
//

import Foundation
import UIKit

 //Extenstion to handle empty table views
 extension UITableView {

     func setEmptyMessage(_ message: String) {
         let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
         messageLabel.text = message
         messageLabel.textColor = .black
         messageLabel.numberOfLines = 0
         messageLabel.textAlignment = .center
         messageLabel.font = UIFont(name: "TrebuchetMS", size: 18)
         messageLabel.sizeToFit()

         self.backgroundView = messageLabel
         self.separatorStyle = .none
     }

     func restore() {
         self.backgroundView = nil
         self.separatorStyle = .singleLine
     }
 }

