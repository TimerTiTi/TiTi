//
//  SettingUpdateHistoryVC.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/04.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit
import Combine
import Moya

final class SettingUpdateHistoryVC: UIViewController {
    static let identifier = "SettingUpdateHistoryVC"

    @IBOutlet weak var updateList: UICollectionView!
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .medium)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = UIColor.lightGray
        loader.startAnimating()
        return loader
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: SettingUpdateHistoryVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Localized.string(.Settings_Button_UpdateHistory)
        self.configureLoader()
        self.configureCollectionView()
        self.configureViewModel()
        self.bindAll()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.updateList.adjustedContentInsetDidChange()
            self.updateList.reloadData()
        }
    }
}

extension SettingUpdateHistoryVC {
    private func configureLoader() {
        self.view.addSubview(self.loader)
        
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func configureCollectionView() {
        self.updateList.dataSource = self
        self.updateList.delegate = self
    }
    
    private func configureViewModel() {
        // TODO: DI 수정
        let api = TTProvider<FirebaseAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = FirebaseRepository(api: api)
        let getUpdateHistorysUseCase = GetUpdateHistorysUseCase(repository: repository)
        
        self.viewModel = SettingUpdateHistoryVM(getUpdateHistorysUseCase: getUpdateHistorysUseCase)
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
}

extension SettingUpdateHistoryVC {
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
                self?.updateList.reloadData()
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

extension SettingUpdateHistoryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.infos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UpdateInfoCell.identifier, for: indexPath) as? UpdateInfoCell else { return UICollectionViewCell() }
        guard let info = self.viewModel?.infos[safe: indexPath.item] else { return cell }
        cell.configure(with: info, superWidth: self.updateList.bounds.width)
        
        return cell
    }
}

extension SettingUpdateHistoryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UpdateInfoCell.identifier, for: indexPath) as? UpdateInfoCell else { return .zero }
        let textHeight = cell.textLabel.frame.height
        
        return CGSize(width: self.updateList.bounds.width, height: textHeight + 79.67 - 17)
    }
}
