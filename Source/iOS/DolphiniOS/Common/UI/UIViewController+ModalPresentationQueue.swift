// Copyright (c) 2016 nestor-huma, updated by tr1ckyf0x
// https://github.com/tr1ckyf0x/ModalPresentationQueue

import UIKit


/** Associated keys for stored properties */
private struct AssociatedKeys {
    static var PresentationQueueName = "np_PresentationQueueName"
    static var DismissCompletion = "np_DismissCompletion"
}

@objc public extension UIViewController {
    /**
     Simple block which takes no parameters and returns nothing.
     */
    typealias Action = () -> Void
    
    /**
     Adds view controller to the presentation queue.
     New view controller will be presented immediately if the queue is empty or right after the last added view controller will be dismissed.
     */
    @objc func addViewControllerToPresentationQueue(viewControllerToPresent: UIViewController, animated: Bool = true, completion: Action? = nil) {
        
        // Create new block operation
        let newOperation = BlockOperation {
            let semaphore = DispatchSemaphore(value: 0)
            
            // Set view controller's dismissal completion in order to get notified when it will be dismissed
            viewControllerToPresent.dismissCompletion = {
                semaphore.signal()
            }
            
            // Present view controller in main queue
            OperationQueue.main.addOperation {
                self.present(viewControllerToPresent, animated: animated, completion: completion)
            }
            
            // Wait until view controller will be dismissed
            _ = semaphore.wait(timeout: .distantFuture)
        }
        newOperation.queuePriority = .veryHigh
        
        // Make sure that new operation won't start until all previous operations will finish
        if let lastOperation = presentationQueue.operations.last {
            newOperation.addDependency(lastOperation)
        }
        
        
        // Add the new operation to the queue
        presentationQueue.addOperation(newOperation)
    }
    
    /** Removes all view controllers which were not yet presented from presentation queue */
    @objc func emptyPresentationQueue() {
        presentationQueue.cancelAllOperations()
    }
    
    /**
     Queue of view controllers.
     */
    private var presentationQueue: OperationQueue {
        struct Static {
            static let presentationQueue = OperationQueue()
        }
        return Static.presentationQueue
    }
    
}

@objc public extension UIViewController {
    /**
     This block is called after the view controller becomes dismissed.
     */
    private var dismissCompletion: Action? {
        get {
            return dismissCompletionWrapper?.action
        }
        set {
            dismissCompletionWrapper = ActionWrapper(action: newValue)
        }
    }
    
    /**
     Class used to wrap block.
     Is needed because you can only associate with objects which are kind of AnyObject.
     */
    private class ActionWrapper {
        var action: Action?
        init(action: Action?) {
            self.action = action
        }
    }
    
    /**
     Wrapped dismiss completion.
     */
    @nonobjc private var dismissCompletionWrapper: ActionWrapper? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DismissCompletion) as? ActionWrapper
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.DismissCompletion, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    // MARK: method swizzling
    @objc static func swizzleViewDidDisappear() {
        //Make sure This isn't a subclass of UIViewController, So that It applies to all UIViewController childs
            if self != UIViewController.self {
                return
            }
            let originalSelector = #selector(UIViewController.viewDidDisappear(_:))
            let swizzledSelector = #selector(UIViewController.np_viewDidDisappear(_:))
            guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
            method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    /**
     Swizzled viewWillDisappear.
     */
    @objc private func np_viewDidDisappear(_ animated: Bool) {
        self.np_viewDidDisappear(animated)
        if isBeingDismissed {
            dismissCompletion?()
        }
    }
}
