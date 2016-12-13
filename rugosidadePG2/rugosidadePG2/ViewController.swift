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
        for triangle in objeto.triangles2D {
            //scanLine
            let trianglePixels = getPixels(from: triangle)
            
            //pegando triangulo 3D correspondente ao 2D
            let triangleIndex = objeto.triangles2D.index(of: triangle)
            let triangle3D = objeto.triangles3D[triangleIndex!]
            
            for pixel in trianglePixels {
                // Calcular coordenadas baricentricas (alfa, beta, gama) de P com relacao aos vertices 2D:
                let barycentricCoord = pixel.getBarycentricCoord(triangle: triangle)
                
                // Multiplicar coordenadas baricentricas pelos vertices 3D originais obtendo P', que eh uma aproximacao pro ponto 3D:

                let pixel3D = pixel.convertTo3DCoord(alfaBetaGama: barycentricCoord!, triangle3D: triangle3D)
                
                // Consulta ao z-buffer:
                if pixel3D.z! < zBuffer[Int(pixel3D.x)][Int(pixel3D.y)] {//TODO: (nao esquecer de tambem checar os limites do array z-buffer)
                    zBuffer[Int(pixel3D.x)][Int(pixel3D.y)] = pixel3D.z!
                    
                    // Calcular uma aproximacao para a normal do ponto P'
                    var N = triangle.firstVertex * (barycentricCoord?.x)! +
                            triangle.secondVertex * (barycentricCoord?.y)! +
                            triangle.thirdVertex * (barycentricCoord?.z!)!
                    
                    var V = Point(x: -pixel3D.x, y: -pixel3D.y, z: -pixel3D.z!)
                    var L = iluminacao.viewLightPosition! - pixel3D
                    
                    //Normalizar N, V e L
                    N = N.normalized()
                    V = V.normalized()
                    L = L.normalized()
                    

                }
            }
        }
    }
}
