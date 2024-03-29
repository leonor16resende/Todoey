//
//  ViewController.swift
//  Todoey
//
//  Created by Leonor Resende on 21/07/2019.
//  Copyright © 2019 Leonor Resende. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeViewController {

    let realm = try! Realm()
    var toDoItems : Results<Item>?
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        guard let colourHex = selectedCategory?.color else { fatalError() }
        updateNavBar(withHexCode: colourHex)
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {        
        updateNavBar(withHexCode: "007AFF")
    }
    
    // MARK: - Navbar setup methods
    func updateNavBar(withHexCode colourHexCode : String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Bar does not exist")
        }
        
        guard let navBarColor = UIColor(hexString: colourHexCode) else {fatalError() }
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:ContrastColorOf(navBarColor, returnFlat: true)]
                
        searchBar.barTintColor = navBarColor

    }
    
    // MARK: TableView data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title

            if let colour = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                cell.tintColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        }
        else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    // MARK: TableView delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Mark as done
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }
            catch {
                print("Error saving done status \(error)")
            }
        }
        
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    
    }
    
    // MARK: Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch {
                    print("Error saving new items \(error)")
                }
            }
            
            self.tableView.reloadData()

        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Delete item
    override func updateModel(at indexPath: IndexPath) {
        // Delete
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            }
            catch {
                print("Error saving done status \(error)")
            }
        }
    }
    
    
    // MARK: - Load items
    func loadItems() {

        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()

    }
    
}

// MARK: Search Bar methods
extension ToDoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
