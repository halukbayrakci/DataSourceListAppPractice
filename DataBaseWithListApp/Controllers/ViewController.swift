//
//  ViewController.swift
//  DataBaseWithListApp
//
//  Created by HALUK BAYRAKCI
//

import UIKit
import CoreData

final class ViewController: UIViewController {
    
    @IBOutlet weak private var listAppTableView : UITableView!
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       fetch()
        
    }
    
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "NEW DATA ADD", message: nil, preferredStyle: .alert)
        let defaultButton = UIAlertAction(title: "ADD", style: .default) { _ in
            let alertTextField = alertController.textFields?.first?.text
            if alertTextField != "" {
                
                // Veriyi kaydetme
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let context = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListAppItem", in: context!)
                let listAppItem = NSManagedObject(entity: entity!, insertInto: context)
                
                listAppItem.setValue(alertTextField!, forKey: "listTitle")
                
                do {
                    try context?.save()
                } catch  {
                    print("Data is not save")
                }
                
                self.fetch()
    
            }else{
                let alertController = UIAlertController(title: "WARNING !", message: "You cannot leave the field blank !", preferredStyle: .alert)
                let defaultButton = UIAlertAction(title: "OK", style: .cancel)
                
                alertController.addAction(defaultButton)
                self.present(alertController, animated: true)
            }
            
        }
        
        let cancelButton = UIAlertAction(title: "CANCEL", style: .destructive)
        
        alertController.addTextField()
        alertController.addAction(defaultButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
        
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "WARNING!!", message: "Are you sure you want to delete all the elements in the list ? ", preferredStyle: .alert)
        let defaultButton = UIAlertAction(title: "DELETE", style: .destructive) { _ in
            
            
            self.deleteAllRecords()
            self.fetch()
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(defaultButton)
        alertController.addAction(cancelButton)
        self.present(alertController, animated: true)
    }
    
   
    
    func fetch() {
        // Veri çekme
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListAppItem")
        
        do {
            try data = (context?.fetch(fetchRequest))!
        } catch  {
            print("There was an error")
        }
        
        listAppTableView.reloadData()
    }
    
    func deleteAllRecords() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ListAppItem")
        let deleteFetchRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context?.execute(deleteFetchRequest)
        } catch  {
            print("There was error")
        }
    }
    
}

extension ViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let listItem = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = listItem.value(forKey: "listTitle") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "DELETE" ) { (_,_,_) in
            
            let alertController = UIAlertController(title: "Warning!", message: "Are you sure the data will be deleted ?", preferredStyle: .alert)
            let defaultButton = UIAlertAction(title: "Delete", style: .destructive) { _ in
                
                // Veri silme
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let context = appDelegate?.persistentContainer.viewContext
                
                context?.delete(self.data[indexPath.row])
                
                do {
                    try context?.save()
                } catch  {
                    print("Data is not save")
                }
                
                self.fetch()
            }
            
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(defaultButton)
            alertController.addAction(cancelButton)
            self.present(alertController, animated: true)
            
        }
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "EDIT") { _, _, _ in
            
            let alertController = UIAlertController(title: "NEW DATA ADD", message: nil, preferredStyle: .alert)
            let defaultButton = UIAlertAction(title: "ADD", style: .default) { _ in
                let alertTextField = alertController.textFields?.first?.text
                if alertTextField != "" {
                    
                    let appDeletegate = UIApplication.shared.delegate as? AppDelegate
                    let context = appDeletegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(alertTextField, forKey: "listTitle")
                    
                    if context!.hasChanges{
                        
                        do {
                            try context?.save()
                        } catch  {
                            print("Data is not save")
                        }
                    }
                    
                    self.listAppTableView.reloadData()
                }else{
                    let alertController = UIAlertController(title: "WARNING !", message: "You cannot leave the field blank !", preferredStyle: .alert)
                    let defaultButton = UIAlertAction(title: "OK", style: .cancel)
                    
                    alertController.addAction(defaultButton)
                    self.present(alertController, animated: true)
                }
                
            }
            
            alertController.addTextField()
            alertController.addAction(defaultButton)
            self.present(alertController, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [editAction])
    }
}


