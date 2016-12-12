//
//  Point.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

// Manter como struct, para perder referência quando valor mudar
struct Point: Hashable{
    var x: Double
    var y: Double
    var z: Double?
    
    // MARK: Hashable
    var hashValue: Int {
        get {
            return "\(self.x)\(self.y)\(self.z)".hashValue
        }
    }
    
    var hashValueString: String {
        get {
            return "\(self.x)\(self.y)\(self.z)"
        }
    }
    
    //MARK: - inits
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    
    //MARK: - Vector Basic Operations
    static func * (vector: Point, scalar: Double) -> Point {
        return Point(x: scalar*(vector.x), y: scalar*(vector.y), z: scalar*(vector.z)!)
    }
    
    static func - (u: Point, v: Point) -> Point {
        return Point(x: u.x - v.x , y: u.y - v.y , z: u.z! - v.z!)
    }
    
    static func + (u: Point, v: Point) -> Point {
        return Point(x: u.x + v.x , y: u.y + v.y , z: u.z! + v.z!)
    }
    
    func normalized() -> Point {
        let norm = sqrt((self.x * self.x) + (self.y * self.y) + (self.z! * self.z!))
        
        return Point(x: self.x/norm, y: self.y/norm, z: self.z!/norm)
    }
    
    //MARK: - Equatable protocol
    static func ==(lhs: Point, rhs: Point) -> Bool {
        
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }

}
