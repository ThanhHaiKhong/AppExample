//
//  NotificationsViewController.swift
//  NotificationsClient
//
//  Created by Thanh Hai Khong on 27/2/25.
//

import ComposableArchitecture
import SwiftUI
import UIKit

@objc
public class NotificationsViewController: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Notifications"
        self.setupAppearance()
        self.initialize()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setupAppearance() {
        self.navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0);
        self.view.backgroundColor = .systemGroupedBackground;
    }
    
    private func initialize() {
        let store = Store(initialState: Notifications.State()) {
            Notifications()
        }
        
        let swiftUIView = NotificationView(store: store)
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = UIColor.systemGroupedBackground
        
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        hostingController.didMove(toParent: self)
    }
}
