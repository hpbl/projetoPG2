//
//  Camera.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 09/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

class Camera {
    var position: Point
    var vectorN: Point
    var vectorV: Point
    var d: Int
    var hx: Double
    var hy: Double
    
    
    // MARK: - inits
    init(position: Point, vectorN: Point, vectorV: Point, d: Int, hx: Double, hy: Double) {
        self.position = position
        self.vectorN = vectorN
        self.vectorV = vectorV
        self.d = d
        self.hx = hx
        self.hy = hy
    }
    
    init(named: String) {
        let cameraStrings = read(from: named, type: "cfg")
        let lastLine = cameraStrings?[3].components(separatedBy: " ")
        
        self.position = (cameraStrings?[0].toPoint())!
        self.vectorN = (cameraStrings?[1].toPoint())!
        self.vectorV = (cameraStrings?[2].toPoint())!
        
        self.d = Int(lastLine![0])!
        self.hx = Double(lastLine![1])!
        self.hy = Double(lastLine![2])!
    }
}
