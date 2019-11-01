//
//  GameViewController.swift
//  GameOfLife
//
//  Created by Pedro Cacique on 31/10/19.
//  Copyright © 2019 Pedro Cacique. All rights reserved.
//
//  SILVER

import UIKit
import QuartzCore
import SceneKit
import SwiftGameOfLife

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var scene: SCNScene
    var grid: Grid
    var nodes: [SCNNode] = []
    var renderTime: TimeInterval = 0
    let duration: TimeInterval = 0.1
    let size: Int = 10
    var population: [[SCNNode]] = []
    var currentGen: Int = 0
    var lightNode: SCNNode
    
    required init?(coder aDecoder: NSCoder) {
        scene = SCNScene()
        grid = Grid(width: size, height: size, isRandom: true, proportion: 50)
        grid.addRule(CountRule(name: "Solitude", startState: .alive, endState: .dead, count: 2, type: .lessThan))
        grid.addRule(CountRule(name: "Survive2", startState: .alive, endState: .alive, count: 2, type: .equals))
        grid.addRule(CountRule(name: "Survive3", startState: .alive, endState: .alive, count: 3, type: .equals))
        grid.addRule(CountRule(name: "Overpopulation", startState: .alive, endState: .dead, count: 3, type: .greaterThan))
        grid.addRule(CountRule(name: "Birth", startState: .dead, endState: .alive, count: 3, type: .equals))
        lightNode = SCNNode()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        showGen()
    }
    
    func showGen(){
//        removeAllNodes()
        swiftGens()
        for i in 0..<grid.width {
            for j in 0..<grid.height {
                if grid.cells[i][j].state == .alive {
                    let x:Float = Float(i) * 1.05 - Float(grid.width/2)
                    let z:Float = Float(j) * 1.05 - Float(grid.height/2)
                    placeBox( pos: SCNVector3(x: x, y: 0, z: z) )
                }
            }
        }
        population.append(nodes)
        currentGen += 1
    }
    
    func swiftGens(){
        if currentGen > 0{
            let nodes = population.last!
            for n in nodes{
                n.position.y += 1.05
            }
        }
        
    }
    
    func placeBox(pos: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)){
        let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = pos
        scene.rootNode.addChildNode(boxNode)
        nodes.append(boxNode)
    }
    
    func removeAllNodes(){
        for p in population{
            for n in p {
                n.removeAllActions()
                n.removeFromParentNode()
            }
        }
        nodes = []
        population = []
    }
    
    func setupScene(){
        // CAMERA
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: Float(2*size), y: Float(size*10), z: 0)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        
        // OMNI LIGHT
        
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // AMBIENT LIGHT
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let scnView = self.view as! SCNView
        scnView.delegate = self
        scnView.scene = scene
        
        scnView.isPlaying = true
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false
        scnView.backgroundColor = UIColor.black
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > renderTime {
            grid.applyRules()
            showGen()
            lightNode.position.y += 1.05
            renderTime = time + duration
        }
    }
}
