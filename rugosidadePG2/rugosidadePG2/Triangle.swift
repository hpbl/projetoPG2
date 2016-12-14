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
    var edges: [PointTuple: (Double, Double)]?
    var pixels = [Point]()
    
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
    
    func findEdges() -> [PointTuple: (Double, Double)] {
        var edgesDict = [PointTuple: (Double, Double)]()
        
        edgesDict[PointTuple(pointA: self.firstVertex,
                             pointB: self.secondVertex)] = lineEquation(pointA: self.firstVertex,
                                                                        pointB: self.secondVertex)
        
        edgesDict[PointTuple(pointA: self.firstVertex,
                             pointB: self.thirdVertex)] = lineEquation(pointA: self.firstVertex,
                                                                       pointB: self.thirdVertex)
        
        edgesDict[PointTuple(pointA: self.secondVertex,
                             pointB: self.thirdVertex)] = lineEquation(pointA: self.secondVertex,
                                                                       pointB: self.thirdVertex)

        return edgesDict
    }
}


extension Triangle: Equatable {
    
    public static func ==(lhs: Triangle, rhs: Triangle) -> Bool {
        return lhs.firstVertex == rhs.firstVertex && lhs.secondVertex == rhs.secondVertex && lhs.thirdVertex == rhs.thirdVertex
    }


}
