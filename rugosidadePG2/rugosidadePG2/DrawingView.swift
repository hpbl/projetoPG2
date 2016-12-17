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
import CoreGraphics

class DrawingView: NSView {
    var backgroundQueue : DispatchQueue?
    let camera = Camera(named: "vader")
    let objeto = Object(named: "vader")
    let iluminacao = Illumination(named: "iluminacao")
    var shouldDraw: Bool = false
    var pixelColors: [NSColor] = []
    var pixelsToDraw: [NSRect] = []
    var pixelToDraw: Point? {
        didSet {
            //mandando redesenhar a view
            //🖌(self.pixelToDraw)
            //self.pixelsToDraw.append(NSRect(x: self.pixelToDraw.x, y: self.pixelToDraw.y, width: 2, height: 2))
            self.shouldDraw = true
            self.pixelsToDraw.append(NSRect(x: (self.pixelToDraw?.x)!, y: (self.pixelToDraw?.y)!, width: 2, height: 2))
            
            if pixelToDraw?.color != nil {
                self.pixelColors.append(NSColor(red: CGFloat((self.pixelToDraw?.color!.0)!)/255,
                                                green: CGFloat((self.pixelToDraw?.color!.1)!)/255,
                                                blue: CGFloat((self.pixelToDraw?.color!.2)!)/255,
                                                alpha: 1))

            } else {
                self.pixelColors.append(NSColor.black)
                //Swift.print("NAAAAO0000000")
            }
            
            self.setNeedsDisplay(NSRect(x: (self.pixelToDraw?.x)!,
                                        y: (self.pixelToDraw?.y)!,
                                        width: 2, height: 2))
        }
    }
    
    override var acceptsFirstResponder: Bool { return true }
    override func viewDidMoveToWindow() {
        backgroundQueue = DispatchQueue(label: "com.app.backqueue")
        
    }
    
