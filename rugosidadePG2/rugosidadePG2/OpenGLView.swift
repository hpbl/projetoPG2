//
//  OpenGLView.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 13/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Foundation
import AppKit
import Cocoa
import OpenGL
import GLKit
import GLUT

class OpenGLView: NSOpenGLView {
    let camera = Camera(named: "calice2")
    let objeto = Object(named: "calice2")
    let iluminacao = Illumination(named: "iluminacao")
    var shouldDraw: Bool = false
    
    override var acceptsFirstResponder: Bool { return true }
    override func viewDidMoveToWindow() {
        
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 8 {
            self.parteGeral()
            shouldDraw = !shouldDraw
            self.setNeedsDisplay(self.frame)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        //Background
        glClearColor(40/255, 43/255, 53/255, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        //draw points routine
        if shouldDraw{
            self.draw(points: self.objeto.triangles2D[0].pixels)
        }
        
        //forcando execucao dos comandos OpenGL
        glFlush()
    }
    
    func draw(points: [Point]) {
        glPointSize(2.0)
        glColor3f(0, 170/255, 202/255)
        glBegin(GLenum(GL_POINTS))
        
        for point in points {
            glVertex3fv([Float(point.x), Float(point.y), 0])
        }
        
        glEnd()
    }
    
    //MARK: - Algoritmo de execução
    func parteGeral() {
        
        // Gram-Schmidt
        let alpha = self.camera.adjustCamera()
        
        //passando posição da fonte de luz para coordenada de vista
        self.iluminacao.viewLightPosition = alpha * (self.iluminacao.rwLightPosition - self.camera.position)
        
        //passando pontos do objeto para coordenadas de vista
        for point in self.objeto.rwPoints {
            let viewPoint = alpha * (point - camera.position)
            objeto.viewPoints.append(viewPoint)
            //inicializando normais como zero
            objeto.pointsNormalsDict[viewPoint] = Point(x: 0, y: 0, z: 0)
        }
        
        //calculando a normal dos triangulos e normalizando
        for triangle in self.objeto.triangles3D {
            let triangleNormal = triangle.normal().normalized()
            
            //somar a normal à de cada um dos pontos
            objeto.pointsNormalsDict[triangle.firstVertex] = (objeto.pointsNormalsDict[triangle.firstVertex]!) + triangleNormal
            
            objeto.pointsNormalsDict[triangle.secondVertex] = (objeto.pointsNormalsDict[triangle.secondVertex]!) + triangleNormal
            
            objeto.pointsNormalsDict[triangle.thirdVertex] = (objeto.pointsNormalsDict[triangle.thirdVertex])! + triangleNormal
        }
        
        //normalizando as normais
        for (point, normal) in self.objeto.pointsNormalsDict {
            objeto.pointsNormalsDict[point] = normal.normalized()
        }
        
        //projetar pontos para coordenadas 2D
        for point in self.objeto.viewPoints {
            //gerando pontos 2D [-1, 1]
            var screenPoint = Point(x: (camera.d/camera.hx) * (point.x/point.z!),
                                    y: (camera.d/camera.hy) * (point.y)/point.z!)
            
            //parametrizando pontos em relação à janela e transformando em inteiro
            screenPoint.x = Double(Int((screenPoint.x + 1) * Double(self.frame.width) / 2))
            screenPoint.y = Double(Int((1 - screenPoint.y) * Double(self.frame.height) / 2))
            
            objeto.screenPoints.append(screenPoint)
        }
        
        //Inicializar z-buffer com dimensoes [width][height] e +infinto em todas as posições
        var zBuffer = [[Double]]()
        
        let column = Array(repeating: Double.infinity, count: Int(self.frame.height))
        
        for _ in (0..<Int(self.frame.width)) {
            zBuffer.append(column)
        }
        
        //Conversão por varredura
        for triangle in self.objeto.triangles2D {
            //scanLine
            var trianglePixels = getPixels(from: triangle)
            
            //pegando triangulo 3D correspondente ao 2D
            let triangleIndex = objeto.triangles2D.index(of: triangle)
            let triangle3D = objeto.triangles3D[triangleIndex!]
            
            self.objeto.triangles2D[triangleIndex!].pixels = trianglePixels
            
            for pixel in trianglePixels {
                // Calcular coordenadas baricentricas (alfa, beta, gama) de P com relacao aos vertices 2D:
                let barycentricCoord = pixel.getBarycentricCoord(triangle: triangle)
                
                // Multiplicar coordenadas baricentricas pelos vertices 3D originais obtendo P', que eh uma aproximacao pro ponto 3D:
                let pixel3D = pixel.approx3DCoordinates(alfaBetaGama: barycentricCoord!, triangle3D: triangle3D)
                
                // Consulta ao z-buffer:
                if pixel3D.z! < zBuffer[Int(pixel.x)][Int(pixel.y)] {//TODO: (nao esquecer de tambem checar os limites do array z-buffer)
                    zBuffer[Int(pixel.x)][Int(pixel.y)] = pixel3D.z!
                    
                    // Calcular uma aproximacao para a normal do ponto P'
                    var N3D = pixel3D.normalized()
                    
                    var N = triangle.firstVertex.normalized() * (barycentricCoord?.x)! +
                        triangle.secondVertex.normalized() * (barycentricCoord?.y)! +
                        triangle.thirdVertex.normalized() * (barycentricCoord?.z!)!
                    
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
                        let ambientalComponent = getAmbientalComponent(illumination: self.iluminacao)
                        I = phongColor(ambientalComponent: ambientalComponent,
                                       difuseComponent: nil,
                                       specularComponent: nil)
                        
                    } else {
                        var R = (N * (2 * innerProduct(u: N, v: L))) - L
                        R = R.normalized()
                        
                        if innerProduct(u: R, v: V) < 0 {
                            //não possui componente especular
                            let ambientalComponent = getAmbientalComponent(illumination: self.iluminacao)
                            let difuseComponent = getDifuseComponent(illumination: self.iluminacao,
                                                                     N: N,
                                                                     L: L)
                            I = phongColor(ambientalComponent: ambientalComponent,
                                           difuseComponent: difuseComponent,
                                           specularComponent: nil)
                        } else {
                            //TODO: Conferir se é assim
                            let ambientalComponent = getAmbientalComponent(illumination: self.iluminacao)
                            let difuseComponent = getDifuseComponent(illumination: self.iluminacao,
                                                                     N: N,
                                                                     L: L)
                            let specularComponent = getSpecularComponent(illumination: self.iluminacao,
                                                                         R: R,
                                                                         V: V)
                            
                            I = phongColor(ambientalComponent: ambientalComponent,
                                           difuseComponent: difuseComponent,
                                           specularComponent: specularComponent)
                        }
                    }
                    //TODO: pintar pixel com cor (I) correspondente
                    let index = trianglePixels.index(of: pixel)
                    trianglePixels[index!].color = verifyRGB(I: I)
                }
                
            }
        }
    }
    
}
