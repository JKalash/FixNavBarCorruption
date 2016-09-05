extension UIViewController {
    func fixNavigationBarCorruption() {
        if let coordinator = self.transitionCoordinator {
            if coordinator.initiallyInteractive {
                let mapTable = NSMapTable(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableStrongMemory, capacity: 0)
                coordinator.notifyWhenInteractionEnds({ (context) -> Void in
                    if let n = self.navigationController {
                        for view in n.navigationBar.subviews {
                            if let animationKeys = view.layer.animationKeys() {
                                let anims = NSMutableArray()
                                for animationKey in animationKeys {
                                    if let anim = view.layer.animation(forKey: animationKey) {
                                        if anim.isKind(of: CABasicAnimation.classForCoder()) {
                                            let animCopy = CABasicAnimation(keyPath: (anim as! CABasicAnimation).keyPath)
                                            // Make sure fromValue and toValue are the same, and that they are equal to the layer's final resting value
                                            animCopy.fromValue = view.layer.value(forKeyPath: (anim as! CABasicAnimation).keyPath!)
                                            animCopy.toValue = view.layer.value(forKeyPath: (anim as! CABasicAnimation).keyPath!)
                                            animCopy.byValue = (anim as! CABasicAnimation).byValue
                                            // CAPropertyAnimation properties
                                            animCopy.isAdditive = (anim as! CABasicAnimation).isAdditive
                                            animCopy.isCumulative = (anim as! CABasicAnimation).isCumulative
                                            animCopy.valueFunction = (anim as! CABasicAnimation).valueFunction
                                            // CAAnimation properties
                                            animCopy.timingFunction = anim.timingFunction
                                            animCopy.delegate = anim.delegate
                                            animCopy.isRemovedOnCompletion = anim.isRemovedOnCompletion
                                            // CAMediaTiming properties
                                            animCopy.speed = anim.speed
                                            animCopy.repeatCount = anim.repeatCount
                                            animCopy.repeatDuration = anim.repeatDuration
                                            animCopy.autoreverses = anim.autoreverses
                                            animCopy.fillMode = anim.fillMode
                                            // We want our new animations to be instantaneous, so set the duration to zero.
                                            // Also set both the begin time and time offset to 0.
                                            animCopy.duration = 0
                                            animCopy.beginTime = 0
                                            animCopy.timeOffset = 0
                                            anims.add(animCopy)
                                        }
                                    }
                                }
                                mapTable.setObject(anims, forKey: view)
                            }
                        }
                    }
                })
                coordinator.animate(alongsideTransition: nil, completion: { (context) -> Void in
                    for view in mapTable.keyEnumerator() {
                        if let v = view as? UIView {
                            if let anims = mapTable.object(forKey: v) as? [CABasicAnimation] {
                                for anim in anims {
                                    v.layer.add(anim, forKey: anim.keyPath)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}