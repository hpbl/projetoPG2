//
//  ScanLineFunctions.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 13/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

func areCollinear(_ pointA: Point, _ pointB: Point, _ pointC: Point) -> Bool {
    if [pointA, pointB, pointC].reduce(true, { (result, point) -> Bool in
        return result && point.x == pointA.x
    }) {
       return true
    }
    
    else if [pointA, pointB, pointC].reduce(true, { (result, point) -> Bool in
        return result && point.y == pointA.y
    }) {
        return true
    }
    
    return false
}

func isLine(_ triangle: Triangle) -> Bool {
    let pointA = triangle.firstVertex
    let pointB = triangle.secondVertex
    let pointC = triangle.thirdVertex
    
    
    return areCollinear(pointA, pointB, pointC)
}
