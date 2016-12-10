//
//  AuxiliarFunctions.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 09/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

func read(from file: String, type: String) -> [String]? {
    if let path = Bundle.main.path(forResource: file, ofType: type) {
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let strings =  data.components(separatedBy: .newlines)
            return strings.filter {$0 != ""}
            
        } catch {
            print(error)
        }
    }
    return nil
}

//MARK: - Vector formulas

func innerProduct(u: Point, v: Point) -> Double {
    return (u.x * v.x) + (u.y * v.y) + (u.z! * v.z!)
}

func vectorByScalar(a: Double , v: Point) -> Point {
    return Point(x: a*(v.x), y: a*(v.y), z: a*(v.z)!)
    
}

func projection(u: Point, v: Point) ->  Point {
    return vectorByScalar(a: innerProduct(u: v, v: u)/innerProduct(u: u, v: u) , v: u)
}

func vectorSubtraction(u: Point, v: Point) -> Point {
    return Point(x: u.x - v.x , y: u.y - v.y , z: u.z! - v.z!)
    
}

func orthogonalization(N: Point, V: Point) -> Point {
    return vectorSubtraction(u: V, v: projection(u: N, v: V))
}

func crossProduct(u: Point , v: Point) -> Point {
    let x = (u.y*v.z!) - (v.z!*v.y)
    let y = (u.z!*v.x) - (u.x*v.z!)
    let z = (u.x*v.y) - (u.y*v.x)
    
    return Point(x: x, y: y, z: z)
}


