//
//  triangle.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

class Triangle {
    var firstVertex: Point
    var secondVertex: Point
    var thirdVertex: Point
    var edges: [(Double, Double)]?
    
    func normal() -> Point {
        return crossProduct(u: (self.thirdVertex - self.firstVertex),
                            v: (self.thirdVertex - self.secondVertex))
    }
    
    init(firstVertex: Point, secondVertex: Point, thirdVertex: Point) {
        self.firstVertex = firstVertex
        self.secondVertex = secondVertex
        self.thirdVertex = thirdVertex
        self.edges = findEdges()
    }
    
    func findEdges() -> [(Double, Double)] {
        var edgesArray = [(Double, Double)]()
        
        edgesArray.append(lineEquation(pointA: self.firstVertex, pointB: self.secondVertex))
        edgesArray.append(lineEquation(pointA: self.firstVertex, pointB: self.thirdVertex))
        edgesArray.append(lineEquation(pointA: self.secondVertex, pointB: self.thirdVertex))

        return edgesArray
    }
    

}

