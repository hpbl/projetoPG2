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
    
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    //MARK: - Algoritmo de execução
    func parteGeral() {
        //Inicializaçao dos objejos (leitura dos arquivos de entrada)
        let camera = Camera(named: "camaro")
        let objeto = Object(named: "camaro")
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
            objeto.pointsNormalsDict?[viewPoint] = Point(x: 0, y: 0, z: 0)
        }
        
        //calculando a normal dos triangulos e normalizando
        for triangle in objeto.triangles3D {
            let triangleNormal = triangle.normal().normalized()
            
            //somar a normal à de cada um dos pontos
            objeto.pointsNormalsDict?[triangle.firstVertex] = (objeto.pointsNormalsDict?[triangle.firstVertex]!)! + triangleNormal
            
            objeto.pointsNormalsDict?[triangle.secondVertex] = (objeto.pointsNormalsDict?[triangle.secondVertex]!)! + triangleNormal
            
            objeto.pointsNormalsDict?[triangle.thirdVertex] = (objeto.pointsNormalsDict?[triangle.thirdVertex])! + triangleNormal
        }
        
        //normalizando as normais
        for (point, normal) in objeto.pointsNormalsDict! {
            objeto.pointsNormalsDict?[point] = normal.normalized()
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
        for triangle in objeto.triangles2D {
            
            //achar Ymin e Ymax do triangulo
            let controlPoints = [triangle.firstVertex, triangle.secondVertex, triangle.thirdVertex]
            
            let arrayY = [triangle.firstVertex.y, triangle.secondVertex.y, triangle.thirdVertex.y]
            let maxY = arrayY.max()
            let minY = arrayY.min()
            
            let arrayX = [triangle.firstVertex.x, triangle.secondVertex.x, triangle.thirdVertex.x]
            let maxX = arrayX.max()
            let minX = arrayX.min()
            
        }
    }
    


}

