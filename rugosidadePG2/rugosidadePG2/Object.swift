//
//  Object.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

class Object {
    var rwPoints: [Point]
    var viewPoints = [Point]()
    var screenPoints = [Point]()
    var pointsNormalsDict = [Point: Point]()
    var triangles3D: [Triangle] { return self.getTriangles(from: self.trianglesVerticesList!,
                                                           of: self.viewPoints)}
    var triangles2D: [Triangle] { return self.getTriangles(from: self.trianglesVerticesList!,
                                                           of: self.screenPoints)}


    private var trianglesVerticesList: [String]?
    
    
    // MARK: - inits
    init(named: String) {
        let objectStrings = read(from: named, type: "byu")
        let objectSpecs = objectStrings?[0].components(separatedBy: " ")
        
        let numberOfPoints = Int(objectSpecs![0])!
        
        self.rwPoints = Object.getPoints(from: Array(objectStrings![1...numberOfPoints]))
        self.trianglesVerticesList = Array(objectStrings![numberOfPoints+1..<(objectStrings!.count)])
    }
    
    
    // MARK: - instance methods
    private func getTriangles(from array: [String], of points:[Point]) -> [Triangle] {
        let objectTrianglesArray = array.map{$0.components(separatedBy: " ")}
        
        return objectTrianglesArray.map{Triangle(firstVertex: points[Int($0[0])!-1],
                                                 secondVertex: points[Int($0[1])!-1],
                                                 thirdVertex: points[Int($0[2])!-1])}
    }
    
    
    // MARK: - class methods
    class func getPoints(from array: [String]) -> [Point] {
        let objectPointsArray = array.map{$0.components(separatedBy: " ")}
        
        return objectPointsArray.map{Point(x: Double($0[0])!,
                                           y: Double($0[1])!,
                                           z: Double($0[2])!)}
    }
    

}
