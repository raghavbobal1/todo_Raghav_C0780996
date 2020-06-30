//
//  TodoViewController.swift
//  todo_Raghav_C0780996
//
//  Created by Raghav Bobal on 2020-06-29.
//  Copyright © 2020 com.lambton. All rights reserved.
//

import UIKit
import CoreData

class TaskHandlingViewController: UIViewController
{
    @IBOutlet weak var todoTitleLabel: UITextField!
    @IBOutlet weak var taskText: UITextView!
    var todo: Todo?
    var delegate: TaskTableViewController?
    
    @IBOutlet weak var deadlineLabel: UIDatePicker!
    @IBOutlet weak var buttonStack: UIStackView!
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        //Gesture to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Removing options if the task is new
        if todo == nil {
            buttonStack.isHidden = true
        }
        //Setting values of existing tasks
        if let todoData = todo
        {
            taskText.text = todoData.taskText
            todoTitleLabel.text = todoData.name
            deadlineLabel.date = todoData.due_date!
        }
    }
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func saveTask(_ sender: Any) {
        if(checkTitle())
        {
            if todo == nil
            {
                delegate?.saveTodo(title: todoTitleLabel!.text!, taskText: taskText!.text!, dueDate: deadlineLabel!.date)
            }
            else
            {
                todo?.name = todoTitleLabel!.text!
                todo?.taskText = taskText!.text!
                todo?.due_date = deadlineLabel!.date
                delegate?.updateTodo()
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func markCompleted(_ sender: Any) {
        
        if(checkTitle()) {
            todo?.name = todoTitleLabel!.text!
            todo?.taskText = taskText!.text!
            todo?.due_date = deadlineLabel!.date
            delegate?.markTodoCompleted()
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func deleteTask(_ sender: Any) {
        
        delegate?.deleteTodoFromList()
        navigationController?.popViewController(animated: true)
    }
    
    
//    method to check weather title is empty or not
    func checkTitle() -> Bool {
        if (todoTitleLabel.text?.isEmpty ?? true) {
            let alert = UIAlertController(title: "Title can't be blank!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
}
