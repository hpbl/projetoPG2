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
        
        return Point(x: xPos!, y: yPos!, z: zPos!)
    }
}

//MARK: - Input
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

func executeAfter(delay: Int, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delay)) {
        block()
    }
}
