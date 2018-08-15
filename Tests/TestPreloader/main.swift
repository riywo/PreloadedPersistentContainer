//
//  main.swift
//  TestPreloader
//
//  Created by Ryosuke Iwanaga on 2018-08-15.
//  Copyright © 2018 Ryosuke Iwanaga. All rights reserved.
//

import Foundation
import CoreData
import PreloadedPersistentContainer

/*
 An example implementation of preloading CLI. The steps to integrate with your iOS App are like below:
 
 1. Add a new target for macOS Command Line Tool.
 2. Build Frameworks for both iOS and OSX (using Carthege is easier).
 3. Associate each Framework to iOS App and macOS CLI.
 4. Add macOS CLI to tatget memberships of your Core Data model, related classes, etc.
 5. Edit scheme of iOS App to add macOS CLI into its build targets before iOS App. Uncheck Parallelize Build.
 6. Add run script phase to iOS App build phases, with a command `${BUILT_PRODUCTS_DIR}/../${CONFIGURATION}/TestPreloader`.
 7. Write preload functions in macOS CLI code using `loadPersistentStoresWithPreload()`.
 8. Use `loadPersistentStoresWithPreload()` in iOS App instead of `loadPersistentStores()`.
 9. Then, build iOS App. Have fun!
 */

let container = NSPersistentContainer(name: "TestModel")
container.loadPersistentStoresWithPreload { (storeDescription, error) in
    if let error = error {
        fatalError("Failed to load store: \(error)")
    }
}
TestPreload(container.viewContext).preload()
