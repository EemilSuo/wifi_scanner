#import <CoreLocation/CoreLocation.h>
#import <CoreWLAN/CoreWLAN.h>
#include <iomanip>
#include <iostream>


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
        std::cerr << "Error: Location Services permission denied. SSIDs will be hidden." << std::endl;
        std::cerr << "Please enable Location Services for this app or Terminal in System Settings." << std::endl;
    }

    // 2. Initialize Wi-Fi Client
    CWWiFiClient *client = [CWWiFiClient sharedWiFiClient];
    CWInterface *interface = [client interface];

    if (!interface) {
        std::cerr << "Error: No Wi-Fi interface found." << std::endl;
        return 1;
    }

    std::cout << "Scanning for Wi-Fi networks on " << [[interface interfaceName] UTF8String] << "..." << std::endl;
    std::cout << std::left << std::setw(30) << "SSID" << std::setw(20) << "BSSID" << "Signal strength" << std::endl;
    std::cout << std::string(70, '-') << std::endl;

    // 3. Scan for Networks
    NSError *error = nil;
    NSSet<CWNetwork *> *networks = [interface scanForNetworksWithSSID:nil error:&error];

    if (error) {
        std::cerr << "Error scanning: " << [[error localizedDescription] UTF8String] << std::endl;
        return 1;
    }

// Sort networks by RSSI (strongest first)
  NSArray<CWNetwork *> *sortedNetworks = [[networks allObjects]
      sortedArrayUsingComparator:^NSComparisonResult(CWNetwork *a, CWNetwork *b) {
          return [@([b rssiValue]) compare:@([a rssiValue])];
      }];

  for (CWNetwork *network in sortedNetworks) {
        NSString *ssidName = [network ssid];
       
        std::string ssid = ssidName ? std::string([ssidName UTF8String]) : "<Hidden>";
        std::string bssid = [network bssid] ? std::string([[network bssid] UTF8String]) : "<Unknown>";
        long rssi = [network rssiValue];

        std::cout << std::left << std::setw(30) << ssid << std::setw(20) << bssid << rssi << " dBm ";

        if (rssi > -50) std::cout << "[Excellent]";
        else if (rssi > -70) std::cout << "[Good]";
        else if (rssi > -80) std::cout << "[Fair]";
        else std::cout << "[Weak]";

        std::cout << std::endl;
    }
  }
  return 0;
}
