# macOS Wi-Fi Scanner

A simple command-line Wi-Fi scanner for macOS that retrieves SSID, BSSID, and signal strength (RSSI).

## Why This Exists

Modern macOS versions have strict privacy requirements for accessing Wi-Fi information (SSIDs and BSSIDs). To see these, an application must:
1.  **Be bundled** with an `Info.plist` that includes a location usage description.
2.  **Request and receive Location Services permission**.
3.  **Be signed** (even with an ad-hoc signature).

This project handles these requirements by embedding the `Info.plist` into the binary and creating a minimal `.app` structure.

## Requirements

- macOS
- Xcode Command Line Tools (`clang++`)

## Building and Running

To build the application:

```bash
make build
```

To run the application:

```bash
make run
```

> **Note:** The application must be run via `make run` (or directly from within the bundle at `./WifiScanner.app/Contents/MacOS/WifiScanner`) so that macOS can correctly associate it with its permissions.

## Permissions

The first time you run it, you may see a prompt asking for Location Services permission. You must grant this to see the SSID names; otherwise, they will appear as `<Hidden>`.
