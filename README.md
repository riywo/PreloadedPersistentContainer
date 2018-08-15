# PreloadedPersistentContainer
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/riywo/PreloadedPersistentContainer/master/LICENSE.txt)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A Framework to extend `NSPersistentContainer` with preloaded SQLite data. This supports both macOS for build phase and iOS for runtime.

## Use cases

- Preload multple records at build phase, then provide search experience to customers

## Install

Using `Carthage`:

```sh
$ cat Cartfile
github "riywo/PreloadedPersistentContainer"

$ carthage update
*** Fetching PreloadedPersistentContainer
*** Checking out PreloadedPersistentContainer at "v0.1.0"
*** xcodebuild output can be found in /var/folders/29/mmyrpb0d5g39glgdcv9x4z780000gn/T/carthage-xcodebuild.PBBnLr.log
*** Building scheme "PreloadedPersistentContainer iOS" in PreloadedPersistentContainer.xcodeproj
*** Building scheme "PreloadedPersistentContainer macOS" in PreloadedPersistentContainer.xcodeproj
```

Now, you can use Framework:

```
./Carthage/Build
├── Mac
│   ├── PreloadedPersistentContainer.framework
│   └── PreloadedPersistentContainer.framework.dSYM
└── iOS
    ├── PreloadedPersistentContainer.framework
    └── PreloadedPersistentContainer.framework.dSYM
```

## Usage

### 1. Create a macOS CLI target.

File -> New -> Target -> macOS Command Line Tool

### 2. Associate each Framework to iOS App and macOS CLI.

Add to Linked Frameworks and Libraries

### 3. Add macOS CLI to target memberships of your Core Data model, related classes, etc.

Open file -> Show the File inspector (right pane) -> Check macOS CLI in Target Membership

### 4. Edit scheme of iOS App to add macOS CLI into its build targets before iOS App. Uncheck Parallelize Build.

Product -> Scheme -> Manage Schemes -> Edit Your iOS scheme -> Build -> Add macOS CLI -> Move it before iOS App -> Uncheck Parallelize Build

### 5. Add run script phase to iOS App build phases.

Open Buid Phases of your iOS App target -> Add Run script -> Move it after Compile Sources -> Paste command below

```sh
${BUILT_PRODUCTS_DIR}/../${CONFIGURATION}/YourMacOSCLI
```

### 6. Write preload functions in macOS CLI.

If this CLI runs on build phase of iOS App, it preloads SQLite files in you iOS App main bundle (`Your.app/YourModel.sqlite*`).

```swift
import CoreData
import PreloadedPersistentContainer

let container = NSPersistentContainer(name: "YourModel")
container.loadPersistentStoresWithPreload { (storeDescription, error) in
    if let error = error {
        fatalError("Failed to load store: \(error)")
    }
}

let entity = YourEntity(context: container.viewContext)
entity.id = 1
try! container.viewContext.save()
```

### 7. Use `loadPersistentStoresWithPreload()` in your iOS App.

Maybe in AppDelegate.swift, replace `loadPersistentStores()` with `loadPersistentStoresWithPreload()`.

Then, the bundled SQLite files (`Your.app/YourModel.sqlite*`) will be automatically read.

```swift
import CoreData
import PreloadedPersistentContainer

lazy var persistentContainer: NSPersistentContainer = {
    let modelName = "YourModel"
    let container = NSPersistentContainer(name: modelName)
    container.loadPersistentStoresWithPreload(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()
```

### 8. Build iOS App.

Have fun!

## References

- [Creating Swift frameworks for iOS, OS X and tvOS with Unit Tests and Distributing via CocoaPods and Swift Package Manager](https://www.enekoalonso.com/articles/creating-swift-frameworks-for-ios-osx-and-tvos)
- [Core Data: How to Preload Data and Use Existing SQLite Database](https://appcoda.com/core-data-preload-sqlite-database/)
- [Core Data: Automate master data preloading \- The Cookbook](https://tundrax.github.io/blog/2013/05/06/core-data-automate-master-data-preloading/)



