//
//  PreloadedPersistentContainerTests.swift
//  PreloadedPersistentContainerTests
//
//  Created by Ryosuke Iwanaga on 2018-08-14.
//  Copyright © 2018 Ryosuke Iwanaga. All rights reserved.
//

import XCTest
import CoreData
@testable import PreloadedPersistentContainer

class PreloadedPersistentContainerTests: XCTestCase {
    let bundle = Bundle(for: PreloadedPersistentContainerTests.self)
    let testModel = "TestModel"
    
    var container: NSPersistentContainer!
    
    override func setUp() {
        func cleanDefaultSQLite() {
            let fileManager = FileManager.default
            let defaultUrl = NSPersistentContainer.defaultDirectoryURL()
            for ext in ["sqlite", "sqlite-wal", "sqlite-shm"] {
                let url = defaultUrl.appendingPathComponent(testModel).appendingPathExtension(ext)
                if fileManager.fileExists(atPath: url.path) {
                    try! fileManager.removeItem(at: url)
                }
            }
        }
        
        // Since .xctest bundle can't be accessd by `Bundle.main`, we have to declare mom explicitly
        // You don't have to do this in your iOS App
        func containerForTestModel() -> NSPersistentContainer {
            let momUrl = bundle.url(forResource: testModel, withExtension: "momd")!
            let mom = NSManagedObjectModel(contentsOf: momUrl)!
            return NSPersistentContainer(name: testModel, managedObjectModel: mom)
        }

        func loadPersistentStoresWithPreload(
            completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void)
        {
            #if os(iOS)
            // Since .xctest bundle can't be accessd by `Bundle.main`, we have to specify mainBundle explicitly
            // This is only for iOS testing
            container._loadPersistentStoresWithPreload(mainBundle: bundle, completionHandler: block)
            #else
            // For macOS, it always requires `BUILT_PRODUCTS_DIR` and `CONTENTS_FOLDER_PATH` environment variable
            // to identify bundle location, which are pretended at scheme
            container.loadPersistentStoresWithPreload(completionHandler: block)
            #endif
        }
        
        super.setUp()
        cleanDefaultSQLite()
        container = containerForTestModel()
        loadPersistentStoresWithPreload { (storeDescription, error) in
            if let error = error {
                XCTFail("Failed to load store: \(error)")
            }
        }
        #if os(OSX)
        // To test macOS functionality alone, we need preload here
        // For iOS, it is done by build phase of tests with TestPreloader CLI
        TestPreload(container.viewContext).preload()
        #endif
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPreloadedEntity() {
        do {
            let request: NSFetchRequest<TestEntity> = TestEntity.fetchRequest()
            let results = try container.viewContext.fetch(request)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first!.id, 1)
        } catch {
            XCTFail("Failed to load entity: \(error)")
        }
    }
}
