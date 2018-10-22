//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by Руслан Акберов on 16/10/2018.
//  Copyright © 2018 Ruslan Akberov. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        startExamples()
        subjectsExamples()
    }
    
    func startExamples() {
        example("just") {
            // Observable
            let observable = Observable.just("Hello, RxSwift!")
            
            // Obsever
            observable.subscribe({ (event) in
                print(event)
//                next(Hello, RxSwift!), completed
            })
        }
        
        example("of") {
            let observable = Observable.of(1, 2, 3, 4, 5)
            observable.subscribe { print($0) } // shortcut
//            next(1)
//            next(2)
//            next(3)
//            next(4)
//            next(5)
//            completed
        }
        
        example("create") {
            let items = [1, 2, 3, 4, 5]
            Observable.from(items).subscribe(onNext: { (event) in
                print(event)
            }, onError: { (error) in
                print("Error")
            }, onCompleted: {
                print("Done")
            }, onDisposed: {
                print("Disposed")
            })
//            1
//            2
//            3
//            4
//            5
//            Done
//            Disposed
        }
        
        example("disposable") {
            let sequence = [1, 2, 3]
            Observable.from(sequence).subscribe({ (event) in
                print(event)
            })
            Disposables.create()
//            next(1)
//            next(2)
//            next(3)
//            completed
        }
        
        example("dispose") {
            let sequence = [1, 2, 3]
            Observable.from(sequence).subscribe({ (event) in
                print(event)
            }).dispose() // bad practice
//            next(1)
//            next(2)
//            next(3)
//            completed
        }
        
        example("disposeBag") {
            let sequence = [1, 2, 3]
            let disposeBag = DisposeBag()
            Observable.from(sequence).subscribe({ (event) in
                print(event)
            }).disposed(by: disposeBag) // correct way to deallocate memory
//            next(1)
//            next(2)
//            next(3)
//            completed
        }
        
        example("takeUntil") {
            let stopSeq = Observable.just(1).delaySubscription(5, scheduler: MainScheduler.instance)
            let seq = Observable.from([1, 2, 3]).takeUntil(stopSeq)
            seq.subscribe { print($0) }
//            next(1)
//            next(2)
//            next(3)
//            completed
        }
        
        /// OPERATORS
        
        example("filter") {
            let seq = Observable.of(1, 2, 7, 11, 3, 21).filter { $0 > 10 }
            seq.subscribe { print($0) }
//            next(11)
//            next(21)
//            completed
        }
        
        example("map") {
            let seq = Observable.of(1, 2 ,3).map { $0 * $0 }
            seq.subscribe { print($0) }
        }
//        next(1)
//        next(4)
//        next(9)
//        completed

        example("merge") {
            let firstSeq = Observable.of(1, 2, 3)
            let secondSeq = Observable.of(10, 20, 30)
            let bothSeq = Observable.of(firstSeq, secondSeq).merge()
            bothSeq.subscribe { print($0) }
//            next(1)
//            next(2)
//            next(10)
//            next(3)
//            next(20)
//            next(30)
//            completed
        }
        
    }
    
    func subjectsExamples() {
        
        // Represents an object that is both an observable sequence as well as an observer.
        example("Publish Subject") {
            let disposableBag = DisposeBag()
            let subject = PublishSubject<String>()
            
            subject.subscribe { print("Subscription first:", $0) }.disposed(by: disposableBag)
            subject.on(.next("Hello"))
            subject.onNext("RxSwift")
            
            subject.subscribe(onNext: {print("Subscription second:", $0)}).disposed(by: disposableBag)
            subject.onNext("Wow")
            subject.onNext("How are you?")
            
            subject.onCompleted() // or error end sequence
            subject.onNext("I am here")
            
//            Subscription first: next(Hello)
//            Subscription first: next(RxSwift)
//            Subscription first: next(Wow)
//            Subscription second: Wow
//            Subscription first: next(How are you?)
//            Subscription second: How are you?
        }
        
        // Represents a value that changes over time.
        example("Behavior Subject") {
            let disposableBag = DisposeBag()
            let subject = BehaviorSubject(value: 1)
            
            subject.subscribe(onNext: {print(#line, $0)}).disposed(by: disposableBag)
            subject.onNext(2)
            subject.onNext(3)
            
            subject.subscribe(onNext: {print(#line, $0)}).disposed(by: disposableBag)
//            173 1
//            173 2
//            173 3
//            177 3
        }
        
        example("Replay Subject") {
            let disposableBag = DisposeBag()
            let subject = ReplaySubject<String>.create(bufferSize: 1)
            
            subject.subscribe(onNext: {print("First subscription:", $0)}).disposed(by: disposableBag)
            subject.onNext("a")
            subject.onNext("b")
            
            subject.subscribe(onNext: {print("Second subscription:", $0)}).disposed(by: disposableBag)
            subject.onNext("c")
            subject.onNext("d")
            
//            First subscription: a
//            First subscription: b
//            Second subscription: b
//            First subscription: c
//            Second subscription: c
//            First subscription: d
//            Second subscription: d
            
            let subject2 = ReplaySubject<Int>.create(bufferSize: 3)
            subject2.onNext(1)
            subject2.onNext(2)
            subject2.onNext(3)
            subject2.onNext(4)
            subject2.subscribe(onNext: {print($0)}).disposed(by: disposableBag)
            
//            2
//            3
//            4
        }
        
//        Variable is a wrapper for BehaviorSubject.
        example("Vatibles") {
            let disposableBag = DisposeBag()
            let variable = Variable("A")
            variable.asObservable().subscribe(onNext: {print($0)}).disposed(by: disposableBag)
            variable.value = "B"
        }
//        A
//        B
        
    }
    
    func example(_ rxOperator: String, action: () -> ()) {
        print("\n--- Example of:", rxOperator)
        action()
    }

}

