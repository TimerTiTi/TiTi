//
//  ResetPasswordVC.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2024/03/16.
//  Copyright © 2024 FDEE. All rights reserved.
//

import UIKit
import Combine
import Moya
import SwiftUI

final class ResetPasswordVC: PortraitVC {
    private var environment: ResetPasswordEnvironment?
    private var cancellables: Set<AnyCancellable> = []
    
    override func loadView() {
        super.loadView()
        self.environment = ResetPasswordEnvironment(rootVC: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.configureHostingVC()
        self.bindListener()
    }
    
    private func configureHostingVC() {
        guard let environment = self.environment else { return }
        
        // TODO: DI 수정
        let api = TTProvider<AuthAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = AuthRepository(api: api)
        let checkUsernameExitUseCase = CheckUsernameExitUseCsae(repository: repository)
        let viewModel = ResetPasswordNicknameModel(checkUsenameExitUseCase: checkUsernameExitUseCase)
        let hostingVC = UIHostingController(rootView: ResetPasswordNicknameView(model: viewModel).environmentObject(environment))
        self.addChild(hostingVC)
        hostingVC.didMove(toParent: self)
        
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hostingVC.view)
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func bindListener() {
        self.environment?.$dismiss
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dismiss in
                if dismiss {
                    self?.dismiss(animated: true)
                }
            }
            .store(in: &self.cancellables)
        
        self.environment?.$resetSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                guard success else { return }
                self?.dismiss(animated: true)
            }
            .store(in: &self.cancellables)
    }
}
