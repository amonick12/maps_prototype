//
//  MyNavigationController.swift
//  Feed Me
//
//  Created by Aaron Monick on 3/3/15.
//  Copyright (c) 2015 Ron Kliffer. All rights reserved.
//

import UIKit

class MyNavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: FilterViewController(), menuPosition:.Right)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 200.0 // optional, default is 160
        //sideMenu?.bouncingEnabled = false
      
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
      println("sideMenuWillOpen")
    }
  
    func sideMenuWillClose() {
      println("sideMenuWillClose")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
