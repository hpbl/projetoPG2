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
    var pixelToDraw: Point = Point() {
        didSet {
            DispatchQueue.main.async {
                self.displayIfNeeded()
            }
        }
    }
    
    override var acceptsFirstResponder: Bool { return true }
    override func viewDidMoveToWindow() {}
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 8 {
            shouldDraw = !shouldDraw
            self.pixelToDraw = Point(x: 100, y: 100)
            DispatchQueue.main.async {
                self.parteGeral()
            }
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
            🖌(self.pixelToDraw)
        }
        
        //forcando execucao dos comandos OpenGL
        glFlush()
    }
    
    //MARK: - Algoritmo de execução
    func parteGeral() {
        
        // Gram-Schmidt
        let alpha = self.camera.adjustCamera()
        
        //passando posição da fonte de luz para coordenada de vista
        self.iluminacao.viewLightPosition = alpha * (self.iluminacao.rwLightPosition - self.camera.position)
        
        //passando pontos do objeto para coordenadas de vista
        for point in self.objeto.rwPoints {
            let viewPoint = alpha * (point - self.camera.position)
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
            var screenPoint = Point(x: (camera.d * point.x)/(camera.hx * point.z!),
                                    y: (camera.d * point.y)/(camera.hy * point.z!))
            
            //parametrizando pontos em relação à janela e transformando em inteiro
            screenPoint.x = Double(Int((screenPoint.x + 1) * Double(self.frame.width) / 2))
            screenPoint.y = Double(Int((1 - screenPoint.y) * Double(self.frame.height) / 2))
            
            objeto.screenPoints.append(screenPoint)
            
            if screenPoint.x > Double(self.frame.width) || screenPoint.x < 0 || screenPoint.y > Double(self.frame.height) || screenPoint.y < 0 {
                Swift.print("passou dos limites jovenzinho \(screenPoint)")
            }
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
            let controlPoints = [triangle.firstVertex, triangle.secondVertex, triangle.thirdVertex]
            
            var sortedPoints = controlPoints.sorted {(pointA, pointB) -> Bool in
                return (pointA.y == pointB.y) ? (pointA.x < pointB.x) : (pointA.y > pointB.y)
            }
            
            if (sortedPoints.filter{$0.y == sortedPoints[0].y}).count > 1 {
                
                Swift.print(sortedPoints.filter{$0.y == sortedPoints[0].y}.count)
                //triangulo é flat-top
                let maxYPoints = [sortedPoints[0], sortedPoints[1]]
                
                //pegando a e b das equações
                let lineEquation1 = triangle.edges?[PointTuple(pointA: maxYPoints[0],
                                                               pointB: sortedPoints[2])]
                
                let a1 = lineEquation1?.0
                //let b1 = lineEquation1?.1
                
                
                let lineEquation2 = triangle.edges?[PointTuple(pointA: maxYPoints[1],
                                                               pointB: sortedPoints[2])]
                
                let a2 = lineEquation2?.0
                
                //tratando o flat-top
                var Xmin = maxYPoints[0].x
                var Xmax = maxYPoints[1].x
                var currentY = maxYPoints[0].y
                let Ymin = sortedPoints[2].y
                
                
                while currentY >= Ymin {
                    var currX = Xmin
                    while currX <= Xmax {
                        
                        if currX >= 0 && currentY >= 0 {
                            let phongReturn = phongRoutine(triangle: triangle,
                                                           objeto: objeto,
                                                           iluminacao: iluminacao,
                                                           pixel: Point(x: round(currX), y: round(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            Swift.print("Pixel: \(pixel.x), \(pixel.y), \(pixel.z)")
                            
                        }
                        currX = currX + 1
                    }
                    
                    //decrementando o currentY
                    Xmin = Xmin - 1/a1!
                    Xmax = Xmax - 1/a2!
                    
                    if Xmin == Xmax {
                        currentY = Ymin
                    } else {
                        currentY = currentY - 1
                    }
                }
                
                
            } else if (sortedPoints.filter{$0.y == sortedPoints[2].y}).count > 1 {
                //triangulo é flat-bottom
                let minYPoints = [sortedPoints[1], sortedPoints[2]]
                
                //pegando a e b das equações
                let lineEquation1 = triangle.edges?[PointTuple(pointA: minYPoints[0],
                                                               pointB: sortedPoints[0])]
                
                let a1 = lineEquation1?.0
                //let b1 = lineEquation1?.1
                
                
                let lineEquation2 = triangle.edges?[PointTuple(pointA: minYPoints[1],
                                                               pointB: sortedPoints[0])]
                
                let a2 = lineEquation2?.0
                
                //tratando o flat-bottom
                var Xmin = sortedPoints[0].x
                var Xmax = sortedPoints[0].x
                var currentY = sortedPoints[0].y
                let Ymin = sortedPoints[2].y
                
                
                while currentY >= Ymin {
                    var currX = Xmin
                    while currX <= Xmax {
                        if currX >= 0 && currentY >= 0 {
                            let phongReturn = phongRoutine(triangle: triangle,
                                                           objeto: objeto,
                                                           iluminacao: iluminacao,
                                                           pixel: Point(x: round(currX), y: round(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            Swift.print("Pixel: \(pixel.x), \(pixel.y), \(pixel.z)")
                        }
                        currX = currX + 1
                    }
                    
                    //decrementando o currentY
                    Xmin = Xmin - 1/a1!
                    Xmax = Xmax - 1/a2!
                    currentY = currentY - 1
                    
                }
                
            } else {
                //triangulo normal
                
                //achando ponto com y médio
                let midPoint = sortedPoints[1]
                
                //cálculando x do novo vértice
                let newVertexX = round(sortedPoints[0].x +
                    (((midPoint.y - sortedPoints[0].y) * (sortedPoints[2].x - sortedPoints[0].x)) / (sortedPoints[2].y - sortedPoints[0].y)))
                
                //criando novo vértice
                let newVertex = Point(x: newVertexX, y: midPoint.y)
                
                //calculando pixels dentro do prieiro triangulo (flat-bottom)
                let flatBottomPart = Triangle(firstVertex: sortedPoints[0], secondVertex: midPoint, thirdVertex: newVertex)
                let controlPointsFB = [flatBottomPart.firstVertex, flatBottomPart.secondVertex, flatBottomPart.thirdVertex]
                let sortedPointsFB = controlPointsFB.sorted {(pointA, pointB) -> Bool in
                    return (pointA.y == pointB.y) ? (pointA.x < pointB.x) : (pointA.y > pointB.y)
                }
                
                
                //triangulo é flat-bottom
                let minYPoints = [sortedPointsFB[1], sortedPointsFB[2]]
                
                //pegando a e b das equações
                var lineEquation1 = flatBottomPart.edges?[PointTuple(pointA: minYPoints[0],
                                                                     pointB: sortedPointsFB[0])]
                
                var a1 = lineEquation1?.0
                
                
                var lineEquation2 = flatBottomPart.edges?[PointTuple(pointA: minYPoints[1],
                                                                     pointB: sortedPointsFB[0])]
                
                var a2 = lineEquation2?.0
                
                //tratando o flat-bottom
                var Xmin = sortedPointsFB[0].x
                var Xmax = sortedPointsFB[0].x
                var currentY = sortedPointsFB[0].y
                var Ymin = sortedPointsFB[2].y
                
                
                while currentY >= Ymin {
                    var currX = Xmin
                    while currX <= Xmax {
                        if currX >= 0 && currentY >= 0 {
                            let phongReturn = phongRoutine(triangle: triangle,
                                                           objeto: objeto,
                                                           iluminacao: iluminacao,
                                                           pixel: Point(x: round(currX), y: round(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            Swift.print("Pixel: \(pixel.x), \(pixel.y), \(pixel.z)")
                        }
                        currX = currX + 1
                    }
                    
                    //decrementando o currentY
                    Xmin = Xmin - 1/a1!
                    Xmax = Xmax - 1/a2!
                    currentY = currentY - 1
                    
                }
                
                
                //calculando pixels dentro do segundo triangulo (flat-top)
                let flatTopPart = Triangle(firstVertex: midPoint, secondVertex: newVertex, thirdVertex: sortedPoints[2])
                let controlPointsFT = [flatTopPart.firstVertex, flatTopPart.secondVertex, flatTopPart.thirdVertex]
                let sortedPointsFT = controlPointsFT.sorted {(pointA, pointB) -> Bool in
                    return (pointA.y == pointB.y) ? (pointA.x < pointB.x) : (pointA.y > pointB.y)
                }
                
                //triangulo é flat-top
                let maxYPoints = [sortedPointsFT[0], sortedPointsFT[1]]
                
                //pegando a e b das equações
                lineEquation1 = flatTopPart.edges?[PointTuple(pointA: maxYPoints[0],
                                                              pointB: sortedPointsFT[2])]
                
                a1 = lineEquation1?.0
                //let b1 = lineEquation1?.1
                
                
                lineEquation2 = flatTopPart.edges?[PointTuple(pointA: maxYPoints[1],
                                                              pointB: sortedPointsFT[2])]
                
                a2 = lineEquation2?.0
                
                //tratando o flat-top
                Xmin = maxYPoints[0].x
                Xmax = maxYPoints[1].x
                currentY = maxYPoints[0].y
                Ymin = sortedPointsFT[2].y
                
                
                while currentY >= Ymin {
                    var currX = Xmin
                    while currX <= Xmax {
                        if currX >= 0 && currentY >= 0 {
                            let phongReturn = phongRoutine(triangle: triangle,
                                                           objeto: objeto,
                                                           iluminacao: iluminacao,
                                                           pixel: Point(x: round(currX), y: round(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            Swift.print("Pixel: \(pixel.x), \(pixel.y), \(pixel.z)")
                        }
                        currX = currX + 1
                    }
                    
                    //decrementando o currentY
                    Xmin = Xmin - 1/a1!
                    Xmax = Xmax - 1/a2!
                    
                    if Xmin == Xmax {
                        currentY = Ymin
                    } else {
                        currentY = currentY - 1
                    }
                }
                
            }
        }
    }
    
    
    //MARK: - OpenGL methods
    func 🖌(_ pixel: Point) {
        
        let r = Float(pixel.color!.0 / 255)
        let g = Float(pixel.color!.1 / 255)
        let b = Float(pixel.color!.2 / 255)
        
        glPointSize(2.0)
        glColor3f(r, g, b)
        glBegin(GLenum(GL_POINTS))
        
        glVertex2i(Int32(pixel.x), Int32(pixel.y))
        
        
        glEnd()
    }
    
}
