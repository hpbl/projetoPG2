//
//  ViewController.swift
//  rugosidadePG2
//
//  Created by Hilton Pintor Bezerra Leite on 08/12/16.
//  Copyright © 2016 Chien&Pintor&Melo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parteGeral()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    //MARK: - Algoritmo de execução
    func parteGeral() {
        //Inicializaçao dos objejos (leitura dos arquivos de entrada)
        let camera = Camera(named: "vaso")
        let objeto = Object(named: "vaso")
        let iluminacao = Illumination(named: "iluminacao")
        
        
        
        // Gram-Schmidt
        let alpha = camera.adjustCamera()
        
        //passando posição da fonte de luz para coordenada de vista
        iluminacao.viewLightPosition = alpha * (iluminacao.rwLightPosition - camera.position)
        
        //passando pontos do objeto para coordenadas de vista
        for point in objeto.rwPoints {
            let viewPoint = alpha * (point - camera.position)
            objeto.viewPoints.append(viewPoint)
            //inicializando normais como zero
            objeto.pointsNormalsDict[viewPoint] = Point(x: 0, y: 0, z: 0)
        }
        
        //calculando a normal dos triangulos e normalizando
        for triangle in objeto.triangles3D {
            let triangleNormal = triangle.normal().normalized()
            
            //somar a normal à de cada um dos pontos
            objeto.pointsNormalsDict[triangle.firstVertex] = (objeto.pointsNormalsDict[triangle.firstVertex]!) + triangleNormal
            
            objeto.pointsNormalsDict[triangle.secondVertex] = (objeto.pointsNormalsDict[triangle.secondVertex]!) + triangleNormal
            
            objeto.pointsNormalsDict[triangle.thirdVertex] = (objeto.pointsNormalsDict[triangle.thirdVertex])! + triangleNormal
        }
        
        //normalizando as normais
        for (point, normal) in objeto.pointsNormalsDict {
            objeto.pointsNormalsDict[point] = normal.normalized()
        }
        
        //projetar pontos para coordenadas 2D
        for point in objeto.viewPoints {
            //gerando pontos 2D [-1, 1]
            var screenPoint = Point(x: (camera.d/camera.hx) * (point.x/point.z!),
                                    y: (camera.d/camera.hy) * (point.y)/point.z!)
            
            //parametrizando pontos em relação à janela e transformando em inteiro
            screenPoint.x = Double(Int((screenPoint.x + 1) * Double(self.view.frame.width) / 2))
            screenPoint.y = Double(Int((1 - screenPoint.y) * Double(self.view.frame.height) / 2))

            objeto.screenPoints.append(screenPoint)
        }
        
        //Inicializar z-buffer com dimensoes [width][height] e +infinto em todas as posições
        var zBuffer = [[Double]]()
        
        let column = Array(repeating: Double.infinity, count: Int(self.view.frame.height))
        
        for _ in (0..<Int(self.view.frame.width)) {
            zBuffer.append(column)
        }
        
        //Conversão por varredura
        //for triangle in objeto.triangles2D {
        let first = Point(x: 8, y: 0)
        let second = Point(x: 4, y: 0)
        let third = Point(x: 0, y: 4)
        
        
        let triangle = Triangle(firstVertex: first, secondVertex: second, thirdVertex: third)
        let controlPoints = [triangle.firstVertex, triangle.secondVertex, triangle.thirdVertex]
        
        let sortedPoints = controlPoints.sorted {(pointA, pointB) -> Bool in
            return (pointA.y == pointB.y) ? (pointA.x < pointB.x) : (pointA.y > pointB.y)
        }
        
        let edges = triangle.edges
        var trianglePoints = [Point]()
        
        if (sortedPoints.filter{$0.y == sortedPoints[0].y}).count > 1 {
            //triangulo é flat-top
            let maxYPoints = [sortedPoints[0], sortedPoints[1]]
            
            //pegando a e b das equações
            let lineEquation1 = triangle.edges?[PointTuple(pointA: maxYPoints[0],
                                                           pointB: sortedPoints[2])]
            
            let a1 = lineEquation1?.0
            let b1 = lineEquation1?.1
            
            
            let lineEquation2 = triangle.edges?[PointTuple(pointA: maxYPoints[1],
                                                           pointB: sortedPoints[2])]
            
            let a2 = lineEquation2?.0
            let b2 = lineEquation2?.1
            
            //tratando o flat-top
            var Xmin = maxYPoints[0].x
            var Xmax = maxYPoints[1].x
            var currentY = maxYPoints[0].y
            var Ymin = sortedPoints[2].y
            
            
            while currentY >= Ymin {
                trianglePoints = trianglePoints + self.getPointsInside(currentY: currentY, currentX: Xmin, Xmax: Xmax, a1: a1!)
                
                //decrementando o currentY
                Xmin = Xmin - 1/a1!
                Xmax = Xmax - 1/a2!
                currentY = a1! * Xmin + b1!
            }
            
            print(trianglePoints.count)
            
        } else if (sortedPoints.filter{$0.y == sortedPoints[2].y}).count > 1 {
            //triangulo é flat-bottom
            let minYPoints = [sortedPoints[1], sortedPoints[2]]
            
            //pegando a e b das equações
            let lineEquation1 = triangle.edges?[PointTuple(pointA: minYPoints[0],
                                                           pointB: sortedPoints[0])]
            
            let a1 = lineEquation1?.0
            let b1 = lineEquation1?.1
            
            
            let lineEquation2 = triangle.edges?[PointTuple(pointA: minYPoints[1],
                                                           pointB: sortedPoints[0])]
            
            let a2 = lineEquation2?.0
            let b2 = lineEquation2?.1
            
            //tratando o flat-bottom
            var Xmin = sortedPoints[0].x
            var Xmax = sortedPoints[0].x
            var currentY = sortedPoints[0].y
            var Ymin = sortedPoints[2].y
            
            
            while currentY >= Ymin {
                trianglePoints = trianglePoints + self.getPointsInside(currentY: currentY, currentX: Xmin, Xmax: Xmax, a1: a1!)
                
                //decrementando o currentY
                Xmin = Xmin - 1/a1!
                Xmax = Xmax - 1/a2!
                currentY = a1! * Xmin + b1!
            }
            
            print(trianglePoints.count)

            
        } else {
            //triangulo normal
        }
        
    }
    
    //}
    
    func getPointsInside(currentY: Double, currentX: Double, Xmax: Double, a1: Double) -> [Point] {
        var pointsInside = [Point]()
        var currX = currentX
        while currX <= Xmax {
            pointsInside.append(Point(x: currX, y: currentY))
            currX = currX + 1
        }
        return pointsInside
    }
}
