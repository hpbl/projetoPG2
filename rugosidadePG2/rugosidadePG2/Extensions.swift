//
//  Extensions.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

extension String {
    func toPoint() -> Point{
        let xPos = Double((self.components(separatedBy: " ")[0]))
        let yPos = Double((self.components(separatedBy: " ")[1]))
        let zPos = Double((self.components(separatedBy: " ")[2]))
        
        return Point(x: xPos!, y: yPos!, z: zPos)
    }
}