    override func keyDown(with event: NSEvent) {
        
        if event.keyCode == 8 {
            shouldDraw = !shouldDraw
            backgroundQueue?.async {
                self.parteGeral()
            }
            
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        
        //NSColor.black.setFill()
        //NSRectFill(self.bounds)
        
        //if shouldDraw{
        if shouldDraw {
            
            NSColor.red.set()
            NSRectFillListWithColors(self.pixelsToDraw, self.pixelColors, self.pixelsToDraw.count)
            //NSRectFillList(self.pixelsToDraw, self.pixelsToDraw.count)
        } else {
            NSColor.black.set()
            NSRectFill(NSRect(x: 20, y: 20, width: 2, height: 2))
            NSRectFill(NSRect(x: 24, y: 24, width: 2, height: 2))
            NSRectFill(NSRect(x: 28, y: 28, width: 2, height: 2))
        }
        
        //Swift.print("Executou")
        
        //teste
        //shouldDraw = !shouldDraw
        //self.pixelToDraw = Point(x: 100, y: 100)
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
            
            
        }
        
        //Inicializar z-buffer com dimensoes [width][height] e +infinto em todas as posições
        var zBuffer = [[Double]]()
        
        let column = Array(repeating: Double.infinity, count: Int(self.frame.height))
        
        for _ in (0..<Int(self.frame.width)) {
            zBuffer.append(column)
        }
        
        //Conversão por varredura
        for triangle in self.objeto.triangles2D {
            
            if triangle.firstVertex.y == triangle.secondVertex.y && triangle.firstVertex.y == triangle.thirdVertex.y {
            }
            //scanLine
            let controlPoints = [triangle.firstVertex, triangle.secondVertex, triangle.thirdVertex]
            
            var sortedPoints = controlPoints.sorted {(pointA, pointB) -> Bool in
                return (pointA.y == pointB.y) ? (pointA.x < pointB.x) : (pointA.y > pointB.y)
            }
            
            if (sortedPoints.filter{$0.y == sortedPoints[0].y}).count > 1 {
                
                //triangulo é flat-top
                let maxYPoints = [sortedPoints[0], sortedPoints[1]]
                
                if maxYPoints[0] == maxYPoints[1] || isLine(triangle) {
                    //é uma linha
                    
                    let lineEquation = triangle.edges?[PointTuple(pointA: maxYPoints[0],
                                                                     pointB: sortedPoints[2])]
                    var a1: Double?
                    if lineEquation?.0 == 0 {
                        a1 = Double.infinity
                    } else {
                        a1 = lineEquation?.0
                    }
                    
                    var currentY = maxYPoints[0].y
                    var currentX = maxYPoints[0].x
                    
                    let minY = sortedPoints[2].y
                    let maxX = sortedPoints[2].x
                    
                    if currentY == minY {
                        while currentX <= maxX {
                            //TODO: Aqui linha
                            let phongReturn = phongRoutine(triangle: triangle,
                                                           objeto: objeto,
                                                           iluminacao: iluminacao,
                                                           pixel: Point(x: floor(currentX),
                                                                        y: floor(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            DispatchQueue.main.async {
                                self.pixelToDraw = pixel
                            }
                            currentX = currentX + 1
                        }
                    } else {
                    
                    while currentY <= minY {
                        //TODO: Aqui linha
                        let phongReturn = phongRoutine(triangle: triangle,
                                                       objeto: objeto,
                                                       iluminacao: iluminacao,
                                                       pixel: Point(x: floor(currentX),
                                                                    y: floor(currentY)),
                                                       zBuffer: zBuffer)
                        zBuffer = phongReturn.1
                        let pixel = phongReturn.0
                        
                        DispatchQueue.main.async {
                            self.pixelToDraw = pixel
                        }
                        currentX = currentX - 1/a1!
                        currentY = currentY - 1
                        }
                    }
                    
                    
                } else {
                    
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
                                                               pixel: Point(x: floor(currX), y: floor(currentY)),
                                                               zBuffer: zBuffer)
                                zBuffer = phongReturn.1
                                let pixel = phongReturn.0
                                
                                //TODO: Aqui
                                //executeAfter(delay: 2) {
                                DispatchQueue.main.async {
                                    self.pixelToDraw = pixel
                                }
                                //}
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
                                                           pixel: Point(x: floor(currX), y: floor(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            //TODO: Aqui
                            //executeAfter(delay: 2) {
                            DispatchQueue.main.async {
                                self.pixelToDraw = pixel
                            }
                            
                            //}
                            
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
                                                           pixel: Point(x: floor(currX), y: floor(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            //TODO: Aqui
                            //executeAfter(delay: 2) {
                            DispatchQueue.main.async {
                                self.pixelToDraw = pixel
                            }
                            //}
                            
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
                
                if maxYPoints[0] == maxYPoints[1] || isLine(flatTopPart) {
                    //é uma linha
                    let lineEquation = flatTopPart.edges?[PointTuple(pointA: maxYPoints[0],
                                                                     pointB: sortedPointsFT[2])]
                    var a1: Double?
                    if lineEquation?.0 == 0 {
                        a1 = Double.infinity
                    } else {
                        a1 = lineEquation?.0
                    }
                    
                    currentY = maxYPoints[0].y
                    var currentX = maxYPoints[0].x
                    
                    let minY = sortedPointsFT[2].y
                    let maxX = sortedPoints[2].x

                    
                    if currentY == minY {
                        while currentX <= maxX {
                            //TODO: Aqui linha
                            let phongReturn = phongRoutine(triangle: triangle,
                                                           objeto: objeto,
                                                           iluminacao: iluminacao,
                                                           pixel: Point(x: floor(currentX),
                                                                        y: floor(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            DispatchQueue.main.async {
                                self.pixelToDraw = pixel
                            }
                            currentX = currentX + 1
                        }
                    } else {
                        
                        while currentY <= minY {
                            //TODO: Aqui linha
                            let phongReturn = phongRoutine(triangle: triangle,
                                                           objeto: objeto,
                                                           iluminacao: iluminacao,
                                                           pixel: Point(x: floor(currentX),
                                                                        y: floor(currentY)),
                                                           zBuffer: zBuffer)
                            zBuffer = phongReturn.1
                            let pixel = phongReturn.0
                            
                            DispatchQueue.main.async {
                                self.pixelToDraw = pixel
                            }
                            currentX = currentX - 1/a1!
                            currentY = currentY - 1
                        }
                    }
                    
                } else {
                    
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
                                                               pixel: Point(x: floor(currX), y: floor(currentY)),
                                                               zBuffer: zBuffer)
                                zBuffer = phongReturn.1
                                let pixel = phongReturn.0
                                
                                //TODO: Aqui
                                //executeAfter(delay: 2) {
                                DispatchQueue.main.async {
                                    self.pixelToDraw = pixel
                                }
                                //}
                                
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
    }
    
}
