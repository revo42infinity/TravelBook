//
//  ListViewController.swift
//  TravelBook
//
//  Created by owner on 10/11/20.
//  Copyright © 2020 Caner Duru. All rights reserved.
//

import UIKit
import CoreData //6

class ListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource { //2

    @IBOutlet weak var tableView: UITableView!
    //8
    var titleArray = [String]()
    var idArray = [UUID]()
//20
    var chosenTitle = ""
    var chosenTitleID : UUID?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//4 sag ustte button ekleyecegiz
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        
        
//1
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()                       //15
        
    }
 //36  viewwillappear her gorunum gorundugunde cagiriyor. didload bir kere cagriliyor. selector de getdata diyebilmek icin asagida 7 nolu kodda basa @objc yaziyoruz. daha once yoktu. asgidakini yazinca artik save edince listede cikacak
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    
    
    
    
//7
    @objc func getData (){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
            
            if results.count > 0 {
//11 duplice seyler olmasin diye remove yapacagiz verileri temizleyecegiz
                self.titleArray.removeAll(keepingCapacity: false) //kapasiteyi tutma
                self.idArray.removeAll(keepingCapacity: false)
                
                
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)               //9
                        
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)                     //10
                        
                    }
//12 table view da gostermemiz gerekiyor
                    tableView.reloadData()
                }
            }
        }catch{
            print("error")
        }
        
    }
    
    
    
    
//5 selectorun func. addbutton clicked ismini biz verdik
    @objc func addButtonClicked(){
//21
        chosenTitle = "" //basinca bos gondericek
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    
    
    
//3
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//13        return 10 bunun yerine asagidaki
        return titleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
//14        cell.textLabel?.text = "test" bunun yerine asagidaki
            cell.textLabel?.text = titleArray[indexPath.row] //indexpath de ne varsa onu goster.boylece herseyi birbine bagladik
        
        return cell
    }
//19
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 //21
        chosenTitle = titleArray[indexPath.row] //ustune tiklanan title i bana getir
        chosenTitleID = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  //22
        if segue.identifier == "toViewController" { //eger buysa gercekten seguemiz
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = chosenTitle
            destinationVC.selectedTitleID = chosenTitleID
            
            
            
        }
    }
    
    
}
