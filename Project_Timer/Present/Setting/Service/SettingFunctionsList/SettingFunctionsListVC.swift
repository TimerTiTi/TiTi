//
//  SettingFunctionsListVC.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/04.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit
import Combine
import Moya

final class SettingFunctionsListVC: UIViewController {
    static let identifier = "SettingFunctionsListVC"

    @IBOutlet weak var functionList: UICollectionView!
    
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .medium)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = UIColor.lightGray
        loader.startAnimating()
        return loader
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: SettingFunctionsListVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Localized.string(.Settings_Button_Functions)
        self.configureLoader()
        self.configureCollectionView()
        self.configureViewModel()
        self.bindAll()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.functionList.collectionViewLayout.invalidateLayout()
        }
    }
}

extension SettingFunctionsListVC {
    private func configureLoader() {
        self.view.addSubview(self.loader)
        
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func configureCollectionView() {
        self.functionList.dataSource = self
        self.functionList.delegate = self
    }
    
    private func configureViewModel() {
        // TODO: DI 수정
        let api = TTProvider<FirebaseAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = FirebaseRepository(api: api)
        let getTiTiFunctionsUseCase = GetTiTiFunctionsUseCase(repository: repository)
        
        self.viewModel = SettingFunctionsListVM(getTiTiFunctionsUseCase: getTiTiFunctionsUseCase)
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
}

extension SettingFunctionsListVC {
    private func bindAll() {
        self.bindCells()
        self.bindWarning()
    }
    
    private func bindCells() {
        self.viewModel?.$infos
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.stopLoader()
                self?.functionList.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.stopLoader()
                self?.showAlertWithOK(title: warning.title, text: warning.text)
            })
            .store(in: &self.cancellables)
    }
}

extension SettingFunctionsListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.infos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FunctionInfoCell.identifier, for: indexPath) as? FunctionInfoCell else { return UICollectionViewCell() }
        guard let info = self.viewModel?.infos[safe: indexPath.item] else { return cell }
        cell.configure(with: info, delegate: self)
        
        return cell
    }
}

extension SettingFunctionsListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.functionList.bounds.width, height: 55)
    }
}

extension SettingFunctionsListVC: FunctionsActionDelegate {
    func showWebview(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

