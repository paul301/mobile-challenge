//
//  ViewController.swift
//  PxChallenge
//
//  Created by Paul Floussov on 2017-04-10.
//  Copyright © 2017 Paul Floussov. All rights reserved.
//

import UIKit
import RxSwift
import Moya_ObjectMapper

class ViewController: UIViewController {

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        pxProvider.request(.popularPhotos())
            .mapObject(PopularPage.self)
            .subscribe { event in
                switch event {
                case .next(let page):
                    print(page)
                case .error(let error):
                    print(error)
                default:
                    break
                }
        }.disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

