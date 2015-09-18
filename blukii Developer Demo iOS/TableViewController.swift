//
//  TableViewController.swift
//  Hello-Blukii-App-1
//
//  Created by Lennart Fleig on 02.04.15.
//  Copyright (c) 2015 Lennart Fleig. All rights reserved.
//

import UIKit
import CoreBluetooth
import blukiiKit

class TableViewController: UITableViewController, CBCentralManagerDelegate {

    lazy var centralManager: CBCentralManager = CBCentralManager(delegate: self, queue: nil)
    var blukiis = [CBPeripheral]()
    var rssis = [NSNumber]()
    var names = [NSString]()
    var lastSelectedIndexPath: NSInteger?
    var connectedBlukii: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "blukiiHeaderBanner"), forBarMetrics: UIBarMetrics.Default)
        //self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //Connected Blukii Disconnecten
        blukiis = [CBPeripheral]()
        rssis = [NSNumber]()
        names = [NSString]()
        if connectedBlukii != nil {
            centralManager.cancelPeripheralConnection(connectedBlukii!)
        }
        //Suche nach Blukiis wieder starten
        findPeripherals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blukiis.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        
        cell.textLabel?.text = names[indexPath.row] as String
        cell.detailTextLabel?.text = rssis[indexPath.row].stringValue
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Connect Blukii"
        centralManager.connectPeripheral(blukiis[indexPath.row], options: nil)
    }
  
    //MARK: Bluetooth
    
    func findPeripherals() {
        if self.centralManager.state == CBCentralManagerState.PoweredOn {
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
    
    //MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if centralManager.state == CBCentralManagerState.PoweredOn {
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        //Peripheral found
        if BKBlukiiDescription.isBlukiiDevice(peripheral) {
            blukiis.append(peripheral)
            rssis.append(RSSI)
            names.append(advertisementData[CBAdvertisementDataLocalNameKey]! as! NSString)
            tableView.reloadData()
        } else {
            print("No Blukii Peripheral")
        }

    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Device Connected")
        connectedBlukii = peripheral
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        self.performSegueWithIdentifier("showDetailView", sender: peripheral)
        
    }
    
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Device Disconnected")
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        if self.navigationController?.topViewController != self {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to Connect")
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailView" {
            (segue.destinationViewController as!  DetailViewController).blukii = sender as? CBPeripheral
            centralManager.stopScan()
        }
    }

}
