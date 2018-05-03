//
//  MovieTableViewController.swift
//  MovieInventory
//
//  Created by Paul Heintz on 4/27/18.
//  Copyright © 2018 Paul Heintz. All rights reserved.
//

import UIKit

class MovieTableViewController: UITableViewController {
    //MARK: Properties
    
    var movies = [Movie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem

        // Load any saved movies, otherwise alert user to add.
        if let savedMovies = loadMovies() {
            movies += savedMovies
            
            if movies.isEmpty {
                // Alert user no movies in inventory
                let alert = UIAlertController(title: "Nothing in Inventory", message: "There's nothing currently in inventory. Tap \"Add Movie\" to add something.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
        } else {
            // Alert user no movies in inventory
            let alert = UIAlertController(title: "Nothing in Inventory", message: "There's nothing currently in inventory. Tap \"Add Movie\" to add something.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        movies = movies.sorted { $0.title < $1.title }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MovieTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MovieTableViewCell.")
        }
        
        // Fetches the appropriate movie for the data source layout.
        let movie = movies[indexPath.row]
        
        cell.movieLabel.text = movie.title
        cell.barcodeLabel.text = movie.barcode

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            movies.remove(at: indexPath.row)
            saveMovies()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    //MARK: Actions
    
    @IBAction func unwindToMovieList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ScannerViewController, let movie = sourceViewController.movie {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing movie.
                movies[selectedIndexPath.row] = movie
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new movie.
                let newIndexPath = IndexPath(row: movies.count, section: 0)
                
                movies.append(movie)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the movies
            saveMovies()
        }
    }
    
    //MARK: Private Methods
    
    private func loadSampleMovies() {
        guard let movie1 = Movie(barcode: "0086162118456", title: "Office Space") else {
            fatalError("Unable to instantiate movie1")
        }
        guard let movie2 = Movie(barcode: "0025195054584", title: "9") else {
            fatalError("Unable to instantiate movie2")
        }
        guard let movie3 = Movie(barcode: "8083929301829", title: "Ferris Bueller's Day Off") else {
            fatalError("Unable to instantiate movie3")
        }
        
        movies += [movie1, movie2, movie3]
    }
    
    private func saveMovies() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(movies, toFile: Movie.ArchiveURL.path)
        
        if isSuccessfulSave {
            print("Movies successfully saved.")
        } else {
            print("Failed to save movies...")
        }
    }
    
    private func loadMovies() -> [Movie]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Movie.ArchiveURL.path) as? [Movie]
    }

}
