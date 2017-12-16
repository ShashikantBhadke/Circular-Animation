//
//  Circular_Animation.swift
//  CircularAnimation
//
//  Created by Trupti Karale on 15/12/17.
//  Copyright © 2017 Ankita Chordia. All rights reserved.
//

import Foundation
import UIKit
class Circular_Animation:NSObject, URLSessionDownloadDelegate{
    
    
    static let circleAnimation = Circular_Animation()
    
    var shapeLayer = CAShapeLayer()
    var pulsatingLayer: CAShapeLayer!
    
    let percentageLable: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    //MARK:- Create Label
    func addPercantageLabel(viewController:UIViewController){
        viewController.view.addSubview(percentageLable)
        percentageLable.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        percentageLable.center = viewController.view.center
    }
    //MARK:- Draw Circle
    func drawCircle(viewController:UIViewController){
        
        setUpNotificationObserver(viewController: viewController)
        
        viewController.view.backgroundColor = UIColor.backgroundColor
        
        addPercantageLabel(viewController: viewController)
        
        setupCircleLayer(viewController: viewController)
        
        let trackLayer = createShapeLayer(viewController: viewController, strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        viewController.view.layer.addSublayer(trackLayer)
        
        shapeLayer = createShapeLayer(viewController: viewController, strokeColor: .outlineStrokeColor, fillColor: .clear)
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        viewController.view.layer.addSublayer(shapeLayer)
        
    viewController.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTab)))
    }
    //Setup Outer Layer
    func setupCircleLayer(viewController:UIViewController){
            pulsatingLayer = createShapeLayer(viewController: viewController, strokeColor: .clear, fillColor: UIColor.pulsatingFillColor)
        viewController.view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
    }
    
    //Setup Outer Layer Animation
    func animatePulsatingLayer(){
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.5
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    
    //MARK:- Download File
    private func beginDownloadFile(){
        let urlString = "https://www.planwallpaper.com/static/images/6768666-1080p-wallpapers.jpg"//"https://firebasestorage.googleapis.com/v0/b/firestorechat-e64ac.appspot.com/o/intermediate_training_rec.mp4?alt=media&token=e20261d0-7219-49d2-b32d-367e1606500c"
        Circular_Animation.circleAnimation.shapeLayer.strokeEnd = 0
        let config = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
        
        guard let url = URL(string: urlString) else { return }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.shapeLayer.strokeEnd = percentage
            self.percentageLable.text = "\(Int(percentage * 100))%"
            
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading file")
    }
    //MARK:- Create Shape Layer
    func createShapeLayer(viewController: UIViewController, strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer{
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = kCALineCapRound
        layer.position = viewController.view.center
        return layer
    }
    
    //MARK:- Handle Tab gesture
    @objc func handleTab(){
        shapeLayer.strokeEnd = 0
        let basicAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        beginDownloadFile()
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    //MARK:- SetUP notification
    func setUpNotificationObserver(viewController: UIViewController){
        NotificationCenter.default.addObserver(viewController, selector: #selector(handleEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
    }
    @objc func handleEnterForeground(){
        animatePulsatingLayer()
    }
}


extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let backgroundColor = UIColor.rgb(r: 21, g: 22, b: 33)
    static let outlineStrokeColor = UIColor.rgb(r: 234, g: 46, b: 111)
    static let trackStrokeColor = UIColor.rgb(r: 56, g: 25, b: 49)
    static let pulsatingFillColor = UIColor.rgb(r: 86, g: 30, b: 63)
}
