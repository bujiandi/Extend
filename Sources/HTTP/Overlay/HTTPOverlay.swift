//
//  HTTPOverlay.swift
//  Basic
//
//  Created by 李招利 on 2018/10/29.
//

import Foundation

public protocol HTTPOverlay : class {
    
    func startNetOverlay()
    func stopNetOverlay()
    func progressPercentChanged(_ percent:Double)
    
}

public protocol HTTPFailureRetryOverlay : class {
    
    func showRetryOverlay(_ resumeWork:Resumable, _ message:String)
    
}

extension HTTP {
    
    final class WeakOverlay {
        weak var overlay:HTTPOverlay?
        
        init(_ overlay:HTTPOverlay) {
            self.overlay = overlay
        }
    }
    
}
