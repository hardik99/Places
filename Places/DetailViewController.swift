//
//  DetailViewController.swift
//  Places
//
//  Created by Juan Manuel Jimenez Sanchez on 6/12/16.
//  Copyright © 2016 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var placeImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var ratingButton: UIButton!
    
    var place: Place!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.place.name

        self.placeImageView.image = self.place.image
        //Aquí cambiamos el color de fondo de la tabla
        self.tableView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        //Si al final hay celdas sin usar, entonces les damos un tamaño de cero para que no se vean
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        //Aquí elegimos el color de la linea separadora de celdas
        self.tableView.separatorColor = #colorLiteral(red: 0.9460816062, green: 0.9460816062, blue: 0.9460816062, alpha: 1)
        
        //Esto es para que el tamaño de la fila sea dinamico dependiendo del contenido
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension

        //Cargamos la imagen según la valoración que tenga
        let image = UIImage(named: self.place.rating)
        self.ratingButton.setImage(image, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {
        if let reviewVC = segue.source as? ReviewViewController {
            if let rating = reviewVC.ratingSelected {
                //Guardamos en el objeto la valoración que se acaba de dar
                self.place.rating = rating
                //Cargamos la imagen según la valoración dada
                let image = UIImage(named: self.place.rating)
                self.ratingButton.setImage(image, for: .normal)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showMap" {
            let destination = segue.destination as! MapViewController
            destination.place = self.place
        }
    }

}

extension DetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailViewCell", for: indexPath) as! PlaceDetailViewCell
        //Le quitamos el fondo a las celdas para que se vea el fondo de la tabla como tal.
        cell.backgroundColor = UIColor.clear
        
        switch indexPath.row {
        case 0:
            cell.keyLabel.text = "Name:"
            cell.valueLabel.text = self.place.name
        case 1:
            cell.keyLabel.text = "Tipo:"
            cell.valueLabel.text = self.place.type
        case 2:
            cell.keyLabel.text = "Localización:"
            cell.valueLabel.text = self.place.location
        case 3:
            cell.keyLabel.text = "Phone number:"
            cell.valueLabel.text = self.place.phone
        case 4:
            cell.keyLabel.text = "Web:"
            cell.valueLabel.text = self.place.web
        default:
            break
        }
        
        return cell
    }
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            //Hemos seleccionado la geolocalización
            self.performSegue(withIdentifier: "showMap", sender: nil)
        default:
            break
        }
    }
}
