//
//  ViewController.swift
//  A2_FA_ios_Kirna_779568
//
//  Created by user165337 on 1/31/21.
//  Copyright © 2021 user165337. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    
    var products:[Product]?
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     var managedContext: NSManagedObjectContext!
       
    @IBOutlet var textFields: [UITextField]!
   override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
     managedContext = appDelegate.persistentContainer.viewContext
           
    
   // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
     NotificationCenter.default.addObserver(self, selector: #selector(saveCoreData), name: UIApplication.willResignActiveNotification, object: nil)
           
   // loadData()
    loadCoreData()
    }

//MARK:- add button
    @IBAction func AddProduct(_ sender: UIBarButtonItem) {
        let ID = Int(textFields[0].text ?? "0000") ?? 0000
        let Name = textFields[1].text ?? ""
        let Description = textFields[2].text ?? ""
        let Price = Int(textFields[3].text ?? "0000") ?? 0000
        let Provider = textFields[4].text ?? ""
        
        let product = Product(ID: ID, Name: Name, Description: Description, Price: Price, Provider: Provider)
           products?.append(product)
        
        for textField in textFields {
            textField.text = ""
            textField.resignFirstResponder()
        }
    }
    
    //MARK:- get path
    func getDataFilePath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = documentPath.appending("/book-data.txt")
        return filePath
    }
    //MARK:- load data
    func loadData() {
        products = [Product]()
        
         let filePath = getDataFilePath()
               
               if FileManager.default.fileExists(atPath: filePath) {
                   
                   do {
                       // creating string of the file path
                       let fileContent = try String(contentsOfFile: filePath)
                       // seperating the books from each other
                       let contentArray = fileContent.components(separatedBy: "\n")
                       for content in contentArray {
                           // seperating each book's contents
                           let ProductContent = content.components(separatedBy: ",")
                           if ProductContent.count == 5 {
                               let product = Product(ID: Int(ProductContent[0])!, Name: ProductContent[1], Description: ProductContent[2], Price: Int(ProductContent[3])!, Provider: ProductContent[5])
                               products?.append(product)
                           }
                       }
                   } catch {
                       print(error)
                   }
                   
               }    }
    // MARK:- prepare for seague
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
           if let productListTableVC = segue.destination as? ProdController {
               productListTableVC.products = self.products
           }
   }
    
    
    
    
    // MARK:- savaData
       @ objc func saveData() {
           let filePath = getDataFilePath()
           
           var saveString = ""
           for product in products! {
            saveString = "\(saveString)\(product.ID) ,\(product.Name),\(product.Description),\(product.Price),\(product.Provider)\n"
           }
           
           do {
               try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
           } catch {
               print(error)
           }
       }
    //MARK:- load core data
    func loadCoreData() {
           products = [Product]()
           
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
           
           do {
               let results = try managedContext.fetch(fetchRequest)
               if results is [NSManagedObject] {
                   for result in (results as! [NSManagedObject]) {
                       let name = result.value(forKey: "Name") as! String
                       let provider = result.value(forKey: "Provider") as! String
                    let id = result.value(forKey: "ID") as! Int
                    let price = result.value(forKey: "Price") as! Int
                    let description = result.value(forKey: "Desription") as! String
                    products?.append(Product(ID: id, Name: name, Description: description, Price: price, Provider: provider))
                   }
               }
               
           } catch {
               print(error)
           }
    }
@objc func saveCoreData() {
    //clearCoreData()
   // let appDelegate = UIApplication.shared.delegate as! AppDelegate
  //  let managedContext = appDelegate.persistentContainer.viewContext
    
    let productEntity = NSEntityDescription.insertNewObject(forEntityName: "A2_FA_ios_Kirna_779568", into: managedContext)
    for product in products! {
        let productEntity = NSEntityDescription.insertNewObject(forEntityName: "A2_FA_ios_Kirna_779568", into: managedContext)
        productEntity.setValue(product.Name, forKey: "Name")
        productEntity.setValue(product.Provider, forKey: "Provider")
        
    }
    
    do {
        try managedContext.save()
    } catch {
        print(error)
    }
        
}
    func clearCoreData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
//        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                if let managedObject = result as? NSManagedObject {
                    managedContext.delete(managedObject)
                }
            }
        } catch {
            print("Error deleting records \(error)")
        }
        
    }
}
