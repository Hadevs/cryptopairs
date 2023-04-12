//
//  MainRouter.swift
//  CryptoPairs
//
//  Created by Danil Kovalev on 10.04.2023.
//

import UIKit

struct MainRouter {
    private let initialViewController: UIViewController = PairsViewController()
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }

    func route() {
        let nc = UINavigationController(rootViewController: initialViewController)
        self.window.rootViewController = nc
        self.window.makeKeyAndVisible()
    }
}
