//
//  GameScene.swift
//  iStruct2D iPadOS Demo
//
//  Created by weng chong lao on 31/08/2022.
//
//  This project is my individual project that is the further development of the iStruct2D Python
//
//  iStruct2D Python: https://github.com/wengchonglao0124/iStruct2D-Python.git
//
//  This project aims to develop a prototype for the structural analysis software by using Swift on iOS and iPadOS system.
//  Allowing users to use only 4 actions - TAP, SWIPE, PINCH, TWIRL - to analyse the 2D simply supported beam structure.
//
//  Comparing to the traditional structural analysis software, the result presentation of iStruct2D iPadOS Demo is interactive and
//  changes instantly as the input condition is altered giving users an immediate visualization of the impact on structural behaviour.
//

import SpriteKit
import GameplayKit

/**
 Main scene of the application
 */
class GameScene: SKScene {
    
    // Setup all the basic parameters ⬇️
    var startTouch = CGPoint()
    var moveTouch = CGPoint()
    var endTouch = CGPoint()
    
    var startSupportLocation = CGPoint()
    var endSupportLocation = CGPoint()
    var pointLoadLocation = CGPoint()
    
    var selectedObject = false
    var supportGenerated = false
    
    var support1Generated = false
    var support2Generated = false
    
    var pointLoadGenerated = false
    var pointLoadSelected = false
    var pointLoadObject = SKSpriteNode()
    var pointLoadLabel = SKLabelNode()
    var pointLoadMagnitude = CGFloat(1)
    var pointLoadMagnitudeIsChanging = false
    var pointLoadMagnitudeChangingBox = SKShapeNode()
    
    var maxBendingMomentLocation = CGPoint()
    var currentCurve1 = SKShapeNode()
    var currentCurve2 = SKShapeNode()
    var currentMaxValue = SKLabelNode()
    var bendingValueRatio = CGFloat()
    
    var beamLength = CGFloat()
    
    var measureDistance1LineList = [SKShapeNode]()
    var measureDistance1LabelList = [SKLabelNode]()
    var measureDistance2LineList = [SKShapeNode]()
    var measureDistance2LabelList = [SKLabelNode]()
    var measureDistance3LineList = [SKShapeNode]()
    var measureDistance3LabelList = [SKLabelNode]()
    
    var memberToolSelected = false
    var supportToolSelected = false
    var loadingToolSelected = false
    
    var memberToolBg = SKShapeNode()
    var supportToolBg = SKShapeNode()
    var loadingToolBg = SKShapeNode()
    var extendedToolList = [SKSpriteNode]()
    var extendedTool = SKSpriteNode()
    var extendedToolWithObject = false
    
    var shearDiagram = SKShapeNode()
    var generatedShear = false
    var leftValueLabel = SKLabelNode(fontNamed: "LeftValueLabel")
    var rightValueLabel = SKLabelNode(fontNamed: "RightValueLabel")
    
    var deflectionDiagram = SKShapeNode()
    var generatedDeflection = false
    var deflectionValueLabel = SKLabelNode(fontNamed: "DeflectionValueLabel")
    var rotationLeftValueLabel = SKLabelNode(fontNamed: "RotationLeftValueLabel")
    var rotationRightValueLabel = SKLabelNode(fontNamed: "RotationRightValueLabel")
    
    var selectedDeflection = true
    var selectedShear = false
    var selectedBending = false
    
    var deflectionButton = SKShapeNode()
    var shearButton = SKShapeNode()
    var bendingButton = SKShapeNode()
    
    var deflectionBar = SKShapeNode()
    var shearBar = SKShapeNode()
    var bendingBar = SKShapeNode()
    
    var isDraggingActualSupport = false
    var draggingSupport = SKNode()
    
    var isGeneratingUDL = false
    var selectedUDL = false
    var UDL_Object = SKSpriteNode()
    var UDLLoadLabelLeft = SKLabelNode()
    var UDLLoadLabelRight = SKLabelNode()
    
    var isDraggingLoading = false
    
