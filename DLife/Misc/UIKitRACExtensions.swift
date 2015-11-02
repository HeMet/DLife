//
//  UIKitRACExtensions.swift
//  DLife
//
//  Created by Евгений Губин on 05.09.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension UIView {
    private struct AssociatedKeys {
        static var rac_alpha: UInt = 0
    }
    
    var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(&AssociatedKeys.rac_alpha, setter: { self.alpha = $0 }, getter: { self.alpha })
    }
}

extension UISegmentedControl {
    private struct AssociatedKeys {
        static var rac_selectedSegmentIndex: UInt = 1
    }
    
    var rac_selectedSegmentIndex: MutableProperty<Int> {
        return lazyAssociatedProperty(&AssociatedKeys.rac_selectedSegmentIndex) {
            self.addTarget(self, action: "rac_ValueChanged", forControlEvents: .ValueChanged)
            
            let property = MutableProperty<Int>(self.selectedSegmentIndex)
            property.producer.startWithNext {
                self.selectedSegmentIndex = $0
            }
            
            return property
        }
    }
    
    func rac_ValueChanged() {
        rac_selectedSegmentIndex.value = self.selectedSegmentIndex
    }
}

extension UITextField {
    private struct AssociatedKeys {
        static var rac_text: UInt = 2
        static var rac_editingDidEnd = 3
    }
    
    var rac_text: MutableProperty<String?> {
        return lazyAssociatedProperty(&AssociatedKeys.rac_text) {
            self.addTarget(self, action: "rac_AllEditingEvents", forControlEvents: .AllEditingEvents)
            
            let property = MutableProperty<String?>(self.text)
            property.producer.startWithNext { [unowned self] in
                self.text = $0
            }
            
            return property
        }
    }
    
    var rac_editingDidEnd: MutableProperty<UITextField> {
        return lazyAssociatedProperty(&AssociatedKeys.rac_editingDidEnd) {
            self.addTarget(self, action: "rac_onEditingDidEnd", forControlEvents: [.EditingDidEnd, .EditingDidEndOnExit])
            
            let property = MutableProperty<UITextField>(self)
            
            return property
        }
    }
    
    func rac_AllEditingEvents() {
        rac_text.value = self.text
    }
    
    func rac_onEditingDidEnd() {
        rac_editingDidEnd.value = self
    }
}

class Box<T> {
    let value: T
    init(_ value: T) {
        self.value = value
    }
}


extension NSObject {
    func lazyAssociatedProperty<T: AnyObject>(key: UnsafePointer<Void>, factory: () -> T) -> T {
        var associatedProperty = objc_getAssociatedObject(self, key) as? T
        
        if associatedProperty == nil {
            associatedProperty = factory()
            objc_setAssociatedObject(self, key, associatedProperty, .OBJC_ASSOCIATION_RETAIN)
        }
        
        return associatedProperty!
    }
    
    func lazyMutableProperty<T>(key: UnsafePointer<Void>, setter: T -> (), getter: () -> T) -> MutableProperty<T> {
        return lazyAssociatedProperty(key) {
            let property = MutableProperty<T>(getter())
            property.producer.startWithNext(setter)
            return property
        }
    }
}

extension MutableProperty {
    public convenience init(_ initialValue: T, onChanges: T -> ()) {
        self.init(initialValue)
        producer.startWithNext(onChanges)
    }
    
    func didSet(handler: T -> ()) {
        producer.startWithNext(handler)
    }
}