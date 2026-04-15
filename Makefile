# Compiler and flags
CXX = clang++
CXXFLAGS = -O3 -framework CoreWLAN -framework CoreLocation -framework Foundation
INFO_PLIST = Info.plist
APP_BUNDLE = WifiScanner.app
APP_BINARY = $(APP_BUNDLE)/Contents/MacOS/WifiScanner

# Default target
all: build

# Build the application
build: main.mm $(INFO_PLIST)
	@echo "Building WifiScanner..."
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	$(CXX) $(CXXFLAGS) -sectcreate __TEXT __info_plist $(INFO_PLIST) main.mm -o $(APP_BINARY)
	cp $(INFO_PLIST) $(APP_BUNDLE)/Contents/Info.plist
	codesign -f -s - $(APP_BINARY)
	@echo "Build complete. Run with 'make run'"

# Run the application (must run from within the bundle for location permissions)
run:
	@echo "Running WifiScanner from bundle..."
	./$(APP_BINARY)

# Clean build artifacts
clean:
	rm -rf WifiScanner WifiScanner_unsigned Info.plist.o $(APP_BUNDLE)
	@echo "Cleaned build artifacts."

.PHONY: all build run clean
