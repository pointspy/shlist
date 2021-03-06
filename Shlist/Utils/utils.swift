//
//  utils.swift
//  Shlist
//
//  Created by Pavel Lyskov on 10.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//
import UIKit
import Foundation



@discardableResult
func configure<T>(
    _ value: T,
    using closure: (inout T) throws -> Void
) rethrows -> T {
    var value = value
    try closure(&value)
    return value
}

// MARK: - Sample mark
//class Person: Entity {
//  var name: String!
//  var age:  Int!
//
//  init(name: String, age: Int) {
//    /* /* ... */ */
//    _ = true
//  }
//
//  // Return a descriptive string for this person
//  func description(offset: Int = 0) -> String {
//    let uu = 789
//    return "\(name) is \(age + offset) years old"
//  }
//}

extension Data {

    /// Data into file
    ///
    /// - Parameters:
    ///   - fileName: the Name of the file you want to write
    /// - Returns: Returns the URL where the new file is located in NSURL
    func dataToFile(fileUrl: URL) -> URL? {

        // Make a constant from the data
        let data = self

        // Make the file path (with the filename) where the file will be loacated after it is created
        

        do {
            // Write the file from data into the filepath (if there will be an error, the code jumps to the catch block below)
            try data.write(to: fileUrl)

            // Returns the URL where the new file is located in NSURL
            return fileUrl

        } catch {
            // Prints the localized description of the error from the do block
            print("Error writing the file: \(error.localizedDescription)")
        }

        // Returns nil if there was an error in the do-catch -block
        return nil

    }

}
