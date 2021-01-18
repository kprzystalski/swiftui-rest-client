//
//  sklep_restApp.swift
//  sklep-rest
//
//  Created by kprzystalski on 18/01/2021.
//

import SwiftUI
import CoreData

@main
struct sklep_restApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        loadFromAPI()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

extension sklep_restApp {
    
    func loadFromAPI() {
        let context = persistenceController.container.viewContext
        let serverURL = "https://ee1f9c582778.ngrok.io/kategoria"
        
        let url = URL(string: serverURL)
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let kategoriaEntity = NSEntityDescription.entity(forEntityName: "Kategoria", in: context)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                print("Houston mamy problem")
                return
            }
            
            guard data != nil else {
                print("Nie ma danych")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String:Any] {
                    print(object)
                } else if let object = json as? [Any] {
                    for item in object as! [Dictionary<String, AnyObject>] {
                        let title = item["title"] as! String
                        let server_id = item["id"] as! String
                        
                        let kategoria = NSManagedObject(entity: kategoriaEntity!, insertInto: context)
                        
                        kategoria.setValue(title, forKey: "title")
                        kategoria.setValue(server_id, forKey: "server_id")
                        
                        print("Dodano kategorię: \(title) o id: \(server_id)")
                    }
                    try context.save()
                } else {
                    print("Błędny JSON")
                }
                
            } catch {
                print("Problem z pobraniem odpowiedzi")
                return
            }
        })
        task.resume()
    }
}
