//
//  Object.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

class Object {
    var points: [Point]
    var triangles: [Triangle] { return self.getTriangles(from: self.trianglesVerticesList!)}

    private var trianglesVerticesList: [String]?
    
    
    // MARK: - inits
    init(named: String) {
        let objectStrings = Object.read(from: named, type: "byu")
        let objectSpecs = objectStrings?[0].components(separatedBy: " ")
        
        let numberOfPoints = Int(objectSpecs![0])!
        
        self.points = Object.getPoints(from: Array(objectStrings![1...numberOfPoints]))
        self.trianglesVerticesList = Array(objectStrings![numberOfPoints+1..<(objectStrings!.count)])
    }
    
    
    // MARK: - instance methods
    func getTriangles(from array: [String]) -> [Triangle] {
        let objectTrianglesArray = array.map{$0.components(separatedBy: " ")}
        
        return objectTrianglesArray.map{Triangle(firstVertex: self.points[Int($0[0])!-1], secondVertex: self.points[Int($0[1])!-1], thirdVertex: self.points[Int($0[2])!-1])}
    }
    
    
    // MARK: - class methods
    class func getPoints(from array: [String]) -> [Point] {
        let objectPointsArray = array.map{$0.components(separatedBy: " ")}
        return objectPointsArray.map{Point(x: Float($0[0])!, y: Float($0[1])!, z: Float($0[2])!)}
    }
    
    class func read(from file: String, type: String) -> [String]? {
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
}
