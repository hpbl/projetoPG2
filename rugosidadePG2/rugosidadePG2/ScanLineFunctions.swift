//
//  ScanLineFunctions.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 13/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

func getPointsInside(currentY: Double, currentX: Double, Xmax: Double, a1: Double) -> [Point] {
    var pointsInside = [Point]()
    var currX = currentX
    while currX <= Xmax {
        pointsInside.append(Point(x: round(currX), y: round(currentY)))
        currX = currX + 1
    }
    return pointsInside
}

func flatTopPoints(triangle: Triangle, sortedPoints: [Point]) -> [Point] {
    //triangulo é flat-top
    var trianglePixels = [Point]()
    let maxYPoints = [sortedPoints[0], sortedPoints[1]]
    
    //pegando a e b das equações
    let lineEquation1 = triangle.edges?[PointTuple(pointA: maxYPoints[0],
                                                   pointB: sortedPoints[2])]
    
    let a1 = lineEquation1?.0
    let b1 = lineEquation1?.1
    
    
    let lineEquation2 = triangle.edges?[PointTuple(pointA: maxYPoints[1],
                                                   pointB: sortedPoints[2])]
    
    let a2 = lineEquation2?.0
    
    //tratando o flat-top
    var Xmin = maxYPoints[0].x
    var Xmax = maxYPoints[1].x
    var currentY = maxYPoints[0].y
    let Ymin = sortedPoints[2].y
    
    
    while currentY >= Ymin {
        trianglePixels.append(contentsOf: getPointsInside(currentY: currentY, currentX: Xmin, Xmax: Xmax, a1: a1!))
        
        //decrementando o currentY
        Xmin = Xmin - 1/a1!
        Xmax = Xmax - 1/a2!
        
        if Xmin == Xmax {
            currentY = Ymin
        } else {
            currentY = currentY - 1
        }
    }
    return trianglePixels
}

func flatBottomPoints(triangle: Triangle, sortedPoints: [Point]) -> [Point] {
    var trianglePixels = [Point]()
    let minYPoints = [sortedPoints[1], sortedPoints[2]]
    
    //pegando a e b das equações
    let lineEquation1 = triangle.edges?[PointTuple(pointA: minYPoints[0],
                                                   pointB: sortedPoints[0])]
    
    let a1 = lineEquation1?.0
    let b1 = lineEquation1?.1
    
    
    let lineEquation2 = triangle.edges?[PointTuple(pointA: minYPoints[1],
                                                   pointB: sortedPoints[0])]
    
    let a2 = lineEquation2?.0
    
    //tratando o flat-bottom
    var Xmin = sortedPoints[0].x
    var Xmax = sortedPoints[0].x
    var currentY = sortedPoints[0].y
    let Ymin = sortedPoints[2].y
    
    
    while currentY >= Ymin {
        trianglePixels.append(contentsOf: getPointsInside(currentY: currentY, currentX: Xmin, Xmax: Xmax, a1: a1!))
        
        //decrementando o currentY
        Xmin = Xmin - 1/a1!
        Xmax = Xmax - 1/a2!
        currentY = currentY - 1
        
    }
    return trianglePixels
    
}

func getPixels(from triangle: Triangle) -> [Point] {
    let controlPoints = [triangle.firstVertex, triangle.secondVertex, triangle.thirdVertex]
    
    var sortedPoints = controlPoints.sorted {(pointA, pointB) -> Bool in
        return (pointA.y == pointB.y) ? (pointA.x < pointB.x) : (pointA.y > pointB.y)
    }
    
    if (sortedPoints.filter{$0.y == sortedPoints[0].y}).count > 1 {
        //triangulo é flat-top
        return flatTopPoints(triangle: triangle, sortedPoints: sortedPoints)
        
        
    } else if (sortedPoints.filter{$0.y == sortedPoints[2].y}).count > 1 {
        //triangulo é flat-bottom
        return flatBottomPoints(triangle: triangle, sortedPoints: sortedPoints)
        
        
    } else {
        //triangulo normal
        var trianglePixels = [Point]()
        
        
        //achando ponto com y médio
        let midPoint = sortedPoints[1]
        
        //cálculando x do novo vértice
        let newVertexX = round(sortedPoints[0].x +
            (((midPoint.y - sortedPoints[0].y) * (sortedPoints[2].x - sortedPoints[0].x)) / (sortedPoints[2].y - sortedPoints[0].y)))
        
        //criando novo vértice
        let newVertex = Point(x: newVertexX, y: midPoint.y)
        
        //calculando pixels dentro do prieiro triangulo (flat-bottom)
        let flatBottomPart = Triangle(firstVertex: sortedPoints[0], secondVertex: midPoint, thirdVertex: newVertex)
        let controlPointsFB = [flatBottomPart.firstVertex, flatBottomPart.secondVertex, flatBottomPart.thirdVertex]
        let sortedPointsFB = controlPointsFB.sorted {(pointA, pointB) -> Bool in
            return (pointA.y == pointB.y) ? (pointA.x < pointB.x) : (pointA.y > pointB.y)
        }
        trianglePixels = flatBottomPoints(triangle: flatBottomPart, sortedPoints: sortedPointsFB)
        
        //calculando pixels dentro do segundo triangulo (flat-top)
        let flatTopPart = Triangle(firstVertex: midPoint, secondVertex: newVertex, thirdVertex: sortedPoints[2])
        let controlPointsFT = [flatTopPart.firstVertex, flatTopPart.secondVertex, flatTopPart.thirdVertex]
        let sortedPointsFT = controlPointsFT.sorted {(pointA, pointB) -> Bool in
            return (pointA.y == pointB.y) ? (pointA.x < pointB.x) : (pointA.y > pointB.y)
        }
        trianglePixels.append(contentsOf: flatTopPoints(triangle: flatTopPart, sortedPoints: sortedPointsFT))
        
        //removendo pontos duplicados
        return Array(Set(trianglePixels))
    }
    
}
