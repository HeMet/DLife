//
//  ViewModel.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 17.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import ReactiveCocoa
import MVVMKit

class BaseViewModel : ViewModel {
    static let inactiveThrottleInterval: NSTimeInterval = 1
    
    var active = MutableProperty<Bool>(false)
    
    lazy var didBecomeActiveSignal: SignalProducer<ViewModel, NoError> = {
        return self.active.producer.filter { $0 }.map { _ in self as ViewModel }
    }()
    
    lazy var didBecomeInactiveSignal: SignalProducer<ViewModel, NoError> = {
        return self.active.producer.filter { !$0 }.map { _ in self as ViewModel }
    }()
    
    func forwardSignalWhileActive<T, E>(signal: SignalProducer<T, E>) -> SignalProducer<T, E> {
        return signal.forwardWhile(self.active.producer)
    }
    
    func throttleSignalWhileInactive<T, E>(signal: SignalProducer<T, E>) -> SignalProducer<T, E> {
        return signal.throttle(1, onScheduler: QueueScheduler(), passingTest: { _ in !self.active.value })
    }
    
    var onDisposed: ViewModelEventHandler?
    
    func dispose() {
        onDisposed?(self)
    }
}