//
//  TestPreload.swift
//  PreloadedPersistentContainer
//
//  Created by Ryosuke Iwanaga on 2018-08-14.
//  Copyright © 2018 Ryosuke Iwanaga. All rights reserved.
//

import Foundation
import CoreData

class TestPreload {
    let context: NSManagedObjectContext
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    func preload() {
        let entity = TestEntity(context: context)
        entity.id = 1
        try! context.save()
    }
}
