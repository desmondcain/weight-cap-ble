# MetaWear IOS API by MBIENTLAB

<img src="http://mbientlab.com/metawear.png" alt="MetaWear" title="MetaWear" />

### Overview

[MetaWear](https://mbientlab.com) is a complete development and production platform for wearable and connected device applications.

MetaWear features a number of sensors and peripherals all easily controllable over Bluetooth 4.0 Low Energy using this iOS API, no firmware or hardware experience needed!

It comes pre-loaded with a wirelessly upgradeable firmware, so you can always take advantage of the latest features.

### Requirements
- [MetaWear board](http://mbientlab.com/store/)
- [Apple developer account](https://developer.apple.com/programs/ios/), note there are fees associated.
- Device running iOS 7.1 or later with Bluetooth 4.0

> REQUIREMENT NOTES  
The iOS simulator doesn’t support Bluetooth 4.0, so test apps must be run on a real iOS device which requires a developer account.  Bluetooth 4.0 avaliable on iPhone 4S+, iPad 3rd generation+, or iPod Touch 5th generation.

### License
See the [License](https://github.com/mbientlab/Metawear-iOSAPI/blob/master/LICENSE)

### Support
Reach out to the [community](http://community.mbientlab.com) if you encounter any problems, or just want to chat :)

## Getting Started

### Installation

If you are familiar with [CocoaPods](http://cocoapods.org/), you can use the pod named `'Metawear-iOSAPI'`.

Otherwise, download this project.  The API is available as a Framework for iOS called the MetaWear.framework. You will see a few header files along with a framework file included in your download.  To install, simply drag the MetaWear.framework folder into your Xcode project.

<img src="http://mbientlab.com/FrameworkSetup.png" alt="FrameworkSetup" title="FrameworkSetup" />

### Simple API Test

Here is a walkthrough to showcase a very basic connect and toggle LED operation.

First, import the framework header files like this:
```obj-c
#import <MetaWear/MetaWear.h>
```

Then add the following code wherever appropriate to make the LED flash green:
```obj-c
// Begin scanning for MetaWear boards
[[MBLMetaWearManager sharedManager] startScanForMetaWearsWithHandler:^(NSArray *array) {
    // Hooray! We found a MetaWear board, so stop scanning for more
    [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
    // Connect to the board we found
    MBLMetaWear *device = [array firstObject];
    [device connectWithHandler:^(NSError *error) {
        if (!error) {
            // Hooray! We connected to a MetaWear board, so flash its LED!
            [device.led flashLEDColor:[UIColor greenColor] withIntensity:0.5];
        }
    }];
}];
```
Now run the app on a physical device. 

*BLUETOOTH IS NOT SUPPORTED IN THE SIMULATOR* and you will receive a build ERROR when you attempt to compile a MetaWear project in the simulator.

### Sample iOS App

A sample iOS App using the MetaWear iOS API can be found at https://github.com/mbientlab/Metawear-SampleiOSApp.

The sample iOS App demonstrates the base functionality of the various MetaWear modules and serves as a good starting point for developers.

## API Documentation

### API Quickstart

The core class is MBLMetaWear, it corresponds to a physical MetaWear board and contains pointers to encapsulated sensor and peripheral objects which perform the real life functions.  The MBLMetaWear objects are created by the MBLMetaWearManager, which scans for devices.

<img src="http://mbientlab.com/MetaWearAPIQuickstart.png" alt="APIQuickstart" title="APIQuickstart" />

You interact with the data produced by the sensors and peripherals through the MBLEvent class.

<img src="http://mbientlab.com/MetaWearEventQuickstart.png" alt="EventQuickstart" title="EventQuickstart" />

### Data Processing Module

The data processing module is separated into several "filters" which can be used standalone or chained together to create more complex filters.

The current filters available are:
- Summation of Events
- Periodic Sample of Events
- Peak Detector (coming soon)
- Low Pass Filter (coming soon)
- Threshold Detector (coming soon)

The generic nature of these filters allow you to give any data stream as input and receive the processed data as output, either directly or through a log entry.

The following quick example shows how to setup this data processing chain to report the summed RMS value of accelerometer data every minute. This is currently used in the MetaTracker App (https://github.com/mbientlab/MetaTracker) to estimate overall activity in a given time interval.

The following diagram describes the overall data gathering, processing, and storing that we want to achieve.

![alt tag](https://github.com/mbientlab/Metawear-iOSAPI/blob/master/DataProcessing.jpeg)

```obj-c
MBLEvent *event = [self.device retrieveEventWithIdentifier:@"com.mbientlab.ActivityTrackerEvent"];
if (!event) {
    // Program to sum accelerometer RMS data and log sample every 60 seconds
    event = [[self.device.accelerometer.rmsDataReadyEvent summationOfEvent] periodicSampleOfEvent:60000 identifier:@"com.mbientlab.ActivityTrackerEvent"];
}
if (!event.isLogging) {
    self.device.accelerometer.fullScaleRange = MBLAccelerometerRange8G;
    self.device.accelerometer.filterCutoffFreq = 0;
    self.device.accelerometer.highPassFilter = YES;
    [event startLogging];
}
```
