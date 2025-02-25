//
//  FPS.swift
//  Pods
//
//  Created by zixun on 16/12/26.
//
//

import Foundation
//import UIKit

@objc public protocol FPSDelegate: AnyObject {
    @objc optional func fps(fps:FPS, currentFPS:Double)
}

open class FPS: NSObject {
    
    open var isEnable: Bool = true
    
    open var updateInterval: Double = 1.0
    
    open weak var delegate: FPSDelegate?
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FPS.applicationWillResignActiveNotification),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FPS.applicationDidBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    open func open() {
        guard self.isEnable == true else {
            return
        }
        self.displayLink.isPaused = false
    }
    
    open func close() {
        guard self.isEnable == true else {
            return
        }
        
        self.displayLink.isPaused = true
    }
    
    
    @objc private func applicationWillResignActiveNotification() {
        guard self.isEnable == true else {
            return
        }
        
        self.displayLink.isPaused = true
    }
    
    @objc private func applicationDidBecomeActiveNotification() {
        guard self.isEnable == true else {
            return
        }
        self.displayLink.isPaused = false
    }
    
    @objc private func displayLinkHandler() {
        self.count += self.displayLink.frameInterval
        let interval = self.displayLink.timestamp - self.lastTime
        
        guard interval >= self.updateInterval else {
            return
        }
        
        self.lastTime = self.displayLink.timestamp
        let fps = Double(self.count) / interval
        self.count = 0
       
        self.delegate?.fps?(fps: self, currentFPS: round(fps))
        
    }
    
    private lazy var displayLink:CADisplayLink = { [unowned self] in
        let new = CADisplayLink(target: self, selector: #selector(FPS.displayLinkHandler))
        new.isPaused = true
        new.add(to: RunLoop.main, forMode: .common)
        return new
    }()
    
    private var count:Int = 0
    
    private var lastTime: CFTimeInterval = 0.0
}
