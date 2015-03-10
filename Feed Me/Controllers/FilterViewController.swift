//
//  FilterViewController.swift
//  Feed Me
//
//  Created by Aaron Monick on 3/3/15.
//  Copyright (c) 2015 Ron Kliffer. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate: class {
  func filterController(controller: FilterViewController, didSelectTypes types: [String])
}

class FilterViewController: UITableViewController, ENSideMenuDelegate {

  let possibleTypesDictionary = ["bakery":"Bakery", "bar":"Bar", "cafe":"Cafe", "grocery_or_supermarket":"Supermarket", "restaurant":"Restaurant"]
  var selectedTypes: [String]!
  //var selectedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]

  //weak var delegate: TypesTableViewControllerDelegate!
  weak var delegate: FilterViewControllerDelegate!

  var sortedKeys: [String] {
    get {
      return sorted(possibleTypesDictionary.keys)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.sideMenuController()?.sideMenu?.delegate = self
    selectedTypes = sideMenuController()?.sideMenu?.selectedTypes!
    println(selectedTypes)
    
    // Customize apperance of table view
    tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
    tableView.separatorStyle = .None
    tableView.backgroundColor = UIColor.clearColor()
    tableView.scrollsToTop = false
  }
  
  // MARK: - ENSideMenu Delegate
  func sideMenuWillOpen() {
    println("sideMenuWillOpen")
  }
  
  func sideMenuWillClose() {
    println("sideMenuWillClose")
    delegate?.filterController(self, didSelectTypes: selectedTypes)
  }
  
  // MARK: - Actions
  //  @IBAction func donePressed(sender: AnyObject) {
  //    delegate?.typesController(self, didSelectTypes: selectedTypes)
  //  }
  
  // MARK: - Table view data source
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return possibleTypesDictionary.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCellWithIdentifier("TypeCell", forIndexPath: indexPath) as UITableViewCell
//    let key = sortedKeys[indexPath.row]
//    let type = possibleTypesDictionary[key]!
//    cell.textLabel?.text = type
//    cell.imageView?.image = UIImage(named: key)
//    cell.accessoryType = contains(selectedTypes!, key) ? .Checkmark : .None
//    return cell
    
    var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
    
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
      let key = sortedKeys[indexPath.row]
      let type = possibleTypesDictionary[key]!
      cell!.textLabel?.text = type
      cell!.imageView?.image = UIImage(named: key)
      //cell!.accessoryType = contains(selectedTypes, key) ? .Checkmark : .None

    }
    
    //cell!.textLabel?.text = "ViewController #\(indexPath.row+1)"
    
    return cell!
  }
  
  // MARK: - Table view delegate
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let key = sortedKeys[indexPath.row]
    if contains(selectedTypes, key) {
      selectedTypes = selectedTypes.filter({$0 != key})
    } else {
      selectedTypes.append(key)
    }
    
    tableView.reloadData()
  }
}
