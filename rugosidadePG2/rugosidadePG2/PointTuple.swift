//
//  PointTuple.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 11/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

struct PointTuple {
    var pointA: Point
    var pointB: Point
}

extension PointTuple: Hashable {
    var hashValue: Int {
        get {
            return pointA.hashValue < pointB.hashValue ? (pointA.hashValueString + pointB.hashValueString).hashValue : (pointB.hashValueString + pointA.hashValueString).hashValue
        }
    }
    
    static func ==(lhs: PointTuple, rhs: PointTuple) -> Bool {
        return lhs.pointA == rhs.pointA && lhs.pointB == rhs.pointB ||
               lhs.pointA == rhs.pointB && lhs.pointB == rhs.pointA
    }
}