    var isReseting = false
    
    
    /**
     Execute and update when the view interacts with user
     */
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 205/255, green: 216/255, blue: 225/255, alpha: 1)
        generateGridLine()
        generateResetButton()
    }
    
    
    /**
    Calculate and return the distance between two CGPoint objects
     */
    func calculateDistance(start: CGPoint, end: CGPoint) -> CGFloat {
        let distance = sqrt(pow((end.x - start.x), 2) + pow((end.y - start.y), 2))
        return distance
    }
    
    
    /**
     Calculate and return the x coordinate of the middle point between two CGPoint objects
     */
    func calculateCentreX(start: CGPoint, end: CGPoint) -> CGFloat {
        return start.x + (end.x - start.x)/2
    }
    
    
    /**
     Calculate and return the y coordinate of the middle point between two CGPoint objects
     */
    func calculateCentreY(start: CGPoint, end: CGPoint) -> CGFloat {
        return start.y + (end.y - start.y)/2
    }
    
    
    /**
     Calculate and return the rotational angle from the starting point to the ending point vector
     */
    func calculateAngle(start: CGPoint, end: CGPoint) -> CGFloat {
        let x = end.x - start.x
        let y = end.y - start.y
        return atan(y/x)
    }
    
    
    /**
     Convert and return the CGPoint unit to meter unit for analysis
     */
    func calculateRealDistance(distance: CGFloat) -> CGFloat {
        // 675 points = 20 m (testing result)
        return (distance/675)*20
    }
    
    
    /**
     Calculate and return the data of the point loading for later analysis
     */
    func calculatePointLoadDistance() -> (CGFloat, CGFloat, CGFloat) {
        let l = calculateRealDistance(distance: endSupportLocation.x - startSupportLocation.x)
        let a = calculateRealDistance(distance: pointLoadObject.position.x - startSupportLocation.x)
        let b = l - a
        return (l, a, b)
    }
    
    
    /**
     Generate and draw the gridline in the canvas
     */
    func generateGridLine() {
        for x in stride(from: -500, to: 600, by: 25) {
            let length = 800
            let line = SKShapeNode(rectOf: CGSize(width: length, height: 1))
            line.fillColor = UIColor(red: 203/255, green: 209/255, blue: 217/255, alpha: 1)
            line.strokeColor = UIColor(red: 203/255, green: 209/255, blue: 217/255, alpha: 1)
            let y = 0
            line.position = .init(x: x, y: y)
            let angle = CGFloat.pi/2
            line.zRotation = angle
            addChild(line)
        }
        for y in stride(from: -500, to: 500, by: 25) {
            let length = 1200
            let line = SKShapeNode(rectOf: CGSize(width: length, height: 1))
            line.fillColor = UIColor(red: 203/255, green: 209/255, blue: 217/255, alpha: 1)
            line.strokeColor = UIColor(red: 203/255, green: 209/255, blue: 217/255, alpha: 1)
            let x = 0
            line.position = .init(x: x, y: y)
            let angle = CGFloat(0)
            line.zRotation = angle
            addChild(line)
        }
        
        generateToolBar()
        generateExtendedTool()
        generateDiagramSelection()
    }
    
    
    /**
     Generate and draw the tool bar section
     */
    func generateToolBar() {
        let tooBar = SKShapeNode(rectOf: CGSize(width: 100, height: 650))
        tooBar.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        tooBar.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        let x = 465
        let y = 50
        tooBar.position = .init(x: x, y: y)
        let angle = CGFloat.pi
        tooBar.zRotation = angle
        addChild(tooBar)
        
        let line = SKShapeNode(rectOf: CGSize(width: 100, height: 2))
        line.fillColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        line.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        let x2 = 465
        let y2 = 0
        line.position = .init(x: x2, y: y2)
        addChild(line)
        
        let image1 = UIImage(named: "member")
        let texture1 = SKTexture(image: image1!)
        let tool1 = SKSpriteNode(texture: texture1)
        tool1.position = .init(x: 465, y: 300)
        tool1.size = CGSize(width: 70, height: 70)
        addChild(tool1)
        
        let bg1 = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
        bg1.name = "MemberTool"
        bg1.strokeColor = {
            if memberToolSelected {
                return UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0.8)
            }
            else {
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
            }
        }()
        bg1.lineWidth = 4
        bg1.position = .init(x: 465, y: 300)
        addChild(bg1)
        memberToolBg = bg1
        
        let image2 = UIImage(named: "support")
        let texture2 = SKTexture(image: image2!)
        let tool2 = SKSpriteNode(texture: texture2)
        tool2.position = .init(x: 465, y: 200)
        tool2.size = CGSize(width: 70, height: 70)
        addChild(tool2)
        
        let bg2 = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
        bg2.name = "SupportTool"
        bg2.strokeColor = {
            if supportToolSelected {
                return UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0.8)
            }
            else {
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
            }
        }()
        bg2.lineWidth = 4
        bg2.position = .init(x: 465, y: 200)
        addChild(bg2)
        supportToolBg = bg2
        
        let image3 = UIImage(named: "loading")
        let texture3 = SKTexture(image: image3!)
        let tool3 = SKSpriteNode(texture: texture3)
        tool3.position = .init(x: 465, y: 100)
        tool3.size = CGSize(width: 70, height: 70)
        addChild(tool3)
        
        let bg3 = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
        bg3.name = "LoadingTool"
        bg3.strokeColor = {
            if loadingToolSelected {
                return UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0.8)
            }
            else {
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
            }
        }()
        bg3.lineWidth = 4
        bg3.position = .init(x: 465, y: 100)
        addChild(bg3)
        loadingToolBg = bg3
    }
    
    
    /**
     Generate and draw the extended detail section for the tool
     */
    func generateExtendedTool() {
        
        for tool in extendedToolList {
            tool.removeFromParent()
        }
        
        if supportToolSelected {
            let image1 = UIImage(named: "RFR1")
            let texture1 = SKTexture(image: image1!)
            let tool1 = SKSpriteNode(texture: texture1)
            tool1.name = "RFR1"
            tool1.position = .init(x: 465, y: -50)
            tool1.size = CGSize(width: 70, height: 70)
            addChild(tool1)
            extendedToolList.append(tool1)
            
            let image2 = UIImage(named: "FFR1")
            let texture2 = SKTexture(image: image2!)
            let tool2 = SKSpriteNode(texture: texture2)
            tool2.name = "FFR1"
            tool2.position = .init(x: 465, y: -130)
            tool2.size = CGSize(width: 70, height: 70)
            addChild(tool2)
            extendedToolList.append(tool2)
            
            let image3 = UIImage(named: "FFF1")
            let texture3 = SKTexture(image: image3!)
            let tool3 = SKSpriteNode(texture: texture3)
            tool3.name = "FFF1"
            tool3.position = .init(x: 465, y: -210)
            tool3.size = CGSize(width: 70, height: 70)
            addChild(tool3)
            extendedToolList.append(tool3)
        }
        
        if loadingToolSelected {
            let image4 = UIImage(named: "Arrow")
            let texture4 = SKTexture(image: image4!)
            let tool4 = SKSpriteNode(texture: texture4)
            tool4.name = "Arrow"
            tool4.position = .init(x: 465, y: -50)
            tool4.size = CGSize(width: 70, height: 70)
            addChild(tool4)
            extendedToolList.append(tool4)
            
            let image5 = UIImage(named: "UDL")
            let texture5 = SKTexture(image: image5!)
            let tool5 = SKSpriteNode(texture: texture5)
            tool5.name = "UDL"
            tool5.position = .init(x: 465, y: -130)
            tool5.size = CGSize(width: 70, height: 70)
            addChild(tool5)
            extendedToolList.append(tool5)
        }
    }
    
    
    /**
     Generate and draw the result labels in the canvas
     */
    func generateDiagramSelection() {
        let deflectionBg = SKShapeNode(rectOf: CGSize(width: 100, height: 80))
        deflectionBg.name = "DeflectionButton"
        deflectionBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        deflectionBg.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        deflectionBg.position = .init(x: -460, y: -330)
        addChild(deflectionBg)
        deflectionButton = deflectionBg
        
        let button1 = SKLabelNode(fontNamed: "DeflectionButton")
        button1.text = "Deflection"
        //button1.name = "DeflectionButton"
        button1.fontSize = 15
        button1.fontColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        button1.horizontalAlignmentMode = .right
        button1.position = .init(x: 35, y: -10)
        deflectionBg.addChild(button1)
        
        let bar1 = SKShapeNode(rect: CGRect(x: -35, y: 15, width: 70, height: 15), cornerRadius: 10)
        bar1.name = "Bar"
        bar1.lineWidth = 2
        bar1.strokeColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 0.5)
        bar1.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        deflectionBg.addChild(bar1)
        deflectionBar = bar1
        
        let shearBg = SKShapeNode(rectOf: CGSize(width: 100, height: 80))
        shearBg.name = "ShearButton"
        shearBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        shearBg.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        shearBg.position = .init(x: -355, y: -330)
        addChild(shearBg)
        shearButton = shearBg
        
        let button2 = SKLabelNode(fontNamed: "ShearButton")
        button2.text = "Shear"
        //button2.name = "ShearButton"
        button2.fontSize = 15
        button2.fontColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        button2.horizontalAlignmentMode = .right
        button2.position = .init(x: 20, y: -10)
        shearBg.addChild(button2)
        
        let bar2 = SKShapeNode(rect: CGRect(x: -35, y: 15, width: 70, height: 15), cornerRadius: 10)
        bar2.name = "Bar"
        bar2.lineWidth = 2
        bar2.strokeColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 0.5)
        bar2.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        shearBg.addChild(bar2)
        shearBar = bar2
        
        let bendingBg = SKShapeNode(rectOf: CGSize(width: 100, height: 80))
        bendingBg.name = "BendingButton"
        bendingBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        bendingBg.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        bendingBg.position = .init(x: -250, y: -330)
        addChild(bendingBg)
        bendingButton = bendingBg
        
        let button3 = SKLabelNode(fontNamed: "BendingButton")
        button3.text = "Bending"
        //button3.name = "BendingButton"
        button3.fontSize = 15
        button3.fontColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        button3.horizontalAlignmentMode = .right
        button3.position = .init(x: 28, y: -10)
        bendingBg.addChild(button3)
        
        let bar3 = SKShapeNode(rect: CGRect(x: -35, y: 15, width: 70, height: 15), cornerRadius: 10)
        bar3.name = "Bar"
        bar3.lineWidth = 2
        bar3.strokeColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 0.5)
        bar3.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        bendingBg.addChild(bar3)
        bendingBar = bar3
    }
    
    
    /**
     Activate the result labels when the button objects are clicked and selected by the user
     */
    func activateDiagramButton() {
        let unselectedLocationY = CGFloat(-330)
        let selectedLocationY = CGFloat(-320)
        
        let activateMove = SKAction.moveTo(y: selectedLocationY, duration: 0.5)
        activateMove.timingMode = SKActionTimingMode.easeInEaseOut // This line is optional
        
        let inactivateMove = SKAction.moveTo(y: unselectedLocationY, duration: 0.5)
        inactivateMove.timingMode = SKActionTimingMode.easeInEaseOut // This line is optional
        
        let inactiveColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        let inactiveLineColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 0.5)

        if selectedDeflection {
            deflectionButton.run(activateMove)
            deflectionBar.fillColor = UIColor(red: 54/255, green: 126/255, blue: 24/255, alpha: 0.7)
            deflectionBar.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            generateDeflection()
        }
        else if !selectedDeflection {
            deflectionButton.run(inactivateMove)
            deflectionBar.fillColor = inactiveColor
            deflectionBar.strokeColor = inactiveLineColor
            removeDeflection()
        }
        
        if selectedShear {
            shearButton.run(activateMove)
            shearBar.fillColor = .init(red: 0, green: 0, blue: 1, alpha: 0.7)
            shearBar.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            generateShearForceDiagram()
        }
        else if !selectedShear {
            shearButton.run(inactivateMove)
            shearBar.fillColor = inactiveColor
            shearBar.strokeColor = inactiveLineColor
            removeShearForceDiagram()
        }
        
        if selectedBending {
            bendingButton.run(activateMove)
            bendingBar.fillColor = .init(red: 1, green: 0, blue: 0, alpha: 0.7)
            bendingBar.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            generateBendingMomentDiagram()
            
        }
        else if !selectedBending {
            bendingButton.run(inactivateMove)
            bendingBar.fillColor = inactiveColor
            bendingBar.strokeColor = inactiveLineColor
            removeBendingMomentDiagram()
        }
    }
    
    
    /**
     Generate and draw the reset button object in the canvas
     */
    func generateResetButton() {
        let bg = SKShapeNode(rectOf: CGSize(width: 100, height: 60))
        bg.name = "ResetButton"
        bg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        bg.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        bg.position = .init(x: 465, y: -310)
        addChild(bg)
        
        let button = SKLabelNode(fontNamed: "ResetButton")
        button.text = "Reset"
        button.name = "ResetButton"
        button.fontSize = 15
        button.fontColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        button.horizontalAlignmentMode = .right
        button.position = .init(x: 485, y: -315)
        addChild(button)
    }
    
    
    /**
     Draw and display the left-hand side measurement distance of the point loading on the structure member
     */
    func generateMeasureDistance1(start: CGPoint, end: CGPoint, text: String) {
        for lineObject in measureDistance1LineList {
            lineObject.removeFromParent()
        }
        for labelObject in measureDistance1LabelList {
            labelObject.removeFromParent()
        }
        measureDistance1LineList = [SKShapeNode]()
        measureDistance1LabelList = [SKLabelNode]()
        
        let color = UIColor(red: 107/255, green: 102/255, blue: 114/255, alpha: 1)
        let fontSize = CGFloat(16)
        let length = calculateDistance(start: start, end: end)/2-30
        
        var locationAdjestment1 = CGFloat(1)
        if pointLoadMagnitude < 0 {
            locationAdjestment1 = CGFloat(-1.6)
        }
        
        var locationAdjestment2 = CGFloat(1)
        if pointLoadMagnitude < 0 {
            locationAdjestment2 = CGFloat(-2.4)
        }
        
        let line1 = SKShapeNode(rectOf: CGSize(width: length, height: 1))
        line1.fillColor = color
        line1.strokeColor = color
        let line1End: CGPoint = .init(x: start.x+(end.x-start.x)/2-30, y: startSupportLocation.y)
        let x1 = calculateCentreX(start: start, end: line1End)
        let y1 = start.y+20*locationAdjestment1
        line1.position = .init(x: x1, y: y1)
        addChild(line1)
        
        let distanceLabel = SKLabelNode(fontNamed: "PointLoadDistanceLabel")
        distanceLabel.text = "\(text) m"
        distanceLabel.fontSize = fontSize
        distanceLabel.fontColor = color
        distanceLabel.horizontalAlignmentMode = .right
        distanceLabel.position = .init(x: start.x+(end.x-start.x)/2+30, y: startSupportLocation.y+15*locationAdjestment2)
        addChild(distanceLabel)
        
        let line2 = SKShapeNode(rectOf: CGSize(width: length, height: 1))
        line2.fillColor = color
        line2.strokeColor = color
        let line2Start: CGPoint = .init(x: end.x-(end.x-start.x)/2+30, y: startSupportLocation.y)
        let x2 = calculateCentreX(start: line2Start, end: end)
        let y2 = start.y+20*locationAdjestment1
        line2.position = .init(x: x2, y: y2)
        addChild(line2)
        
        let line3 = SKShapeNode(rectOf: CGSize(width: 15, height: 1))
        line3.fillColor = color
        line3.strokeColor = color
        line3.position = .init(x: start.x+2, y: startSupportLocation.y+20*locationAdjestment1)
        let angle3 = CGFloat.pi/2
        line3.zRotation = angle3
        addChild(line3)
        
        let line4 = SKShapeNode(rectOf: CGSize(width: 15, height: 1))
        line4.fillColor = color
        line4.strokeColor = color
        line4.position = .init(x: end.x-2, y: startSupportLocation.y+20*locationAdjestment1)
        let angle4 = CGFloat.pi/2
        line4.zRotation = angle4
        addChild(line4)
        
        measureDistance1LineList.append(line1)
        measureDistance1LineList.append(line2)
        measureDistance1LineList.append(line3)
        measureDistance1LineList.append(line4)
        measureDistance1LabelList.append(distanceLabel)
    }
    
    
    /**
     Draw and display the right-hand side measurement distance of the point loading on the structure member
     */
    func generateMeasureDistance2(start: CGPoint, end: CGPoint, text: String) {
        for lineObject in measureDistance2LineList {
            lineObject.removeFromParent()
        }
        for labelObject in measureDistance2LabelList {
            labelObject.removeFromParent()
        }
        measureDistance2LineList = [SKShapeNode]()
        measureDistance2LabelList = [SKLabelNode]()
        
        let color = UIColor(red: 107/255, green: 102/255, blue: 114/255, alpha: 1)
        let fontSize = CGFloat(16)
        let length = calculateDistance(start: start, end: end)/2-30
        
        var locationAdjestment1 = CGFloat(1)
        if pointLoadMagnitude < 0 {
            locationAdjestment1 = CGFloat(-1.6)
        }
        
        var locationAdjestment2 = CGFloat(1)
        if pointLoadMagnitude < 0 {
            locationAdjestment2 = CGFloat(-2.4)
        }
        
        let line1 = SKShapeNode(rectOf: CGSize(width: length, height: 1))
        line1.fillColor = color
        line1.strokeColor = color
        let line1End: CGPoint = .init(x: start.x+(end.x-start.x)/2-30, y: startSupportLocation.y)
        let x1 = calculateCentreX(start: start, end: line1End)
        let y1 = end.y+20*locationAdjestment1
        line1.position = .init(x: x1, y: y1)
        addChild(line1)
        
        let distanceLabel = SKLabelNode(fontNamed: "PointLoadDistanceLabel")
        distanceLabel.text = "\(text) m"
        distanceLabel.fontSize = fontSize
        distanceLabel.fontColor = color
        distanceLabel.horizontalAlignmentMode = .right
        distanceLabel.position = .init(x: start.x+(end.x-start.x)/2+30, y: startSupportLocation.y+15*locationAdjestment2)
        addChild(distanceLabel)
        
        let line2 = SKShapeNode(rectOf: CGSize(width: length, height: 1))
        line2.fillColor = color
        line2.strokeColor = color
        let line2Start: CGPoint = .init(x: end.x-(end.x-start.x)/2+30, y: startSupportLocation.y)
        let x2 = calculateCentreX(start: line2Start, end: end)
        let y2 = end.y+20*locationAdjestment1
        line2.position = .init(x: x2, y: y2)
        addChild(line2)
        
        let line3 = SKShapeNode(rectOf: CGSize(width: 15, height: 1))
        line3.fillColor = color
        line3.strokeColor = color
        line3.position = .init(x: start.x+2, y: startSupportLocation.y+20*locationAdjestment1)
        let angle3 = CGFloat.pi/2
        line3.zRotation = angle3
        addChild(line3)
        
        let line4 = SKShapeNode(rectOf: CGSize(width: 15, height: 1))
        line4.fillColor = color
        line4.strokeColor = color
        line4.position = .init(x: end.x-2, y: startSupportLocation.y+20*locationAdjestment1)
        let angle4 = CGFloat.pi/2
        line4.zRotation = angle4
        addChild(line4)
        
        measureDistance1LineList.append(line1)
        measureDistance1LineList.append(line2)
        measureDistance1LineList.append(line3)
        measureDistance1LineList.append(line4)
        measureDistance1LabelList.append(distanceLabel)
    }
    
    
    /**
     Draw and display the measurement distance of the structure member
     */
    func generateMeasureDistance3(start: CGPoint, end: CGPoint, text: String) {
        for lineObject in measureDistance3LineList {
            lineObject.removeFromParent()
        }
        for labelObject in measureDistance3LabelList {
            labelObject.removeFromParent()
        }
        measureDistance3LineList = [SKShapeNode]()
        measureDistance3LabelList = [SKLabelNode]()
        
        let color = UIColor(red: 107/255, green: 102/255, blue: 114/255, alpha: 1)
        let fontSize = CGFloat(16)
        let length = calculateDistance(start: start, end: end)/2-30
        
        let line1 = SKShapeNode(rectOf: CGSize(width: length, height: 1))
        line1.fillColor = color
        line1.strokeColor = color
        let line1End: CGPoint = .init(x: start.x+(end.x-start.x)/2-30, y: startSupportLocation.y)
        let x1 = calculateCentreX(start: start, end: line1End)
        let y1 = start.y-50
        line1.position = .init(x: x1, y: y1)
        addChild(line1)
        
        let distanceLabel = SKLabelNode(fontNamed: "PointLoadDistanceLabel")
        distanceLabel.text = "\(text) m"
        distanceLabel.fontSize = fontSize
        distanceLabel.fontColor = color
        distanceLabel.horizontalAlignmentMode = .right
        distanceLabel.position = .init(x: start.x+(end.x-start.x)/2+30, y: start.y-55)
        addChild(distanceLabel)
        
        let line2 = SKShapeNode(rectOf: CGSize(width: length, height: 1))
        line2.fillColor = color
        line2.strokeColor = color
        let line2Start: CGPoint = .init(x: end.x-(end.x-start.x)/2+30, y: startSupportLocation.y)
        let x2 = calculateCentreX(start: line2Start, end: end)
        let y2 = start.y-50
        line2.position = .init(x: x2, y: y2)
        addChild(line2)
        
        let line3 = SKShapeNode(rectOf: CGSize(width: 15, height: 1))
        line3.fillColor = color
        line3.strokeColor = color
        line3.position = .init(x: start.x+2, y: start.y-50)
        let angle3 = CGFloat.pi/2
        line3.zRotation = angle3
        addChild(line3)
        
        let line4 = SKShapeNode(rectOf: CGSize(width: 15, height: 1))
        line4.fillColor = color
        line4.strokeColor = color
        line4.position = .init(x: end.x-2, y: start.y-50)
        let angle4 = CGFloat.pi/2
        line4.zRotation = angle4
        addChild(line4)
        
        measureDistance1LineList.append(line1)
        measureDistance1LineList.append(line2)
        measureDistance1LineList.append(line3)
        measureDistance1LineList.append(line4)
        measureDistance1LabelList.append(distanceLabel)
    }
    
    
    /**
     Generate and display the bending moment diagram
     */
    func generateBendingMomentDiagram() {
        
        currentCurve1.removeFromParent()
        currentCurve2.removeFromParent()
        currentMaxValue.removeFromParent()
        
        let results = calculatePointLoadDistance()
        let l = results.0
        let a = results.1
        let b = results.2
        var maxValue = pointLoadMagnitude*a*b/l
        maxValue = round(maxValue*100)/100
        
        var locationAdjestment1 = (pointLoadLocation.y-100-startSupportLocation.y)
        if pointLoadMagnitude < 0 {
            locationAdjestment1 = (pointLoadLocation.y+100-startSupportLocation.y)
        }
        
        maxBendingMomentLocation = .init(x: pointLoadObject.position.x, y: startSupportLocation.y+locationAdjestment1*maxValue/(pointLoadMagnitude*l/4))
        
        var locationAdjestment2 = maxBendingMomentLocation.y-30
        if pointLoadMagnitude < 0 {
            locationAdjestment2 = maxBendingMomentLocation.y+20
        }
        
        let maxValueLabel = SKLabelNode(fontNamed: "MaxValueLabel")
        maxValueLabel.text = "\(abs(maxValue)) kNm"
        maxValueLabel.fontSize = 20
        maxValueLabel.fontColor = .red
        maxValueLabel.horizontalAlignmentMode = .right
        maxValueLabel.position = .init(x: maxBendingMomentLocation.x+30, y: locationAdjestment2)
        addChild(maxValueLabel)
        currentMaxValue = maxValueLabel
        
        let length1 = calculateDistance(start: startSupportLocation, end: maxBendingMomentLocation)
        let curve1 = SKShapeNode(rectOf: CGSize(width: length1, height: 2))
        curve1.fillColor = .red
        curve1.strokeColor = .red
        let x1 = calculateCentreX(start: startSupportLocation, end: maxBendingMomentLocation)
        let y1 = calculateCentreY(start: startSupportLocation, end: maxBendingMomentLocation)
        curve1.position = .init(x: x1, y: y1)
        let angle1 = calculateAngle(start: startSupportLocation, end: maxBendingMomentLocation)
        curve1.zRotation = angle1
        addChild(curve1)
        currentCurve1 = curve1
        
        let length2 = calculateDistance(start: maxBendingMomentLocation, end: endSupportLocation)
        let curve2 = SKShapeNode(rectOf: CGSize(width: length2, height: 2))
        curve2.fillColor = .red
        curve2.strokeColor = .red
        let x2 = calculateCentreX(start: maxBendingMomentLocation, end: endSupportLocation)
        let y2 = calculateCentreY(start: maxBendingMomentLocation, end: endSupportLocation)
        curve2.position = .init(x: x2, y: y2)
        let angle2 = calculateAngle(start: maxBendingMomentLocation, end: endSupportLocation)
        curve2.zRotation = angle2
        addChild(curve2)
        currentCurve2 = curve2
    }
    
    
    /**
     Remove the bending moment diagram from the canvas
     */
    func removeBendingMomentDiagram() {
        currentCurve1.removeFromParent()
        currentCurve2.removeFromParent()
        currentMaxValue.removeFromParent()
    }
    
    
    /**
     Generate and display the shear force diagram
     */
    func generateShearForceDiagram() {
        
        let results = calculatePointLoadDistance()
        let l = results.0
        let a = results.1
        let b = results.2
        
        var leftReaction = pointLoadMagnitude*b/l
        var rightReaction = pointLoadMagnitude*a/l
        
        let path = CGMutablePath()
        var points = [CGPoint]()
        
        var locationAdjestment1 = CGFloat(100)
        if pointLoadMagnitude < 0 {
            locationAdjestment1 = CGFloat(-100)
        }
        
        let diagramLeftLocationY = startSupportLocation.y + locationAdjestment1*(leftReaction/pointLoadMagnitude)
        let diagramRightLocationY = endSupportLocation.y - locationAdjestment1*(rightReaction/pointLoadMagnitude)
        
        leftReaction = abs(round(leftReaction*100)/100)
        rightReaction = abs(round(rightReaction*100)/100)
        
        points.append(startSupportLocation)
        points.append(.init(x: startSupportLocation.x, y: diagramLeftLocationY))
        points.append(.init(x: pointLoadObject.position.x, y: diagramLeftLocationY))
        points.append(.init(x: pointLoadObject.position.x, y: diagramRightLocationY))
        points.append(.init(x: endSupportLocation.x, y: diagramRightLocationY))
        points.append(endSupportLocation)
        
        path.addLines(between: points)
        shearDiagram.path = path
        
        var locationAdjestment2Left = CGFloat(10)
        var locationAdjestment2Right = CGFloat(25)
        if pointLoadMagnitude < 0 {
            locationAdjestment2Left = CGFloat(-25)
            locationAdjestment2Right = CGFloat(-10)
        }
        
        leftValueLabel.text = "\(leftReaction) kN"
        leftValueLabel.position = .init(x: startSupportLocation.x, y: diagramLeftLocationY+locationAdjestment2Left)
        
        rightValueLabel.text = "\(rightReaction) kN"
        rightValueLabel.position = .init(x: endSupportLocation.x, y: diagramRightLocationY-locationAdjestment2Right)
        
        if generatedShear == false {
            shearDiagram.lineWidth = 5
            shearDiagram.strokeColor = .blue
            addChild(shearDiagram)
            generatedShear = true
            
            leftValueLabel.fontSize = 20
            leftValueLabel.fontColor = .blue
            leftValueLabel.horizontalAlignmentMode = .right
            addChild(leftValueLabel)
            
            rightValueLabel.fontSize = 20
            rightValueLabel.fontColor = .blue
            rightValueLabel.horizontalAlignmentMode = .right
            addChild(rightValueLabel)
        }
    }
    
    
    /**
     Remove the shear force diagram from the canvas
     */
    func removeShearForceDiagram() {
        shearDiagram.removeFromParent()
        generatedShear = false
        leftValueLabel.removeFromParent()
        rightValueLabel.removeFromParent()
    }
    
    
    /**
     Generate and display the deflected shape of the structure
     */
    func generateDeflection() {
        
        let results = calculatePointLoadDistance()
        let l = results.0
        let a = results.1
        let b = results.2
        let e = CGFloat(200000)
        
        var locationAdjestment1 = CGFloat(50)
        if pointLoadMagnitude < 0 {
            locationAdjestment1 = CGFloat(-50)
        }
        
        let constant = (3*l*e)
        var deflection = pointLoadMagnitude*pow(a, 2)*pow(b, 2)/constant
        let maxDeflection = pointLoadMagnitude*pow(l/2, 4)/constant
        let diagramLocationY = startSupportLocation.y-locationAdjestment1*(deflection/maxDeflection)
        
        let path = CGMutablePath()
        path.move(to: startSupportLocation)
        path.addQuadCurve(to: endSupportLocation, control: .init(x: pointLoadObject.position.x, y: diagramLocationY))
        
        deflectionDiagram.path = path
        
        var locationAdjestment2 = CGFloat(10)
        if pointLoadMagnitude < 0 {
            locationAdjestment2 = CGFloat(-10)
        }
        
        deflection = abs(round(deflection*1000*1000)/1000)
        deflectionValueLabel.text = "\(deflection) mm"
        deflectionValueLabel.position = .init(x: pointLoadObject.position.x+50, y: diagramLocationY-locationAdjestment2)
        
        var rotationLeft = pointLoadMagnitude*b*(l*l-b*b)/(6*l*e)
        rotationLeft = abs(round(rotationLeft*1000*1000)/1000)
        
        var rotationRight = pointLoadMagnitude*a*(l*l-a*a)/(6*l*e)
        rotationRight = abs(round(rotationRight*1000*1000)/1000)
        
        rotationLeftValueLabel.text = "\(rotationLeft)x10^-3 rad"
        rotationRightValueLabel.text = "\(rotationRight)x10^-3 rad"
        rotationLeftValueLabel.position = .init(x: startSupportLocation.x-10, y: startSupportLocation.y)
        rotationRightValueLabel.position = .init(x: endSupportLocation.x+155, y: endSupportLocation.y)
        
        if generatedDeflection == false {
            deflectionDiagram.lineWidth = 5
            deflectionDiagram.strokeColor = UIColor(red: 54/255, green: 126/255, blue: 24/255, alpha: 1)
            addChild(deflectionDiagram)
            generatedDeflection = true
            
            deflectionValueLabel.fontSize = 20
            deflectionValueLabel.fontColor = UIColor(red: 54/255, green: 126/255, blue: 24/255, alpha: 1)
            deflectionValueLabel.horizontalAlignmentMode = .right
            addChild(deflectionValueLabel)
            
            rotationLeftValueLabel.fontSize = 20
            rotationLeftValueLabel.fontColor = UIColor(red: 157/255, green: 116/255, blue: 208/255, alpha: 1)
            rotationLeftValueLabel.horizontalAlignmentMode = .right
            addChild(rotationLeftValueLabel)
            
            rotationRightValueLabel.fontSize = 20
            rotationRightValueLabel.fontColor = UIColor(red: 157/255, green: 116/255, blue: 208/255, alpha: 1)
            rotationRightValueLabel.horizontalAlignmentMode = .right
            addChild(rotationRightValueLabel)
        }
    }
    
    
    /**
     Remove the deflected shape of the structure from the canvas
     */
    func removeDeflection() {
        deflectionDiagram.removeFromParent()
        generatedDeflection = false
        deflectionValueLabel.removeFromParent()
        rotationLeftValueLabel.removeFromParent()
        rotationRightValueLabel.removeFromParent()
    }
    
    
    /**
     Execute when user starts touching on the canvas
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            startTouch = touch.location(in: self)
        }
        let touchedNodes = nodes(at: startTouch)
        
        for node in touchedNodes {
            
            if node.name == "FFF1" || node.name == "FFR1" || node.name == "RFR1" {
                let image = UIImage(named: node.name!)
                let texture = SKTexture(image: image!)
                let tool = SKSpriteNode(texture: texture)
                tool.name = node.name!
                tool.position = startTouch
                tool.size = CGSize(width: 100, height: 100)
                addChild(tool)
                extendedTool = tool
                extendedToolWithObject = true
            }
            
            if node.name == "Arrow" || node.name == "UDL" {
                let image = UIImage(named: node.name!)
                let texture = SKTexture(image: image!)
                let tool = SKSpriteNode(texture: texture)
                tool.name = node.name!
                tool.position = startTouch
                tool.size = CGSize(width: 100, height: 100)
                addChild(tool)
                extendedTool = tool
                extendedToolWithObject = true
            }
            
            if node.name == "MemberTool" {
                memberToolSelected = true
                supportToolSelected = false
                loadingToolSelected = false
                memberToolBg.strokeColor = UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0.8)
                supportToolBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
                loadingToolBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
                
            } else if node.name == "SupportTool" {
                supportToolSelected = true
                memberToolSelected = false
                loadingToolSelected = false
                memberToolBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
                supportToolBg.strokeColor = UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0.8)
                loadingToolBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
                
            } else if node.name == "LoadingTool" {
                loadingToolSelected = true
                memberToolSelected = false
                supportToolSelected = false
                memberToolBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
                supportToolBg.strokeColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
                loadingToolBg.strokeColor = UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0.8)
            }
            
            generateExtendedTool()
            
            if node.name == "ResetButton" {
                removeAllChildren()
                
                startTouch = CGPoint()
                moveTouch = CGPoint()
                endTouch = CGPoint()
                
                startSupportLocation = CGPoint()
                endSupportLocation = CGPoint()
                pointLoadLocation = CGPoint()
                
                selectedObject = false
                supportGenerated = false
                
                support1Generated = false
                support2Generated = false
                
                pointLoadGenerated = false
                pointLoadSelected = false
                pointLoadObject = SKSpriteNode()
                pointLoadLabel = SKLabelNode()
                pointLoadMagnitude = CGFloat(1)
                pointLoadMagnitudeIsChanging = false
                pointLoadMagnitudeChangingBox = SKShapeNode()
                
                maxBendingMomentLocation = CGPoint()
                currentCurve1 = SKShapeNode()
                currentCurve2 = SKShapeNode()
                currentMaxValue = SKLabelNode()
                bendingValueRatio = CGFloat()
                
                beamLength = CGFloat()
                
                measureDistance1LineList = [SKShapeNode]()
                measureDistance1LabelList = [SKLabelNode]()
                measureDistance2LineList = [SKShapeNode]()
                measureDistance2LabelList = [SKLabelNode]()
                measureDistance3LineList = [SKShapeNode]()
                measureDistance3LabelList = [SKLabelNode]()
                
                memberToolSelected = false
                supportToolSelected = false
                loadingToolSelected = false
                
                memberToolBg = SKShapeNode()
                supportToolBg = SKShapeNode()
                loadingToolBg = SKShapeNode()
                extendedToolList = [SKSpriteNode]()
                extendedTool = SKSpriteNode()
                extendedToolWithObject = false
                
                generateGridLine()
                generateResetButton()
                
                shearDiagram = SKShapeNode()
                generatedShear = false
                leftValueLabel = SKLabelNode(fontNamed: "LeftValueLabel")
                rightValueLabel = SKLabelNode(fontNamed: "RightValueLabel")
                
                deflectionDiagram = SKShapeNode()
                generatedDeflection = false
                deflectionValueLabel = SKLabelNode(fontNamed: "DeflectionValueLabel")
                rotationLeftValueLabel = SKLabelNode(fontNamed: "RotationLeftValueLabel")
                rotationRightValueLabel = SKLabelNode(fontNamed: "RotationRightValueLabel")
                
                selectedDeflection = true
                selectedShear = false
                selectedBending = false
                
                deflectionButton = SKShapeNode()
                shearButton = SKShapeNode()
                bendingButton = SKShapeNode()
                
                deflectionBar = SKShapeNode()
                shearBar = SKShapeNode()
                bendingBar = SKShapeNode()
                
                isDraggingActualSupport = false
                draggingSupport = SKNode()
                
                isGeneratingUDL = false
                selectedUDL = false
                UDL_Object = SKSpriteNode()
                UDLLoadLabelLeft = SKLabelNode()
                UDLLoadLabelRight = SKLabelNode()
                
                isDraggingLoading = false
                
                isReseting = true
            }
            
            if pointLoadGenerated == false {
                if node.name == "ActualSupport1" || node.name == "ActualSupport2" || node.name == "ExtraSupport" {
                    isDraggingActualSupport = true
                    draggingSupport = node
                }
            }
            else {
                if node.name == "PointLoad" {
                    pointLoadSelected = true
                }
                
                if node.name == "loadingUDL" {
                    selectedUDL = true
                }
                
                if node.name == "PointLoadMagnitudeLabel" {
                    pointLoadMagnitudeIsChanging = !pointLoadMagnitudeIsChanging
                    if pointLoadMagnitudeIsChanging {
                        pointLoadMagnitudeChangingBox.strokeColor = UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0.6)
                    }
                    else {
                        pointLoadMagnitudeChangingBox.strokeColor = UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0)
                    }
                }
                
                if node.name == "DeflectionButton" {
                    selectedDeflection = !selectedDeflection
                    activateDiagramButton()
                }
                else if node.name == "ShearButton" {
                    selectedShear = !selectedShear
                    activateDiagramButton()
                }
                else if node.name == "BendingButton" {
                    selectedBending = !selectedBending
                    activateDiagramButton()
                }
            }
        }
    }
    
    
    /**
     Execute when user starts moving on the canvas
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            moveTouch = touch.location(in: self)
        }
        
        if extendedToolWithObject {
            extendedTool.position = moveTouch
        }
        
        if isDraggingActualSupport {
            let distance = calculateDistance(start: startTouch, end: moveTouch)
            if distance > 50 {
                draggingSupport.position = moveTouch
                draggingSupport.setScale(2)
            }
        }
        
        if selectedObject == false && moveTouch.x < 415 && memberToolSelected {
            removeAllChildren()
            generateGridLine()
            generateResetButton()
            supportGenerated = false
            support1Generated = false
            support2Generated = false
            
            let horizontalMoveTouch: CGPoint = .init(x: moveTouch.x, y: startTouch.y)
            
            let length = calculateDistance(start: startTouch, end: horizontalMoveTouch)
            let beam = SKShapeNode(rectOf: CGSize(width: length, height: 2))
            beam.name = "Beam"
            beam.fillColor = .black
            beam.strokeColor = .black
            let x = calculateCentreX(start: startTouch, end: horizontalMoveTouch)
            let y = calculateCentreY(start: startTouch, end: horizontalMoveTouch)
            beam.position = .init(x: x, y: y)
            addChild(beam)
            
            beamLength = calculateRealDistance(distance: length)
            generateMeasureDistance3(start: startTouch, end: horizontalMoveTouch, text: "\(round(beamLength*100)/100)")
        }
        else {
            if pointLoadSelected {
                if abs(moveTouch.y-startTouch.y) > 100 && !pointLoadMagnitudeIsChanging {
                    isDraggingLoading = true
                    pointLoadObject.position = moveTouch
                    pointLoadLabel.removeFromParent()
                    pointLoadMagnitudeChangingBox.removeFromParent()
                }
                else {
                    if pointLoadMagnitudeIsChanging {
                        pointLoadMagnitude += (moveTouch.y - startTouch.y)/100
                    }
                    pointLoadLabel.text = "\(round(pointLoadMagnitude*100)/100) kN"
                    if pointLoadMagnitude < 0 {
                        pointLoadObject.zRotation = CGFloat.pi
                        pointLoadObject.position = .init(x: pointLoadObject.position.x, y: startSupportLocation.y-25)
                        pointLoadLabel.position = .init(x: pointLoadLabel.position.x, y: startSupportLocation.y-70)
                        pointLoadMagnitudeChangingBox.position = .init(x: pointLoadMagnitudeChangingBox.position.x, y: pointLoadLabel.position.y+10)
                    }
                    else {
                        pointLoadObject.zRotation = 0
                        pointLoadObject.position = .init(x: pointLoadObject.position.x, y: startSupportLocation.y+25)
                        pointLoadLabel.position = .init(x: pointLoadLabel.position.x, y: startSupportLocation.y+55)
                        pointLoadMagnitudeChangingBox.position = .init(x: pointLoadMagnitudeChangingBox.position.x, y: pointLoadLabel.position.y+10)
                    }
                    
                    if pointLoadMagnitudeIsChanging == false {
                        var pointLoadX = moveTouch.x
                        if pointLoadX < startSupportLocation.x {
                            pointLoadX = startSupportLocation.x
                        }
                        if pointLoadX > endSupportLocation.x {
                            pointLoadX = endSupportLocation.x
                        }
                        pointLoadObject.position = .init(x: pointLoadX, y: pointLoadObject.position.y)
                        pointLoadLabel.position = .init(x: pointLoadX+20, y: pointLoadLabel.position.y)
                        
                        pointLoadMagnitudeChangingBox.position = .init(x: pointLoadLabel.position.x-50, y: pointLoadMagnitudeChangingBox.position.y)
                        
                        maxBendingMomentLocation = .init(x: pointLoadX, y: pointLoadLocation.y-80)
                    }
                    
                    if selectedDeflection {
                        generateDeflection()
                    }
                    if selectedShear {
                        generateShearForceDiagram()
                    }
                    if selectedBending {
                        generateBendingMomentDiagram()
                    }
                    
                    let results = calculatePointLoadDistance()
                    let a = round(results.1*100)/100
                    let b = round(results.2*100)/100
                    generateMeasureDistance1(start: startSupportLocation, end: pointLoadObject.position, text: "\(a)")
                    generateMeasureDistance2(start: pointLoadObject.position, end: endSupportLocation, text: "\(b)")
                    //generateMeasureDistance3(start: startSupportLocation, end: endSupportLocation, text: "\(round(beamLength*100)/100)")
                }
            }
            
            if selectedUDL {
                if isGeneratingUDL {
                    let movingDistance = calculateDistance(start: startTouch, end: moveTouch)
                    UDL_Object.removeAllChildren()
                    
                    let imageExtendUDL = UIImage(named: "extendUDL")
                    let textureExtendUDL = SKTexture(image: imageExtendUDL!)
                    
                    let total = Int(round(movingDistance/27))
                    if total >= 1 {
                        for i in 1...total {
                            let extendUDL = SKSpriteNode(texture: textureExtendUDL)
                            extendUDL.position = .init(x: 27*i, y: 0)
                            extendUDL.size = CGSize(width: 70, height: 80)
                            UDL_Object.addChild(extendUDL)
                        }
                    }
                }
                else {
                    if abs(moveTouch.y-startTouch.y) > 100 {
                        isDraggingLoading = true
                        UDL_Object.position = moveTouch
                        UDLLoadLabelLeft.removeFromParent()
                        UDLLoadLabelRight.removeFromParent()
                    }
                    else {
                        // Not completed, just for demo purpose
                        UDL_Object.position = .init(x: moveTouch.x, y: UDL_Object.position.y)
                        UDLLoadLabelLeft.position = .init(x: UDL_Object.position.x+20, y: startSupportLocation.y+55)
                        let width = CGFloat(UDL_Object.children.count*27)
                        UDLLoadLabelRight.position = .init(x: UDL_Object.position.x+width+40, y: startSupportLocation.y+55)
                    }
                }
            }
        }
    }
    
    
    /**
     Execute when user ends touching on the canvas
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            endTouch = touch.location(in: self)
        }
        
        if pointLoadSelected {
            if isDraggingLoading {
                selectedObject = false
                pointLoadGenerated = false
                pointLoadMagnitude = CGFloat(1)
                pointLoadObject.physicsBody = SKPhysicsBody()
                pointLoadObject.physicsBody?.affectedByGravity = true
                pointLoadObject.physicsBody?.isDynamic = true
                isDraggingLoading = false
                
                selectedDeflection = false
                selectedShear = false
                selectedBending = false
                activateDiagramButton()
                
                selectedDeflection = true
                
                for lineObject in measureDistance1LineList {
                    lineObject.removeFromParent()
                }
                for labelObject in measureDistance1LabelList {
                    labelObject.removeFromParent()
                }
                
                for lineObject in measureDistance2LineList {
                    lineObject.removeFromParent()
                }
                for labelObject in measureDistance2LabelList {
                    labelObject.removeFromParent()
                }
                
                generateMeasureDistance3(start: startSupportLocation, end: endSupportLocation, text: "\(round(beamLength*100)/100)")
            }
            pointLoadSelected = false
        }
        
        if selectedUDL {
            if isGeneratingUDL {
                isGeneratingUDL = false
                
                UDLLoadLabelLeft = SKLabelNode(fontNamed: "UDLLoadLabelLeft")
                UDLLoadLabelLeft.name = "UDLMagnitudeLabelLeft"
                UDLLoadLabelLeft.text = "1 kN/m"
                UDLLoadLabelLeft.fontSize = 20
                UDLLoadLabelLeft.fontColor = .red
                UDLLoadLabelLeft.horizontalAlignmentMode = .right
                UDLLoadLabelLeft.position = .init(x: UDL_Object.position.x+20, y: startSupportLocation.y+55)
                addChild(UDLLoadLabelLeft)
                
                UDLLoadLabelRight = SKLabelNode(fontNamed: "UDLLoadLabelRight")
                UDLLoadLabelRight.name = "UDLMagnitudeLabelRight"
                UDLLoadLabelRight.text = "1 kN/m"
                UDLLoadLabelRight.fontSize = 20
                UDLLoadLabelRight.fontColor = .red
                UDLLoadLabelRight.horizontalAlignmentMode = .right
                
                let width = CGFloat(UDL_Object.children.count*27)
                UDLLoadLabelRight.position = .init(x: UDL_Object.position.x+width+40, y: startSupportLocation.y+55)
                addChild(UDLLoadLabelRight)
            }
            
            if isDraggingLoading {
                selectedObject = false
                pointLoadGenerated = false
                UDL_Object.physicsBody = SKPhysicsBody()
                UDL_Object.physicsBody?.affectedByGravity = true
                UDL_Object.physicsBody?.isDynamic = true
                isDraggingLoading = false
            }
            selectedUDL = false
        }
        
        if isDraggingActualSupport {
            draggingSupport.physicsBody = SKPhysicsBody()
            draggingSupport.physicsBody?.affectedByGravity = true
            draggingSupport.physicsBody?.isDynamic = true
            if draggingSupport.name == "ActualSupport1" {
                support1Generated = false
            }
            else if draggingSupport.name == "ActualSupport2" {
                support2Generated = false
            }
            isDraggingActualSupport = false
        }
        
        if extendedToolWithObject {
            if extendedTool.name == "FFF1" || extendedTool.name == "FFR1" || extendedTool.name == "RFR1" {
                if endTouch.x >= startSupportLocation.x-50 && endTouch.x <= startSupportLocation.x+50 && endTouch.y >= startSupportLocation.y-50 && endTouch.y <= startSupportLocation.y+50 && support1Generated == false {
                    let image1 = UIImage(named: extendedTool.name!)
                    let texture1 = SKTexture(image: image1!)
                    let support1 = SKSpriteNode(texture: texture1)
                    support1.position = .init(x: startSupportLocation.x, y: startSupportLocation.y-15)
                    support1.size = CGSize(width: 50, height: 50)
                    if extendedTool.name == "FFF1" {
                        support1.zRotation = -CGFloat.pi/2
                        support1.position = .init(x: startSupportLocation.x, y: startSupportLocation.y)
                    }
                    support1.name = "ActualSupport1"
                    addChild(support1)
                    support1Generated = true
                }
                
                if endTouch.x >= endSupportLocation.x-50 && endTouch.x <= endSupportLocation.x+50 && endTouch.y >= endSupportLocation.y-50 && endTouch.y <= endSupportLocation.y+50 && support2Generated == false {
                    let image2 = UIImage(named: extendedTool.name!)
                    let texture2 = SKTexture(image: image2!)
                    let support2 = SKSpriteNode(texture: texture2)
                    support2.position = .init(x: endSupportLocation.x, y: endSupportLocation.y-15)
                    support2.size = CGSize(width: 50, height: 50)
                    if extendedTool.name == "FFF1" {
                        support2.zRotation = CGFloat.pi/2
                        support2.position = .init(x: endSupportLocation.x, y: endSupportLocation.y)
                    }
                    support2.name = "ActualSupport2"
                    addChild(support2)
                    support2Generated = true
                }
                
                if endTouch.x < endSupportLocation.x-100 && endTouch.x > startSupportLocation.x+100 && endTouch.y >= endSupportLocation.y-35 && endTouch.y <= endSupportLocation.y+35 && pointLoadGenerated == false {
                    let image3 = UIImage(named: extendedTool.name!)
                    let texture3 = SKTexture(image: image3!)
                    let support3 = SKSpriteNode(texture: texture3)
                    support3.position = .init(x: endTouch.x, y: endSupportLocation.y-15)
                    support3.size = CGSize(width: 50, height: 50)
                    support3.name = "ExtraSupport"
                    addChild(support3)
                }
            }
            
            if extendedTool.name == "Arrow" || extendedTool.name == "UDL" {
                if support1Generated && support2Generated && endTouch.x >= startSupportLocation.x && endTouch.x <= endSupportLocation.x && endTouch.y >= startSupportLocation.y-50 && endTouch.y <= startSupportLocation.y+50 && pointLoadGenerated == false {
                    if extendedTool.name == "Arrow" {
                        selectedObject = true
                        pointLoadLocation = endTouch
                        let imagePointLoad = UIImage(named: extendedTool.name!)
                        let texturePointLoad = SKTexture(image: imagePointLoad!)
                        let pointLoad = SKSpriteNode(texture: texturePointLoad)
                        pointLoad.position = .init(x: pointLoadLocation.x, y: startSupportLocation.y+25)
                        pointLoad.size = CGSize(width: 70, height: 80)
                        pointLoad.name = "PointLoad"
                        addChild(pointLoad)
                        pointLoadObject = pointLoad
                        pointLoadGenerated = true
                        
                        pointLoadLabel = SKLabelNode(fontNamed: "PointLoadLabel")
                        pointLoadLabel.name = "PointLoadMagnitudeLabel"
                        pointLoadLabel.text = "\(pointLoadMagnitude) kN"
                        pointLoadLabel.fontSize = 20
                        pointLoadLabel.fontColor = .red
                        pointLoadLabel.horizontalAlignmentMode = .right
                        pointLoadLabel.position = .init(x: pointLoadLocation.x+20, y: startSupportLocation.y+55)
                        addChild(pointLoadLabel)
                        
                        pointLoadMagnitudeChangingBox = SKShapeNode(rectOf: CGSize(width: 110, height: 25))
                        pointLoadMagnitudeChangingBox.lineWidth = 3
                        pointLoadMagnitudeChangingBox.strokeColor = UIColor(red: 63/255, green: 32/255, blue: 200/255, alpha: 0)
                        pointLoadMagnitudeChangingBox.position = .init(x: pointLoadLabel.position.x-50, y: pointLoadLabel.position.y+10)
                        addChild(pointLoadMagnitudeChangingBox)
                        
                        if selectedDeflection {
                            generateDeflection()
                            activateDiagramButton()
                        }
                        if selectedShear {
                            generateShearForceDiagram()
                        }
                        if selectedBending {
                            generateBendingMomentDiagram()
                        }
                        
                        let results = calculatePointLoadDistance()
                        let a = round(results.1*100)/100
                        let b = round(results.2*100)/100
                        generateMeasureDistance1(start: startSupportLocation, end: pointLoadLocation, text: "\(a)")
                        generateMeasureDistance2(start: pointLoadLocation, end: endSupportLocation, text: "\(b)")
                        //generateMeasureDistance3(start: startSupportLocation, end: endSupportLocation, text: "\(round(beamLength*100)/100)")
                    }
                    else if extendedTool.name == "UDL" {
                        selectedObject = true
                        pointLoadLocation = endTouch
                        
                        let imageUDL = UIImage(named: "Arrow")
                        let textureUDL = SKTexture(image: imageUDL!)
                        let UDL = SKSpriteNode(texture: textureUDL)
                        UDL.position = .init(x: pointLoadLocation.x, y: startSupportLocation.y+25)
                        UDL.size = CGSize(width: 70, height: 80)
                        UDL.name = "loadingUDL"
                        addChild(UDL)
                        UDL_Object = UDL
                        pointLoadGenerated = true
                        
                        isGeneratingUDL = true
//                        let imageExtendUDL = UIImage(named: "extendUDL")
//                        let textureExtendUDL = SKTexture(image: imageExtendUDL!)
//                        for i in 1...10 {
//                            let extendUDL = SKSpriteNode(texture: textureExtendUDL)
//                            extendUDL.position = .init(x: 27*i, y: 0)
//                            extendUDL.size = CGSize(width: 70, height: 80)
//                            UDL.addChild(extendUDL)
//                        }
                    }
                }
            }
            extendedTool.removeFromParent()
            extendedTool = SKSpriteNode()
            extendedToolWithObject = false
        }
        
        if selectedObject == false && supportGenerated == false && isReseting == false && endTouch.x < 415 && memberToolSelected {
            let startNode = SKShapeNode(circleOfRadius: 5)
            startNode.strokeColor = .brown
            startNode.name = "StartNode"
            let endNode = SKShapeNode(circleOfRadius: 5)
            endNode.strokeColor = .brown
            endNode.name = "EndNode"
            startNode.position = startTouch
            startSupportLocation = startTouch
            
            let horizontalEndTouch: CGPoint = .init(x: endTouch.x, y: startTouch.y)
            
            endNode.position = horizontalEndTouch
            endSupportLocation = horizontalEndTouch
            addChild(startNode)
            addChild(endNode)
            supportGenerated = true
        }
        if isReseting {
            isReseting = false
        }
    }
    
    
    /**
     Execute when user cancels touching on the canvas
     */
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    /**
     Is called exactly once per frame before any actions are evaluated and any physics are simulated
     */
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
