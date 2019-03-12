//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Dat Truong on 12/03/2019.
//  Copyright © 2019 Dat Truong. All rights reserved.
//

import Foundation

class ChecklistItem {
    var text = ""
    var checked = false
    
    func toggleChecked() {
        checked = !checked
    }
}
