//
//  ViewController.swift
//  WeightCapBLE
//
//  Created by Desmond Cain on 3/25/15.
//  Copyright (c) 2015 Desmond Cain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let sharedManager = MBLMetaWearManager.sharedManager()
    var device = MBLMetaWear.new()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sharedManager.startScanForMetaWearsWithHandler() {
            (deviceArray) -> Void in println("Detected MetaWear devices: \(deviceArray)")

            self.sharedManager.stopScanForMetaWears()
            
            self.device = deviceArray[0] as! MBLMetaWear
            
            self.device.connectWithHandler() {
                (error) -> Void in println("Connected to MetaWear: \(self.device)")
                
                self.flashLED()
                
                self.getBatteryLife()

                self.getSerialNumber()
                
                self.getFirmwareRevision()
                
                self.checkForFirmwareUpdates()
//
//                self.getHardwareRevision()
//
//                self.getManufacturerName()
                
//                self.getAmbientTemp()
                
                self.streamRMSData()
            }
            
            let config = self.device.configuration
            
//            self.device.setConfiguration(<#configuration: MBLRestorable!#>, handler: <#MBLErrorHandler!##(NSError!) -> Void#>)
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func streamRMSData() {
        if device.accelerometer.isKindOfClass(MBLAccelerometerMMA8452Q) {
            let accelerometer = self.device.accelerometer as! MBLAccelerometerMMA8452Q
            
            accelerometer.sampleFrequency = 100
            accelerometer.fullScaleRange = MBLAccelerometerRange(rawValue: 2)!
            accelerometer.highPassCutoffFreq = MBLAccelerometerCutoffFreq(rawValue: 0)!
            accelerometer.highPassFilter = true
        }
        
//        self.device.accelerometer.dataReadyEvent.startNotificationsWithHandler() {
//            (obj, error) -> Void in println("Raw Data: \(obj)")
//        }
        
        // Sum the RMS data
        let summedRMS = self.device.accelerometer.rmsDataReadyEvent.summationOfEvent()
        
        // Set logging interval
        let periodicRMS = summedRMS.periodicSampleOfEvent(2000)
        
        periodicRMS.startNotificationsWithHandler() {
            (obj, error) -> Void in println("RMS: \(obj)")
        }
        
//        self.device.accelerometer.rmsDataReadyEvent.startNotificationsWithHandler() {
//            (obj, error) -> Void in println("RMS: \(obj)")
//        }

        
//        self.device.accelerometer.fullScaleRange = MBLAccelerometerRange8G;  // Default: +- 8G
//        self.device.accelerometer.sampleFrequency = MBLAccelerometerSampleFrequency100 // Default: 100 Hz
//        [device.accelerometer.dataReadyEvent startNotificationsWithHandler:^(MBLAccelerometerData *obj, NSError *error) {
//            NSLog(@"X = %d, Y = %d, Z = %d", obj.x, obj.y, obj.z);
//        }];
    }
    
    func getBatteryLife() {
        self.device.readBatteryLifeWithHandler() {
            (number, error) -> Void in println("Battery: \(number)%")
        }
    }
    
    func getAmbientTemp() {
        self.device.temperature.source = MBLTemperatureSource.Internal
        self.device.temperature.units = MBLTemperatureUnit.Fahrenheit
        self.device.temperature.readTemperatureWithHandler() {
            (number, error) -> () in println("Temp: \(number)° F")
        }
    }
    
    func getSerialNumber() {
        var serialNumber = self.device.deviceInfo.serialNumber
        println("Serial #: \(serialNumber)")
    }
    
    func getFirmwareRevision() {
        var firmwareRevision = self.device.deviceInfo.firmwareRevision
        println("Firmware revision: \(firmwareRevision)")
    }
    
//    func updateFirmaware() {
//        self.device.updateFirmwareWithHandler(<#handler: MBLErrorHandler!##(NSError!) -> Void#>, progressHandler: <#MBLFloatHandler!##(Float, NSError!) -> Void#>)
//    }
    
    func checkForFirmwareUpdates() {
        self.device.checkForFirmwareUpdateWithHandler { (result: Bool, error) -> Void in
            if (result == true) {
                println("Update required")
            } else {
                println("No updates found")
            }
        }
    }
    
    func getHardwareRevision() {
        var hardwareRevision = self.device.deviceInfo.hardwareRevision
        println("Hardware revision: \(hardwareRevision)")
    }
    
    func getManufacturerName() {
        var manufacturerName = self.device.deviceInfo.manufacturerName
        println("Manufacturer Name: \(manufacturerName)")
    }
    
    func flashLED() {
        self.device.led.flashLEDColor(UIColor.whiteColor(), withIntensity: 0.5, numberOfFlashes: 5)
    }
    
    func disconnectDevice() {
        self.device.disconnectWithHandler() {
            (error) -> Void in println("Disconnected from MetaWear: \(self.device)")
        }
    }
    
    func rememberDevice() {
        self.device.rememberDevice()
    }
    
    func forgetDevice() {
        self.device.forgetDevice()
    }

}

