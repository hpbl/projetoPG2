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
    
    
    //MARK: - Geometry
    func getBarycentricCoord(triangle: Triangle) -> Point{
        
        let xA = triangle.firstVertex.x
        let xB = triangle.secondVertex.x
        let xC = triangle.thirdVertex.x
        
        let yA = triangle.firstVertex.y
        let yB = triangle.secondVertex.y
        let yC = triangle.thirdVertex.y
        
        let den = (yB - yC)*(self.x - xC) + (xC - xB)*(yA - yC)
        
        //TODO: mudar isso aqui..
        var point = Point(x: 0, y: 0, z: 0)
        
        if (den != 0) {
            point.x = ((yB - yC)*(self.x - xC) + (xC - xB)*(self.y - yC)) / den
            point.y = ((yC - yA)*(self.x - xC) + (xA - xC)*(self.y - yC)) / den
            point.z = 1 - point.x - point.y
        }
        
        return point
    }
    
    //usar as coordenadas baricentricas para achar o 3D
    func convertTo3DCoord(alfaBetaGama: Point) -> Point{
        
        let alfa = alfaBetaGama.x
        let beta = alfaBetaGama.y
        let gama = alfaBetaGama.z
        
        //TODO: shouldn't it be: alfa*vertice_1_3D + beta*vertice_2_3D + gama*vertice_3_3D
        return self*alfa + self*beta + self*gama!
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
