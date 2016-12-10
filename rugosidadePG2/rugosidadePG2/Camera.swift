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
    var d: Double
    var hx: Double
    var hy: Double
    
    
    //MARK: - inits
    init(named: String) {
        let cameraStrings = read(from: named, type: "cfg")
        let lastLine = cameraStrings?[3].components(separatedBy: " ")
        
        self.position = (cameraStrings?[0].toPoint())!
        self.vectorN = (cameraStrings?[1].toPoint())!
        self.vectorV = (cameraStrings?[2].toPoint())!
        
        self.d = Double(lastLine![0])!
        self.hx = Double(lastLine![1])!
        self.hy = Double(lastLine![2])!
    }
    
    
    //MARK: - funcs
    func adjustCamera() -> [[Double]]{
        
        self.vectorN = self.vectorN.normalized()
        
        //Grand-Schmidt process
        self.vectorV = orthogonalization(n: self.vectorN, v: self.vectorV)
        
        self.vectorV = self.vectorV.normalized()
        
        let U: Point = crossProduct(u: self.vectorN, v: self.vectorV)
        
        let alpha: [[Double]] = [[U.x, U.y, U.z!],
                                 [self.vectorV.x, self.vectorV.y, self.vectorV.z!],
                                 [self.vectorN.x, self.vectorN.y, self.vectorN.z!]
                                ]
        return alpha
    }
}
