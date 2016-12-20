//
//  ViewController.swift
//  Places
//
//  Created by Juan Manuel Jimenez Sanchez on 6/12/16.
//  Copyright © 2016 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    var places: [Place] = []
    var searchResult: [Place] = []
    var fetchResultController: NSFetchedResultsController<Place>!
    var searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //Así inclimos la barra de busqueda en la vista...
        self.searchController = UISearchController(searchResultsController: nil)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        //Personalización visual de la barra de busqueda...
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search places..."
        self.searchController.searchBar.tintColor = UIColor.white
        self.searchController.searchBar.barTintColor = UIColor.darkGray
        
        let fetchRequest: NSFetchRequest<Place> = NSFetchRequest(entityName: "Place")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        //Consultamos todos los lugares y los agregamos al array
        if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
            let context = container.viewContext
            self.fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            self.fetchResultController.delegate = self
            do {
                try self.fetchResultController.performFetch()
                self.places = self.fetchResultController.fetchedObjects!
                
                //Si es la primera vez entonces la BD está vacía y cargamos los lugares por defecto
                let defaults = UserDefaults.standard
                if !defaults.bool(forKey: "hasLoadDefaultInfo") {
                    self.loadDefaultData()
                    defaults.set(true, forKey: "hasLoadDefaultInfo")
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func loadDefaultData() {
        let names = ["Great Wall", "Tower of Pisa", "La Seu de Mallorca", "Alexanderplatz", "Atomium", "Big ben", "Cristo Redentor", "Torre Eiffel"]
        let types = ["Monument", "Monument", "Catedral", "Square", "Museum", "Monument", "Monument", "Monument"]
        let locations = ["Great Wall, Mutianyu Beijing, China", "Piazza del Duomo, 56126 Pisa PI, Italia", "La Seu Plaza de la Seu 5 07001 Palma Baleares, España", "Alexanderstraße 4 10178 Berlin, Deutschland", "Atomiumsquare 11020 Bruxelles, België", "London SW1A 0AA England", "Parque Nacional da Tijuca Alto da Boa Vista Rio de Janeiro - RJ 21072, Brasil", "5 Avenue Anatole France 75007 Paris, France"]
        let telephones = ["+27 20 7219 4272","+27 20 7219 4272","+27 20 7219 4272","+27 20 7219 4272","+27 20 7219 4272","+27 20 7219 4272","+27 20 7219 4272","+27 20 7219 4272"]
        let webs = ["https://en.wikipedia.org/wiki/Great_Wall_of_China", "http://www.towerofpisa.org/", "http://www.catedraldemallorca.info/principal/", "https://es.wikipedia.org/wiki/Alexanderplatz", "http://atomium.be/", "https://es.wikipedia.org/wiki/Big_Ben", "https://es.wikipedia.org/wiki/Cristo_Redentor", "http://www.toureiffel.paris/"]
        let images = [#imageLiteral(resourceName: "murallachina"),#imageLiteral(resourceName: "torrepisa"),#imageLiteral(resourceName: "mallorca"),#imageLiteral(resourceName: "alexanderplatz"),#imageLiteral(resourceName: "atomium"),#imageLiteral(resourceName: "bigben"),#imageLiteral(resourceName: "cristoredentor"),#imageLiteral(resourceName: "torreeiffel")]
        
        if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
            let context = container.viewContext
            
            for i in 0..<names.count {
                let place = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context) as? Place
                
                place?.name = names[i]
                place?.type = types[i]
                place?.location = locations[i]
                place?.phone = telephones[i]
                place?.web = webs[i]
                place?.rating = "rating"
                place?.image = UIImagePNGRepresentation(images[i]) as NSData?
                
                do {
                    try context.save()
                } catch {
                    print("Ha habido al guardar el lugar en Core Data")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Mostramos el tutorial solo si el usuario nunca lo ha visto...
        let defaults = UserDefaults.standard
        let hasViewedTutorial = defaults.bool(forKey: "hasViewedTutorial")
        if hasViewedTutorial {
            return
        }
        if let tutorialVC = storyboard?.instantiateViewController(withIdentifier: "tutorialPageID") as? TutorialPageViewController {
            self.present(tutorialVC, animated: true, completion: nil)
        }
        //------------------------
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Esta función retornando el valor 'true' indica que preferimos ocultar la barra de estado
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: -UITableViewDataSource
    //Estas 3 funciones a continuación, son necesarias para poder desplegar datos en la TableView
    
    //Esta función indica el número de secciones de la tabla (normalmente es 1)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Esta función indica el número de filas por sección.
    //Como no tenemos paginador entonces le indicamos el número total de elementos en el arreglo.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            return self.searchResult.count
        } else {
            return self.places.count
        }
    }
    
    //Esta función aplica para cada fila de la tabla
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place: Place!
        
        if self.searchController.isActive {
            place = self.searchResult[indexPath.row]
        } else {
            place = self.places[indexPath.row]
        }
        
        let cellID = "PlaceCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PlaceCell
        
        //Así es cuando tenemos elementos personalizados en la fila...
        cell.thumbnailimageView.image = UIImage(data: place.image! as Data)
        cell.nameLabel.text = place.name
        cell.typeLabel.text = place.type
        cell.locationLabel.text = place.location
        
        return cell
    }
    
    //MARK: -UITableViewDelegate
    
    //Esta función habilita las opciones que aparecen al desplazar lateralmente la fila
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Compartir
        let shareAction = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            let place: Place!
            
            if self.searchController.isActive {
                place = self.searchResult[indexPath.row]
            } else {
                place = self.places[indexPath.row]
            }
            
            let shareDefaultText = "Estoy visitando \(place.name) en la App de Juan Manuel"
            let activityController = UIActivityViewController(activityItems: [shareDefaultText, UIImage(data: place.image! as Data)!], applicationActivities: nil)
            
            self.present(activityController, animated: true, completion: nil)
        }
        shareAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        //Eliminar
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
                let context = container.viewContext
                let placeToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(placeToDelete)
                
                do {
                    try context.save()
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        return [shareAction, deleteAction]
    }
    
    //Esta función se ejecuta cuando tocamos un área delimitada para un segue (un enlace a otro viewController)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Si el identificador corresponde al segue que va al detalle de la receta
        if segue.identifier == "showDetail" {
            //Obtenemos el indexPath de la fila seleccionada
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //Obtenemos el lugar seleccionado
                let place: Place!
                
                if self.searchController.isActive {
                    place = self.searchResult[indexPath.row]
                    self.searchController.isActive = false//Ocultamos la barra al pasar al detalle
                } else {
                    place = self.places[indexPath.row]
                }
                //Obtenemos el controlador de destino
                let destinationViewController = segue.destination as! DetailViewController
                //Almacenamos en destino el lugar
                destinationViewController.place = place
            }
        }
    }
    
    //Cuando se regresa de cualquier vista hasta esta vista...
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {
        //Si viene desde la vista de agregar lugar
        if segue.identifier == "unwindFromAddPlaceVC" {
            if let addPlaceVC = segue.source as? AddPlaceViewController {
                if let newPlace = addPlaceVC.place {
                    self.places.append(newPlace)
                    //self.tableView.reloadData()
                }
            }
        }
    }
    
    /**
     Realiza el proceso de filtrado de lugares
     */
    func filterContentFor(textToSearch: String) {
        self.searchResult = self.places.filter({ (place) -> Bool in
            let nameToFind = place.name.range(of: textToSearch, options: .caseInsensitive)
            let typeToFind = place.type.range(of: textToSearch, options: .caseInsensitive)
            let locationToFind = place.location.range(of: textToSearch, options: .caseInsensitive)
            return nameToFind != nil || typeToFind != nil || locationToFind != nil
        })
    }
}

/*
 Este controllador se encarga de actualizar automaticamente nuestra lista de lugares cada vez que haya
 un cambio (insert, update, delete)
 */
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                self.tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        }
        self.places = controller.fetchedObjects as! [Place]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}


extension ViewController: UISearchResultsUpdating {
    //Obtiene el texto de la barra de busqueda y llama a la función de busqueda pasandole este texto
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            self.filterContentFor(textToSearch: searchText)
            self.tableView.reloadData()
        }
    }
}
