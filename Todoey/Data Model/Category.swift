//
//  Category.swift
//  Todoey
//
//  Created by Leonor Resende on 23/07/2019.
//  Copyright © 2019 Leonor Resende. All rights reserved.
//

import Foundation
import RealmSwift
class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
