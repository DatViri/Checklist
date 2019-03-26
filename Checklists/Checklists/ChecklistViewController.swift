//
//  ViewController.swift
//  Checklists
//
//  Created by Dat Truong on 11/03/2019.
//  Copyright © 2019 Dat Truong. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    // This declares that items will hold an array of ChecklistItem objects
    // but it does not actually create that array.
    // At this point, items does not have a value yet.
    var items : [ChecklistItem]
    var checklist: Checklist!
        
    required init?(coder aDecoder: NSCoder) {
        
        items = [ChecklistItem]()
        super.init(coder: aDecoder)
        loadChecklistItems()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = checklist.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        // Ask array for ChecklistItem object at index corresponds to row number
        let item = items[indexPath.row]
        
        configureTextForCell(cell: cell, withChecklistItem: item)
        configureCheckmarkForCell(cell: cell, withChecklistItem: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = items[indexPath.row]
            
            item.toggleChecked()
            configureCheckmarkForCell(cell: cell, withChecklistItem: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        saveCheckListItems()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //1 remove item from data model
        items.remove(at: indexPath.row)
        
        //2 remove row from table
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths as [IndexPath], with: .automatic)
        saveCheckListItems()
    }
    
    func configureCheckmarkForCell(cell: UITableViewCell, withChecklistItem item: ChecklistItem) {
        let label = cell.viewWithTag(1001) as! UILabel
        
        if item.checked{
            label.text = "√"
        } else {
            label.text = ""
        }
    }
    
    func configureTextForCell(cell: UITableViewCell, withChecklistItem item: ChecklistItem){
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }
    
    
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func itemDetailViewController(controller: ItemDetailViewController,
                                  didFinishAddingItem item: ChecklistItem) {
        
        let newRowIndex = items.count
        items.append(item)
        
        let indexPath = NSIndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths as [IndexPath],
                             with: .automatic)
        dismiss(animated: true, completion: nil)
        saveCheckListItems()
    }
    
    func itemDetailViewController(controller: ItemDetailViewController,
                               didFinishEditingItem item: ChecklistItem) {
        if let index = items.firstIndex(of: item) {
            let indexPath = NSIndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                configureTextForCell(cell: cell, withChecklistItem: item)
            }
        }
        dismiss(animated: true, completion: nil)
        saveCheckListItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //1
        if segue.identifier == "AddItem" {

            let navigationController = segue.destination
                as! UINavigationController
            let controller = navigationController.topViewController
                as! ItemDetailViewController
            controller.delegate = self
            
        } else if segue.identifier == "EditItem"{
            
            let navigationController = segue.destination
                as! UINavigationController
            let controller = navigationController.topViewController
                as! ItemDetailViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(
                for: sender as! UITableViewCell) {
                controller.itemToEdit = items[indexPath.row]
            }
        }
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString)
            .appendingPathComponent("Checklists.plist")
    }
    
    func saveCheckListItems(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(items, forKey: "ChecklistItems")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
    }
    
    func loadChecklistItems() {
        // 1
        let path = dataFilePath()
        // 2
        if FileManager.default.fileExists(atPath: path) {
            // 3
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)
                items = unarchiver.decodeObject(forKey: "ChecklistItems")
                    as! [ChecklistItem]
                unarchiver.finishDecoding()
            }
        }
    }
}

