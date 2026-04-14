#import <CoreLocation/CoreLocation.h>
#import <CoreWLAN/CoreWLAN.h>
#include <iomanip>
#include <iostream>

using namespace std;

int main() {
  @autoreleasepool {
    // 1. Request Location Authorization (Required for SSID access on macOS)
    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    [locManager requestWhenInUseAuthorization];
    
    // Give the system a moment to process the authorization request
    [NSThread sleepForTimeInterval:1.0];
    
    int timeout = 0;
    CLAuthorizationStatus status = [locManager authorizationStatus];
    while (status == kCLAuthorizationStatusNotDetermined && timeout < 5) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        status = [locManager authorizationStatus];
        timeout++;
    }

    // On macOS, status 3 (kCLAuthorizationStatusAuthorizedAlways) is common for authorized apps
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        cerr << "Error: Location Services permission denied. SSIDs will be hidden." << endl;
        cerr << "Please enable Location Services for this app or Terminal in System Settings." << endl;
    }

    // 2. Initialize Wi-Fi Client
    CWWiFiClient *client = [CWWiFiClient sharedWiFiClient];
    CWInterface *interface = [client interface];

    if (!interface) {
        cerr << "Error: No Wi-Fi interface found." << endl;
        return 1;
    }

    cout << "Scanning for Wi-Fi networks on " << [[interface interfaceName] UTF8String] << "..." << endl;
    cout << left << setw(30) << "SSID" << setw(20) << "BSSID" << "Signal strength" << endl;
    cout << string(70, '-') << endl;

    // 3. Scan for Networks
    NSError *error = nil;
    NSSet<CWNetwork *> *networks = [interface scanForNetworksWithSSID:nil error:&error];

    if (error) {
        cerr << "Error scanning: " << [[error localizedDescription] UTF8String] << endl;
        return 1;
    }

    // 4. Display Results
    for (CWNetwork *network in networks) {
        NSString *ssidName = [network ssid];
        // Fallback for some macOS versions where ssidData is more reliable
        //if (!ssidName && [network ssidData]) {
        //    ssidName = [[NSString alloc] initWithData:[network ssidData] encoding:NSUTF8StringEncoding];
        //}
        
        string ssid = [ssidName UTF8String] ?: "<Hidden>";
        string bssid = [[network bssid] UTF8String] ?: "<Unknown>";
        long rssi = [network rssiValue];

        cout << left << setw(30) << ssid << setw(20) << bssid << rssi << " dBm ";

        if (rssi > -50) cout << "[Excellent]";
        else if (rssi > -70) cout << "[Good]";
        else if (rssi > -80) cout << "[Fair]";
        else cout << "[Weak]";

        cout << endl;
    }
  }
  return 0;
}
