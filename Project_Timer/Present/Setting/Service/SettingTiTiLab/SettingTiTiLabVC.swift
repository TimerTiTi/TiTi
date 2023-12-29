//
//  SettingTiTiLabVC.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/04.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit
import Combine

final class SettingTiTiLabVC: UIViewController {
    static let identifier = "SettingTiTiLabVC"

    @IBOutlet weak var surveys: UICollectionView!
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .medium)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = UIColor.lightGray
        loader.startAnimating()
        return loader
    }()
    @IBOutlet weak var syncLabel: UILabel!
    @IBOutlet weak var signupSyncLabel: UILabel!
    @IBOutlet weak var signinTextLabel: UILabel!
    @IBOutlet weak var signinButton: UIButton!
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: SettingTiTiLabVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.syncLabel.text = "Synchronization".localized()
        self.configureLoader()
        self.configureCollectionView()
        self.configureViewModel()
        self.bindAll()
        // signin
        self.checkSignined()
        self.configureObservation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Localized.string(.Settings_Button_TiTiLab)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.surveys.collectionViewLayout.invalidateLayout()
        }
    }
    
    @IBAction func signupSync(_ sender: Any) {
        let signined = UserDefaultsManager.get(forKey: .signinInTestServerV1) as? Bool ?? false
        if signined {
            self.showSyncHistorysVC()
        } else {
            self.showBetaSigninSignupVC(signin: false)
        }
    }
    
    @IBAction func signin(_ sender: Any) {
        self.showBetaSigninSignupVC(signin: true)
    }
}

// MARK: TestServer Signin
extension SettingTiTiLabVC {
    private func checkSignined() {
        let signined = UserDefaultsManager.get(forKey: .signinInTestServerV1) as? Bool ?? false
        if signined {
            self.configureSignined()
        } else {
            self.configureSignouted()
        }
    }
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: KeyChain.signined, object: nil, queue: .main) { [weak self] _ in
            self?.configureSignined()
        }
    }
    
    private func configureSignined() {
        self.signupSyncLabel.text = "Sync Dailys"
        self.signinTextLabel.text = "Synclonize Historys [Test Server]".localized()
        self.signinButton.isHidden = true
    }
    
    private func configureSignouted() {
        self.signupSyncLabel.text = "Signup"
        self.signinTextLabel.text = "for Synclonize Dailys [Test Server]".localized()
        self.signinButton.isHidden = false
    }
    
    private func showBetaSigninSignupVC(signin: Bool) {
        let authUseCase = AuthUseCase(repository: AuthRepository())
        let viewModel = SignupSigninVM(authUseCase: authUseCase, isSignin: signin)
        let vc = SignupSigninVC(viewModel: viewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showSyncHistorysVC() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: SyncDailysVC.identifier) else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SettingTiTiLabVC {
    private func configureLoader() {
        self.view.addSubview(self.loader)
        
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func configureCollectionView() {
        self.surveys.dataSource = self
        self.surveys.delegate = self
    }
    
    private func configureViewModel() {
        // MARK: NetworkController 생성 관련 로직고민이 필요
        let networkController = NetworkController(network: Network())
        self.viewModel = SettingTiTiLabVM(networkController: networkController)
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
}

extension SettingTiTiLabVC {
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
                self?.surveys.reloadData()
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

extension SettingTiTiLabVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(self.viewModel?.infos.count ?? 0, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SurveyCell.identifier, for: indexPath) as? SurveyCell else { return UICollectionViewCell() }
        if self.viewModel?.infos.count ?? 0 == 0 {
            cell.configureWarning()
        } else {
            guard let info = self.viewModel?.infos[safe: indexPath.item] else { return cell }
            cell.configure(with: info, delegate: self)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TiTiLabHeaderView.identifier, for: indexPath) as? TiTiLabHeaderView else { return UICollectionReusableView() }
            header.configure(delegate: self)
            
            return header
        } else { return UICollectionReusableView() }
    }
}

extension SettingTiTiLabVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.surveys.bounds.width, height: 55)
    }
}

extension SettingTiTiLabVC: TiTiLabActionDelegate {
    func showWebview(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
