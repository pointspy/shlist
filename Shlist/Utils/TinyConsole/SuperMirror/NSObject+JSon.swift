//
//  NSObject+JSon.swift
//  TinyConsole-Example
//
//  Created by Лысков Павел on 12.03.2020.
//

import Foundation
import ObjectiveC.runtime

public extension NSObject {
    class func fromJson(jsonInfo: NSDictionary) -> Self {
        let object = self.init()

        (object as NSObject).load(jsonInfo: jsonInfo)

        return object
    }

    func load(jsonInfo: NSDictionary) {
        for (key, value) in jsonInfo {
            if let keyName = key as? String {
                if responds(to: NSSelectorFromString(keyName)) {
                    setValue(value, forKey: keyName)
                }
            }
        }
    }

    func propertyNames() -> [String] {
        var names: [String] = []
        var counts = UInt32()
        let properties = class_copyPropertyList(object_getClass(self), &counts)
        for i in 0 ..< counts {
            let property = properties?.advanced(by: Int(i)).pointee

            let cName = property_getName(property!)
            let name = String(cString: cName)

            names.append(name)
        }
        return names
    }

    func asJSON() throws -> Any? {
        var json: [String: Any] = [:]

        let names = propertyNames()
        print(names)
        for name in names {
            if let value = value(forKey: name) {
                if let val = value as? JSONSerializable {
                    json[name] = try val.toJSON()

                } else {
                    json[name] = "\(value)"
                }
            }
        }
        print(json)
        return json
    }
}

public func getKeysAndTypes(forObject: Any?) -> [String: Any] {
    var answer: [String: String] = [:]
    var counts = UInt32()
    let properties = class_copyPropertyList(object_getClass(forObject), &counts)
    for i in 0 ..< counts {
        let property = properties?.advanced(by: Int(i)).pointee

        let cName = property_getName(property!)
        let name = String(cString: cName)

        let cAttr = property_getAttributes(property!)!
        let attr = String(cString: cAttr).components(separatedBy: ",")[0].replacingOccurrences(of: "T", with: "")
        answer[name] = attr
        // print("ID: \(property.unsafelyUnwrapped.debugDescription): Name \(name), Attr: \(attr)")
    }
    return answer
}



extension Array where Element == NSObject {
    public func toJSON() throws -> Any? {
//        return try asJSON()
        var result = "{\n \"result\": [\n"

        enumerated().forEach { index, element in

            do {
                let json = try element.asJSON()
                if let dict = json as? [String: Any] {
                    let jsonStr = dict.json
                    if index < self.count - 1 {
                        result = result + jsonStr + ",\n"
                    } else {
                        result = result + jsonStr + "\n"
                    }
                }
            } catch {}
        }

        result = result + "]\n}"

        return result
    }
}
