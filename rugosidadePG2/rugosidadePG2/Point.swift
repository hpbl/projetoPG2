//
//  Point.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

// Manter como struct, para perder referência quando valor mudar
struct Point {
    var x: Double
    var y: Double
    var z: Double?
    var color: (Double, Double, Double)?
    
    //MARK: - inits
    init() {
        self.x = Double.infinity
        self.y = Double.infinity
    }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(x: Double, y: Double, z: Double, color: (Double, Double, Double)) {
        self.x = x
        self.y = y
        self.z = z
        self.color = color
    }
    
    
    //MARK: - Vector Basic Operations
    static func * (vector: Point, scalar: Double) -> Point {
        guard let z = vector.z else {
            return Point(x: scalar*(vector.x), y: scalar*(vector.y))
        }
        
        return Point(x: scalar * (vector.x), y: scalar * (vector.y), z: scalar * z)
    }
    
    static func - (u: Point, v: Point) -> Point {
        if u.z != nil && v.z != nil {
            return Point(x: u.x - v.x , y: u.y - v.y , z: u.z! - v.z!)
        } else {
            return Point(x: u.x - v.x, y: u.y - v.y)
        }
    }
    
    static func + (u: Point, v: Point) -> Point {
        if u.z != nil && v.z != nil {
            return Point(x: u.x + v.x , y: u.y + v.y , z: u.z! + v.z!)

        } else {
            return Point(x: u.x + v.x , y: u.y + v.y)
        }
    }
    
    func normalized() -> Point {
        guard let z = self.z else {
            
            let norm = sqrt((self.x * self.x) + (self.y * self.y))

            return Point(x: self.x/norm, y: self.y/norm)
        }
        
        let norm = sqrt((self.x * self.x) + (self.y * self.y) + (z * z))
        
        return Point(x: self.x/norm, y: self.y/norm, z: self.z!/norm)
    }
    
    
    //MARK: - Geometry
    func getBarycentricCoords(triangle: Triangle) -> Point {
        let v0 = triangle.secondVertex - triangle.firstVertex
        let v1 = triangle.thirdVertex - triangle.firstVertex
        let v2 = self - triangle.firstVertex
        
        let d00 = innerProduct(u: v0, v: v0)
        let d01 = innerProduct(u: v0, v: v1)
        let d11 = innerProduct(u: v1, v: v1)
        let d20 = innerProduct(u: v2, v: v0)
        let d21 = innerProduct(u: v2, v: v1)
        
        let denom = (d00 * d11) - (d01 * d01)
        
        var point = Point()
        
        point.y = ((d11 * d20) - (d01 * d21)) / denom
        point.z = ((d00 * d21) - (d01 * d20)) / denom
        point.x = 1 - point.y - point.z!

        return point
        
    }
    
    //usar as coordenadas baricentricas para achar o 3D
    func approx3DCoordinates(alfaBetaGama: Point, triangle3D: Triangle) -> Point{
        
        let alfa = alfaBetaGama.x
        let beta = alfaBetaGama.y
        let gama = alfaBetaGama.z
        
        return triangle3D.firstVertex*alfa + triangle3D.secondVertex*beta + triangle3D.thirdVertex*gama!
    }
    
}

//MARK: - Protocols
//MARK: Equatable
extension Point: Equatable {
    static func ==(lhs: Point, rhs: Point) -> Bool {
        
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}

// MARK: Hashable
extension Point: Hashable {
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
}
