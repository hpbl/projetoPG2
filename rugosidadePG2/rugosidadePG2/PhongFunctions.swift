//
//  PhongFiles.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 13/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation

//😎❤️💚💙
func verifyRGB(I: Point) -> (Double, Double, Double){
    var newI = I
    
    if I.x > 255 {
        newI.x = 255
    }
    if I.y > 255 {
        newI.y = 255
    }
    if I.z! > 255 {
        newI.z = 255
    }
    
    return (newI.x, newI.y, newI.z!)
}

func phongColor(ambientalComponent: Point, difuseComponent: Point?, specularComponent: Point? ) -> Point {
    var I = Point()
    
    if difuseComponent != nil {
        if specularComponent != nil {
            I = ambientalComponent + difuseComponent! + specularComponent!
        } else {
            I = ambientalComponent + difuseComponent!
        }
    } else {
        I = ambientalComponent
    }
    
    return I
    
}

func getAmbientalComponent(illumination: Illumination) -> Point {
    let ka = illumination.ambientReflection
    let Ia = illumination.ambientColorVector
    
    return Ia * ka
}

func getDifuseComponent(illumination: Illumination, N: Point, L: Point) -> Point {
    let kd = illumination.difuseConstant
    let Od = illumination.difuseVector
    let Il = illumination.lightSourceColor
    
    let double: Double = (innerProduct(u: N, v: L) * kd)
    let vector: Point = Point(x: Il.x * Od.x, y: Il.y * Od.y, z: Il.z! * Od.z!)
    
    return vector * double
}

func getSpecularComponent(illumination: Illumination, R: Point, V: Point) -> Point {
    let ks = illumination.specularPart
    let n = illumination.rugosityConstant
    let Il = illumination.lightSourceColor
    
    return Il * (ks * pow(innerProduct(u: R, v: V), n))
}
