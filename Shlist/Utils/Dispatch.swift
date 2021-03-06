//
//  Dispatch.swift
//  Shlist
//
//  Created by Pavel Lyskov on 21.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//
import Foundation

public class DispatchT {
    open class func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    open class func background(_ block: @escaping () -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            block()
        }
    }
    
    open class func foreground(_ block: @escaping () -> ()) {
        DispatchQueue.main.async { () -> () in
            block()
        }
    }
}
