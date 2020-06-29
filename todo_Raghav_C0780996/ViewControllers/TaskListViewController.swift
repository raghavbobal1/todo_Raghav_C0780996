//
//  TaskListViewController.swift
//  todo_Raghav_C0780996
//
//  Created by Raghav Bobal on 2020-06-29.
//  Copyright © 2020 com.lambton. All rights reserved.
//

import UIKit

import CoreData

class TaskListViewController: UIViewController {
   
    @IBOutlet weak var sortSegment: UISegmentedControl!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var tabelView: UITableView!
    
    var selectedSort = 0
    var selectedCategory: Category? {
        didSet {
            loadTodos()
        }
    }
    
    var categoryName: String!
    let todoListContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tasksArray = [Todo]()
    var selectedTodo: Todo?
    var todoToMove = [Todo]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
               showSearchBar()
               categoryLabel.text = selectedCategory!.name
        
    }
    
   
    @IBAction func addTodo(_ sender: Any) {
        performSegue(withIdentifier: "todoViewScreen", sender: self)
    }
    
    
    @IBAction func sortToDo(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
               case 0: selectedSort = 0
                   break
               case 1: selectedSort = 1
                   break
               default:
                   break
               }
               
               loadTodos()
               tabelView.reloadData()
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? TodoViewController {
            destination.delegate = self
            if selectedTodo != nil
            {
                destination.todo = selectedTodo
            }
        }
        
        if let destination = segue.destination as? MoveTodoViewController {
                destination.selectedTodo = todoToMove
        }
        
    }
    @IBAction func unwindToTaskListView(_ unwindSegue: UIStoryboardSegue) {
        saveTodos()
        loadTodos()
        tabelView.reloadData()
    }
    
   
    
}//class end
extension TaskListViewController {
    func loadTodos(with request: NSFetchRequest<Todo> = Todo.fetchRequest(), predicate: NSPredicate? = nil) {
           
           let sortOptions = ["date", "name"]
            let todoPredicate = NSPredicate(format: "parentFolder.name=%@", selectedCategory!.name!)
           request.sortDescriptors = [NSSortDescriptor(key: sortOptions[selectedSort], ascending: true)]
           if let addtionalPredicate = predicate
           {
               request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [todoPredicate, addtionalPredicate])
           } else
           {
               request.predicate = todoPredicate
           }
           
           do {
               tasksArray = try todoListContext.fetch(request)
           } catch {
               print("Error loading todos \(error.localizedDescription)")
           }
           
       }
    
    func deleteTodoFromList() {
        
        todoListContext.delete(selectedTodo!)
        tasksArray.removeAll { (Todo) -> Bool in
            Todo == selectedTodo!
        }
        tabelView.reloadData()
        
    }
    
    func saveTodos() {
        do {
            try todoListContext.save()
        } catch {
            print("Error  \(error.localizedDescription)")
        }
    }
    
    func updateTodo() {
        saveTodos()
        tabelView.reloadData()
    }
    
    func markTodoCompleted() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let folderPredicate = NSPredicate(format: "name MATCHES %@", "Archived")
        request.predicate = folderPredicate
        do {
            let category = try context.fetch(request)
            self.selectedTodo?.parentFolder = category.first
            saveTodos()
            tasksArray.removeAll { (Todo) -> Bool in
                Todo == selectedTodo!
            }
            tabelView.reloadData()
        } catch {
            print("Error fetching data \(error.localizedDescription)")
        }
        
    }
    
    
    func saveTodo(title: String, dueDate: Date)
    {
        let todo = Todo(context: todoListContext)
        todo.name = title
        todo.due_date = dueDate
        todo.date = Date()
        todo.parentFolder = selectedCategory
        saveTodos()
        tasksArray.append(todo)
        tabelView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
           selectedTodo = nil
       }
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTableView() {
        tabelView.delegate = self
        tabelView.dataSource = self
        tabelView.estimatedRowHeight = 44
        tabelView.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return tasksArray.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
                   let task = tasksArray[indexPath.row]
                   cell.textLabel?.text = task.name
                   if (task.due_date! < Date() && task.parentFolder?.name != "Archived") {
                    cell.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                   }
                   if (Calendar.current.isDateInToday(task.due_date!) && task.parentFolder?.name != "Archived") {
                    cell.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                   }
                   return cell
       }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            self.todoListContext.delete(self.tasksArray[indexPath.row])
            self.tasksArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completion(true)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.6008332166, green: 0.1533286675, blue: 0.6352941176, alpha: 1)
        delete.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let complete = UIContextualAction(style: .normal, title: "Done") { (action, view, completion) in
               self.selectedTodo = self.tasksArray[indexPath.row]
               self.markTodoCompleted()
           }
           let move = UIContextualAction(style: .normal, title: "Move") { (action, view, completion) in
               self.todoToMove.append(self.tasksArray[indexPath.row])
               self.performSegue(withIdentifier: "moveTodoScreen", sender: nil)
           }
           complete.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
           complete.image = UIImage(systemName: "checkmark.circle.fill")
           move.backgroundColor = #colorLiteral(red: 0.3125264625, green: 0.452648486, blue: 0.9764705896, alpha: 1)
           move.image = UIImage(systemName: "arrowshape.turn.up.right.fill")
           return UISwipeActionsConfiguration(actions: [complete, move])
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           selectedTodo = tasksArray[indexPath.row]
           performSegue(withIdentifier: "todoViewScreen", sender: self)
       }
}

extension TaskListViewController: UISearchBarDelegate {
    //search task
    func showSearchBar() {
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Category Folder"
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .black
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        loadTodos(predicate: predicate)
        tabelView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadTodos()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
        loadTodos()
        tabelView.reloadData()
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadTodos()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        tabelView.reloadData()
        searchBar.resignFirstResponder()
    }
}

