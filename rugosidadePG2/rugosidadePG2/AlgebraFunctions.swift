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
    return (u.x * v.x) + (u.y * v.y) + (u.z! * v.z!)
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

//retorna um vetor com alfa, beta e gama
func getBarycentricCoord(currentPoint: Point , triangle: Triangle) -> Point{
    
    let xA = triangle.firstVertex.x
    let xB = triangle.secondVertex.x
    let xC = triangle.thirdVertex.x
    
    let yA = triangle.firstVertex.y
    let yB = triangle.secondVertex.y
    let yC = triangle.thirdVertex.y
    
    let den = (yB - yC)*(currentPoint.x - xC) + (xC - xB)*(yA - yC)
    
    //mudar isso aqui..
    var point = Point(x: 0, y: 0, z: 0)
    
    if (den != 0) {
        point.x = ((yB - yC)*(currentPoint.x - xC) + (xC - xB)*(currentPoint.y - yC)) / den
        point.y = ((yC - yA)*(currentPoint.x - xC) + (xA - xC)*(currentPoint.y - yC)) / den
        point.z = 1 - point.x - point.y
    }
    
    return point
    
}

//usar as coordenadas baricentricas para achar o 3D
func convertTo3DCoord(originalPoint3D: Point , alfaBetaGama: Point) -> Point{
    
    let alfa = alfaBetaGama.x
    let beta = alfaBetaGama.y
    let gama = alfaBetaGama.z
    
    return originalPoint3D*alfa + originalPoint3D*beta + originalPoint3D*gama!
}




//MARK: - 
