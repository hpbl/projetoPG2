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
            return "\(self.pointA.x)\(self.pointA.y)\(self.pointA.z)\(self.pointB.x)\(self.pointB.y)\(self.pointB.z)".hashValue
        }
    }
    
    static func ==(lhs: PointTuple, rhs: PointTuple) -> Bool {
        return lhs.pointA == rhs.pointA && lhs.pointB == rhs.pointB ||
               lhs.pointA == rhs.pointB && lhs.pointB == rhs.pointA
    }
}
