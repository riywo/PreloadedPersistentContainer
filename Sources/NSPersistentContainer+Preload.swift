//
//  NSPersistentContainer+Preload.swift
//  PreloadedPersistentContainer
//
//  Created by Ryosuke Iwanaga on 2018-08-14.
//  Copyright © 2018 Ryosuke Iwanaga. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentContainer {
    /*
     Set preloaded stores automatically, then load them as normal as `loadPersistentStores`.
     
     If this is called by OSX, which means preloading during iOS App build phases, then it cleans and opens
     a new SQLite files in iOS App main bundle.
     
     If this is called by iOS, which means opening preloaded store from real App, then it just opens bundled
     SQLite files.
     
     - Parameters
     - completionHandler: Directly passed to `loadPersistentStores()`
     */
    public func loadPersistentStoresWithPreload(
        completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void)
    {
        _loadPersistentStoresWithPreload(completionHandler: block)
    }
    
    func _loadPersistentStoresWithPreload(
        mainBundle: Bundle? = nil,
        completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void)
    {
        let storeUrl = _baseUrl(mainBundle).appendingPathComponent(name).appendingPathExtension("sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeUrl)
        #if os(iOS)
        storeDescription.setOption(NSNumber(value: true), forKey: NSReadOnlyPersistentStoreOption)
        #endif
        persistentStoreDescriptions = [storeDescription]
        loadPersistentStores(completionHandler: block)
    }
    
    func _baseUrl(_ bundle: Bundle?) -> URL {
        #if os(OSX)
        func deleteTargetSQLite(_ directoryUrl: URL) {
            let fileManager = FileManager.default
            for ext in ["sqlite", "sqlite-wal", "sqlite-shm"] {
                let url = directoryUrl.appendingPathComponent(name).appendingPathExtension(ext)
                if fileManager.fileExists(atPath: url.path) {
                    do {
                        try fileManager.removeItem(at: url)
                    } catch {
                        fatalError("Unable to delete old SQLite files: \(error)")
                    }
                }
            }
        }
        let environment = ProcessInfo.processInfo.environment
        guard let iOSBuildPath = environment["BUILT_PRODUCTS_DIR"], let appPath = environment["CONTENTS_FOLDER_PATH"] else {
            fatalError("Unable to fetch environment variable")
        }
        let url = URL(fileURLWithPath: iOSBuildPath).appendingPathComponent(appPath)
        deleteTargetSQLite(url)
        return url
        #else
        return (bundle ?? Bundle.main).bundleURL
        #endif
    }
}
