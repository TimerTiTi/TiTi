//
//  SettingVC.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/05/28.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit
import Combine
import MessageUI
import Moya
import Combine

final class SettingVC: UIViewController {
    static let identifier = "SettingVC"
    
    @IBOutlet weak var settings: UICollectionView!
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: SettingVM?
    private var lastSection: Int {
        if let sectionsCount = self.viewModel?.sections.count {
            return sectionsCount-1
        } else {
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureViewModel()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.updateTabbarColor(backgroundColor: Colors.tabbarBackground, tintColor: .label, normalColor: .lightGray)
        self.settings.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tabBarController?.updateTabbarColor(backgroundColor: Colors.tabbarBackground, tintColor: .label, normalColor: .lightGray)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            guard let settings = self?.settings else { return }
            settings.collectionViewLayout.invalidateLayout()
        }
    }
}

extension SettingVC {
    private func configureCollectionView() {
        self.extendedLayoutIncludesOpaqueBars = true
        self.settings.dataSource = self
        self.settings.delegate = self
    }
    
    private func configureViewModel() {
        // TODO: DI 수정
        let api = TTProvider<FirebaseAPI>(session: Session(interceptor: NetworkInterceptor.shared))
        let repository = FirebaseRepository(api: api)
        let getAppVersionUseCase = GetAppVersionUseCase(repository: repository)
        self.viewModel = SettingVM(getAppVersionUseCase: getAppVersionUseCase, isIpad: UIDevice.current.userInterfaceIdiom == .pad)
    }
    
    private func bindAll() {
        self.bindCells()
        self.bindLastestVersionFetched()
    }
    
    private func bindCells() {
        self.viewModel?.$cells
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.settings.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindLastestVersionFetched() {
        self.viewModel?.$latestVersionFetched
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.settings.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

extension SettingVC: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel?.sections.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellInfo = self.viewModel?.cells[indexPath.section][indexPath.item],
              let action = cellInfo.action,
              let destination = cellInfo.destination else { return }
        
        switch action {
        case .pushVC:
            switch destination {
            case .storyboardName(let identifier):
                self.pushVC(identifier: identifier)
            default:
                self.pushVC(destination: destination)
            }
            
        case .modalFullscreen:
            self.modalVC(fullscreen: true, destination: destination)
            
        case .activityVC:
            self.systemVC(destination: destination)
            
        case .otherApp:
            self.showOtherApp(destination: destination)
        }
    }
}

extension SettingVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.cells[safe: section]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == self.lastSection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingDevInfoCell.identifier, for: indexPath) as? SettingDevInfoCell else { return UICollectionViewCell() }
            cell.delegate = self
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell else { return UICollectionViewCell() }
            guard let cellInfo = self.viewModel?.cells[indexPath.section][indexPath.item] else { return cell }
            cell.configure(with: cellInfo)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingHeaderView.identifier, for: indexPath) as? SettingHeaderView else { return UICollectionReusableView() }
            guard let headerTitle = self.viewModel?.sections[safe: indexPath.section] else { return header }
            
            header.configure(title: headerTitle)
            return header
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SettingFooterView.identifier, for: indexPath)
            return footer
        } else { return UICollectionReusableView() }
    }
}

extension SettingVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.settings.bounds.width
        guard let info = self.viewModel?.cells[indexPath.section][indexPath.item] else { return CGSize(width: width, height: 43)}
        let height: CGFloat = indexPath.section == self.lastSection ? 80 : CGFloat(info.cellHeight)
        
        return CGSize(width: width, height: height)
    }
}

extension SettingVC: SettingActionDelegate {
    func pushVC(identifier: String) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: identifier) else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func pushVC(destination: Destination) {
        switch destination {
        case .notification:
            self.navigationController?.pushViewController(SettingSwitchListVC(dataSource: .notification), animated: true)
        case .ui:
            self.navigationController?.pushViewController(SettingSwitchListVC(dataSource: .ui), animated: true)
        case .control:
            self.navigationController?.pushViewController(SettingSwitchListVC(dataSource: .control), animated: true)
        case .language:
            self.navigationController?.pushViewController(SettingLanguageVC(), animated: true)
        case .widget:
            // MARK: 위젯 추가제작시 Widget 선택창 구현 필요
            self.navigationController?.pushViewController(SettingCalendarWidgetVC(), animated: true)
        default:
            break
        }
    }
    
    func modalVC(fullscreen: Bool, destination: Destination) {
        switch destination {
        case .signinSelect:
            let vc = SigninSignupVC()
            if fullscreen {
                vc.modalPresentationStyle = .fullScreen
            }
            self.present(vc, animated: true)
        default:
            break
        }
    }
    
    func systemVC(destination: Destination) {
        switch destination {
        case .backup:
            // test code
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let activityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)

            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.sourceRect = self.navigationController!.navigationBar.frame
            }

            self.present(activityViewController, animated: true)
        case .mail:
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["contact.timertiti@gmail.com"])
                mail.setMessageBody("<p>\(Localized.string(.EmailMessage_Text_Message))</p>", isHTML: true)
                
                present(mail, animated: true)
            } else {
                let sendMailErrorAlert = UIAlertController(title: Localized.string(.EmailMessage_Error_CantSendEmailTitle), message: Localized.string(.EmailMessage_Error_CantSendEmailDesc), preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: Localized.string(.Common_Text_OK), style: .default)
                sendMailErrorAlert.addAction(confirmAction)
                self.present(sendMailErrorAlert, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func showOtherApp(destination: Destination) {
        switch destination {
        case .website(let url):
            if let url = URL(string: url) {
                UIApplication.shared.open(url, options: [:])
            }
        case .deeplink(let url):
            if let url = URL(string: url),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        default:
            break
        }
    }
}

extension SettingVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
