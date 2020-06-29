//
//  MoveToDoViewController.swift
//  todo_Raghav_C0780996
//
//  Created by Raghav Bobal on 2020-06-29.
//  Copyright © 2020 com.lambton. All rights reserved.
//

import UIKit
import CoreData

class FolderChangeViewController: UIViewController {
    
    var categories = [Category]()
    var selectedTodo: [Todo]?
    {
        didSet
        {
            loadCategories()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    let moveTodoContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func cancelButtonTapped(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
}

extension FolderChangeViewController
{
    func loadCategories()
    {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let categoryPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedTodo?[0].parentFolder?.name ?? "")
        request.predicate = categoryPredicate
        
        do
        {
            categories = try moveTodoContext.fetch(request)
        }
        catch
        {
            print("Error fetching data \(error.localizedDescription)")
        }
    }
}

// Listing all categories
extension FolderChangeViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
            for todo in self.selectedTodo!
            {
                todo.parentFolder = self.categories[indexPath.row]
            }
            self.performSegue(withIdentifier: "goBackToTaskList", sender: self)
    }
}
import UIKit
import CoreData

class FolderChangeViewController: UIViewController {
    
    var categories = [Category]()
    var selectedTodo: [Todo]?
    {
        didSet
        {
            loadCategories()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    let moveTodoContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func cancelButtonTapped(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
}

extension FolderChangeViewController
{
    func loadCategories()
    {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let categoryPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedTodo?[0].parentFolder?.name ?? "")
        request.predicate = categoryPredicate
        
        do
        {
            categories = try moveTodoContext.fetch(request)
        }
        catch
        {
            print("Error fetching data \(error.localizedDescription)")
        }
    }
}

// Listing all categories
extension FolderChangeViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
            for todo in self.selectedTodo!
            {
                todo.parentFolder = self.categories[indexPath.row]
            }
            self.performSegue(withIdentifier: "goBackToTaskList", sender: self)
    }
}
