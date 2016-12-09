//
//  Illumination.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 09/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

class Illumination {
    var rwLightPosition: Point
    var ambientReflection: Double
    var ambientColorVector: Point
    var difuseConstant: Double
    var difuseVector: Point
    var specularPart: Double
    var lightSourceColor: Point
    var rugosityConstant: Double
    
    init(named: String) {
        let illuminationStrings = read(from: named, type: "txt")
        
        self.rwLightPosition = (illuminationStrings?[0].toPoint())!
        self.ambientColorVector = (illuminationStrings?[2].toPoint())!
        self.difuseVector = (illuminationStrings?[4].toPoint())!
        self.lightSourceColor = (illuminationStrings?[6].toPoint())!

        self.ambientReflection = Double((illuminationStrings?[1])!)!
        self.difuseConstant = Double((illuminationStrings?[3])!)!
        self.specularPart = Double((illuminationStrings?[5])!)!
        self.rugosityConstant = Double((illuminationStrings?[7])!)!
    }
    
}
