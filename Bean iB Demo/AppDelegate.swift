import UIKit
import CoreLocation

protocol BeaconInfoDelegate {
    func foundBeacons(_ num: Int)
    func enteredRegion()
    func exitedRegion()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    // MARK: - Local variables

    var window: UIWindow?

    // CLLocationManager is really, really tricky to use properly. Check out the Apple docs for guidance:
    // https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html
    var locationManager: CLLocationManager?
    
    var delegate: BeaconInfoDelegate?
    
    var authStatusStrings = [
        CLAuthorizationStatus.notDetermined: "Not determined",
        CLAuthorizationStatus.restricted: "Restricted",
        CLAuthorizationStatus.denied: "Denied",
        CLAuthorizationStatus.authorizedAlways: "Authorized always",
        CLAuthorizationStatus.authorizedWhenInUse: "Authorized when in use",
    ]
    
    // MARK: - AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupLocationManager()
        checkAuthorization()
        subscribeToBeacons()
        return true
    }
    
    // MARK: - Set up beacon monitoring
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager!.delegate = self
    }
    
    func checkAuthorization() {
        print("Location services enabled: \(CLLocationManager.locationServicesEnabled())")
        
        // Requesting authorization silently fails if you don't have NSLocationAlwaysUsageDescription in your info.plist.
        locationManager!.requestAlwaysAuthorization()
    }
    
    func subscribeToBeacons() {
        print("Device supports Bluetooth beacon ranging: \(CLLocationManager.isRangingAvailable())")
        
        let uuid = UUID.init(uuidString: "A495DEAD-C5B1-4B44-B512-1370F02D74DE")
        let major: CLBeaconMajorValue = 0xBEEF
        let minor: CLBeaconMinorValue = 0xCAFE
        
        let region = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "Bean iBeacon")
        
        locationManager!.startMonitoring(for: region)
        locationManager!.startRangingBeacons(in: region)
        
        let majorHex = String(format: "%X", major)
        let minorHex = String(format: "%X", minor)
        print("Scanning for iBeacons with UUID: \(uuid!.uuidString), major: \(majorHex), minor: \(minorHex)")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // MARK: Incoming data
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location auth status changed: \(authStatusStrings[status]!)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region: \(region.identifier)")
        delegate?.enteredRegion()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier)")
        delegate?.exitedRegion()
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if (beacons.count > 0) {
            print("Found \(beacons.count) iBeacon(s) in region: \(region.identifier)")
            for beacon in beacons {
                print("    RSSI: \(beacon.rssi)")
            }
        }
        delegate?.foundBeacons(beacons.count)
    }
    
    // MARK: Handling errors
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region: \(region?.identifier), error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Ranging beacons failed for region: \(region.identifier), error: \(error)")        
    }

}

