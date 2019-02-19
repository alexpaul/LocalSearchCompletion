//
//  ViewController.swift
//  LocalSearchCompletion
//
//  Created by Alex Paul on 2/19/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  // setup search controller
  private lazy var searchController: UISearchController = {
    let sc = UISearchController(searchResultsController: nil)
    sc.dimsBackgroundDuringPresentation = false
    definesPresentationContext = false
    sc.searchBar.placeholder = "search for location"
    sc.hidesNavigationBarDuringPresentation = false
    sc.searchResultsUpdater = self
    return sc
  }()
  
  // setup local search completion
  private var searchCompleter = MKLocalSearchCompleter()
  private var completerResults = [MKLocalSearchCompletion]()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
    // set the table view datasource and delegate
    tableView.dataSource = self
    tableView.delegate = self 
    
    // set the MKLocalSearchCompleter delegate
    searchCompleter.delegate = self
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return completerResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
    let suggestion = completerResults[indexPath.row]
    cell.textLabel?.text = suggestion.title
    cell.detailTextLabel?.text = suggestion.subtitle
    return cell
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let suggestion = completerResults[indexPath.row]
    let address = suggestion.subtitle.isEmpty ? suggestion.title : suggestion.subtitle
    LocationService.getCoordinate(addressString: address) { (coordinate, error) in
      if let error = error {
        print("fetching coordinate error: \(error.localizedDescription)")
      } else {
        print("coordinate is \(coordinate)")
      }
    }
  }
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    // upate query fragment
    searchCompleter.queryFragment = searchController.searchBar.text ?? ""
  }
}

extension ViewController: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    completerResults = completer.results
    tableView.reloadData()
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    print("didFailWithError: \(error.localizedDescription)")
  }
}

