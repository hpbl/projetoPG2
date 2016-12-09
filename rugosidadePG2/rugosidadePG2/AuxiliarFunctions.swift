//
//  AuxiliarFunctions.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 09/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

func read(from file: String, type: String) -> [String]? {
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

//MARK: - Vector formulas

func innerProduct(u: Point, v: Point) {
    return (u.x * v.x) + (u.y + v.y) + (u.z! + v.z!)
}
