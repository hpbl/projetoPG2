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

func phongRoutine(triangle: Triangle, objeto: Object, iluminacao: Illumination, pixel: Point, zBuffer: [[Double]]) -> (Point, [[Double]]) {

    //ignorando pixels fora da tela
    if pixel.x > Double(zBuffer.count) || pixel.y > Double(zBuffer[0].count) {
        return (pixel, zBuffer)
    }
    var zBufferLocal = zBuffer
    var pixelLocal = pixel
    
    
    //pegando triangulo 3D correspondente ao 2D
    let triangleIndex = objeto.triangles2D.index(of: triangle)
    let triangle3D = objeto.triangles3D[triangleIndex!]
    
        // Calcular coordenadas baricentricas (alfa, beta, gama) de P com relacao aos vertices 2D:
        let barycentricCoord = pixel.getBarycentricCoords(triangle: triangle)
        
        // Multiplicar coordenadas baricentricas pelos vertices 3D originais obtendo P', que eh uma aproximacao pro ponto 3D:
        let pixel3D = pixel.approx3DCoordinates(alfaBetaGama: barycentricCoord, triangle3D: triangle3D)
        
        // Consulta ao z-buffer:
        if pixel3D.z! < zBufferLocal[Int(pixel.x)-1][Int(pixel.y)-1] {//TODO: (nao esquecer de tambem checar os limites do array z-buffer)
            zBufferLocal[Int(pixel.x)-1][Int(pixel.y)-1] = pixel3D.z!
            
            // Calcular uma aproximacao para a normal do ponto P'
            var N3D = pixel3D.normalized()
            
            var N = triangle.firstVertex.normalized() * (barycentricCoord.x) +
                triangle.secondVertex.normalized() * (barycentricCoord.y) +
                triangle.thirdVertex.normalized() * (barycentricCoord.z!)
            
            var V = Point(x: -pixel3D.x, y: -pixel3D.y, z: -pixel3D.z!)
            var L = iluminacao.viewLightPosition! - pixel3D
            
            //Normalizar N, V e L
            N = N.normalized()
            V = V.normalized()
            L = L.normalized()
            
            if innerProduct(u: V, v: N) < 0 {
                N3D = Point(x: -N3D.x, y: -N3D.y, z: -N3D.z!)
            }
            
            //cor do pixel por phong (R, G, B)
            var I : Point
            if innerProduct(u: N, v: L)  < 0 {
                //não possui componente difusa nem especular
                let ambientalComponent = getAmbientalComponent(illumination: iluminacao)
                I = phongColor(ambientalComponent: ambientalComponent,
                               difuseComponent: nil,
                               specularComponent: nil)
                
            } else {
                var R = (N * (2 * innerProduct(u: N, v: L))) - L
                R = R.normalized()
                
                if innerProduct(u: R, v: V) < 0 {
                    //não possui componente especular
                    let ambientalComponent = getAmbientalComponent(illumination: iluminacao)
                    let difuseComponent = getDifuseComponent(illumination: iluminacao,
                                                             N: N,
                                                             L: L)
                    I = phongColor(ambientalComponent: ambientalComponent,
                                   difuseComponent: difuseComponent,
                                   specularComponent: nil)
                } else {
                    //TODO: Conferir se é assim
                    let ambientalComponent = getAmbientalComponent(illumination: iluminacao)
                    let difuseComponent = getDifuseComponent(illumination: iluminacao,
                                                             N: N,
                                                             L: L)
                    let specularComponent = getSpecularComponent(illumination: iluminacao,
                                                                 R: R,
                                                                 V: V)
                    
                    I = phongColor(ambientalComponent: ambientalComponent,
                                   difuseComponent: difuseComponent,
                                   specularComponent: specularComponent)
                }
            }
            //TODO: pintar pixel com cor (I) correspondente
            pixelLocal.color = verifyRGB(I: I)
        } else {
            
            
            
            
    }
    return (pixelLocal, zBufferLocal)
}

