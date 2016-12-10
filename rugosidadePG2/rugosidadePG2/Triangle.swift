//
//  triangle.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

struct Triangle {
    var firstVertex: Point
    var secondVertex: Point
    var thirdVertex: Point
    
    func normal() -> Point {
        return crossProduct(u: (self.thirdVertex - self.firstVertex),
                            v: (self.thirdVertex - self.secondVertex))
    }
}

