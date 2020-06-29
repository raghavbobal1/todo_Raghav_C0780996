//
//  ViewController.swift
//  todo_Raghav_C0780996
//
//  Created by Raghav Bobal on 2020-06-29.
//  Copyright © 2020 com.lambton. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var categoryContext: NSManagedObjectContext!
    var notificationArray = [Todo]()
    var categoryName = UITextField()
    var categoryArray: [Category] = [Category]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Performing set-up functions
        getCoreData()
        setUpTableView()
        firstTimeSetup()
        setUpNotifications()
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func addCategory(_ sender: Any)
    {
        let alert = UIAlertController(title: "Category Name", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: addCategoryName(textField:))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if(self.categoryName.text!.count < 1)
            {
                self.emptyFieldAlert()
                return
            }
            else
            {
                self.addNewCategory()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    //Alerting user to not leave the category text field empty
    func emptyFieldAlert()
    {
        let alert = UIAlertController(title: "Error!", message: "Name can't be empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //Dynamically adding textfield to enter category name
    func addCategoryName(textField: UITextField)
    {
        self.categoryName = textField
        self.categoryName.placeholder = "Enter Category Name"
    }

}

extension ViewController
{
    
    func getCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        categoryContext = appDelegate.persistentContainer.viewContext
        fetchCategoryData()
        
    }
    
    //Setting up default archive folder
    func firstTimeSetup() {
        let categoryNames = self.categoryArray.map {$0.name}
        guard !categoryNames.contains("Archived") else {return}
        let newCategory = Category(context: self.categoryContext)
        newCategory.name = "Archived"
        self.categoryArray.append(newCategory)
        do
        {
            try categoryContext.save()
            tableView.reloadData()
        }
        catch
        {
            print("Error saving categories \(error.localizedDescription)")
        }
    }
    
    //Function to get category data and display them in a table
    func fetchCategoryData()
    {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            categoryArray = try categoryContext.fetch(request)
        } catch {
            print("Error loading categories: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    //Function to add new category to category list
    func addNewCategory()
    {
        let categoryNames = self.categoryArray.map {$0.name}
        guard !categoryNames.contains(categoryName.text) else {self.showAlert(); return}
        let newCategory = Category(context: self.categoryContext)
        newCategory.name = categoryName.text!
        self.categoryArray.append(newCategory)
        do {
            try categoryContext.save()
            tableView.reloadData()
        } catch {
            print("Error saving categories \(error.localizedDescription)")
        }
    }
    
    //Alert preventing duplicate category names
    func showAlert()
    {
        let alert = UIAlertController(title: "Category Already Exists!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TaskTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    

    func setUpTableView()
    {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        if category.name == "Archived"
        {
            cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            cell.textLabel?.textColor = UIColor.blue
            //cell.textLabel?.textAlignment = .center
        }
        cell.textLabel?.text = category.name
        return cell
    }
    //Adding swipe left to delete table cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
                self.categoryContext.delete(self.categoryArray[indexPath.row])
                self.categoryArray.remove(at: indexPath.row)
                do {
                    try self.categoryContext.save()
                } catch {
                    print("Error saving the context \(error.localizedDescription)")
                }
                self.tableView.reloadData()
                completion(true)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        delete.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "noteListScreen", sender: self)
    }
}

extension ViewController {
    
    //Setting up notifications
    func setUpNotifications() {
        
        checkDueTasks()
        if notificationArray.count > 0 {
            for task in notificationArray {
                
                if let name = task.name {
                    let notificationCenter = UNUserNotificationCenter.current()
                    let notificationContent = UNMutableNotificationContent()
                    
                    notificationContent.title = "Task Reminder"
                    notificationContent.body = "Task: \(name) is due tommorow"
                    notificationContent.sound = .default
//                    sets up notification for a day before the task
                    let fromDate = Calendar.current.date(byAdding: .day, value: -1, to: task.due_date!)!
                    let components = Calendar.current.dateComponents([.month, .day, .year], from: fromDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: "\(name)taskid", content: notificationContent, trigger: trigger)
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print(error ?? "notification center error")
                        }
                    }
                }
            }
        }
        
    }
    
//    fetches the list of due tasks
    func checkDueTasks()
    {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        do
        {
            let notifications = try context.fetch(request)
            for task in notifications {
                if Calendar.current.isDateInTomorrow(task.due_date!)
                {
                    notificationArray.append(task)
                }
            }
        }
        catch
        {
            print("Error loading todos \(error.localizedDescription)")
    }
  }
}

