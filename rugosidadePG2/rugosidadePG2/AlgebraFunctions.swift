//
//  AuxiliarFunctions.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 09/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation


//MARK: - Algebra
func tan(pointA: Point, pointB: Point) -> Double {
    return (pointA.y - pointB.y) / (pointA.x - pointB.x)
}

func lineEquation(pointA: Point, pointB: Point) -> (Double, Double) {
    let a = tan(pointA: pointA, pointB: pointB)
    
    let b = pointA.y - (a * pointA.x)
    
    return (a, b)
}
// 3x3 Matrix multiplied by 3x1 vector 😱
func * (matrix: [[Double]], vector: Point) -> Point {
    let x = matrix[0][0] * vector.x + matrix[0][1] * vector.y + matrix[0][2] * vector.z!
    let y = matrix[1][0] * vector.x + matrix[1][1] * vector.y + matrix[1][2] * vector.z!
    let z = matrix[2][0] * vector.x + matrix[2][1] * vector.y + matrix[2][2] * vector.z!
    
    return Point(x: x, y: y, z: z)
}




//MARK: - Vector geometry
func innerProduct(u: Point, v: Point) -> Double {
    if u.z != nil && v.z != nil {
        return (u.x * v.x) + (u.y * v.y) + (u.z! * v.z!)
    } else {
        return (u.x * v.x) + (u.y * v.y)
    }
}

func projection(u: Point, v: Point) ->  Point {
    return u * (innerProduct(u: u, v: v) / innerProduct(u: u, v: u))
}

func orthogonalization(n: Point, v: Point) -> Point {
    return  v - projection(u: n, v: v)
}

func crossProduct(u: Point , v: Point) -> Point {
    let x = (u.y * v.z!) - (v.z! * v.y)
    let y = (u.z! * v.x) - (u.x * v.z!)
    let z = (u.x * v.y) - (u.y * v.x)
    
    return Point(x: x, y: y, z: z)
}
