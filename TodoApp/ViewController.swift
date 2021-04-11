//
//  ViewController.swift
//  TodoApp
//
//  Created by ith on 04/04/2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // get the core data context for that view
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // create a table view
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // stores the item
    private var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todo List"
        // adding the sub table view to the main view
        view.addSubview(tableView)
        // load all the persistent data
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        // create a bar button on the right side and map a function to its action
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        // using auto-layout contraints to adapt the table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    // button for adding items to the list
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }
    
    // returns the number of list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    // returns the table cell after updating
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    // adding swipe to delete for table rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // if the delete button is clicked
        if editingStyle == .delete {
            // deselect the row
            tableView.deselectRow(at: indexPath, animated: true)
            // get the current item name
            let itemToDelete = models[indexPath.row]
            // alert to show for deletion
            let deleteAlert = UIAlertController(title: "Delete", message: "Do you really want to delete this item?", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                // delete the item
                self.deleteItem(item: itemToDelete)
            }))
            // on selecting NO, do nothing
            deleteAlert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            
            self.present(deleteAlert, animated: true)
        }
    }
    
    // add mapping for when the user selects a row in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        // add custom actions that the user can make after selecting a row
        let sheet = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        // on cancel
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // on edit
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            // create a new alert dialog with the item name prefilled
            let alert = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            // on clicking save, the new item name will be updated for that row
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                self?.updateItem(item: item, newName: newName)
            }))
            
            self.present(alert, animated: true)
        }))
        
        present(sheet, animated: true)
    }

    
    // Core Data functionalities
    
    func getAllItems() {
        do {
            // fetches all item from our coredata
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                // update the table
                self.tableView.reloadData()
            }
        } catch {
            // error
        }
    }
    
    // creates a new item in our coredata memory
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        do {
            // save the context for the coredata
            try context.save()
            // refresh the view after adding item
            getAllItems()
        } catch {
            // error
        }
    }
    
    // delete the item
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        do {
            try context.save()
            // refresh the view after deleting item
            getAllItems()
        } catch {
            // error
        }
    }
    
    // update the item
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        do {
            try context.save()
            // refresh the view after updating item
            getAllItems()
        } catch {
            // error
        }
    }
}

