//
//  Point.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

struct Point {
    var x: Double
    var y: Double
    var z: Double?
    
    
    func normalized() -> Point {
        let norm = sqrt((self.x * self.x) + (self.y * self.y) + (self.z! * self.z!))
        
        return Point(x: self.x/norm, y: self.y/norm, z: self.z!/norm)
    }
}
