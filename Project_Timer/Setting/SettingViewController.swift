//
//  SettingViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/05/28.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit
import Combine

final class SettingViewController: UIViewController {
    static let identifier = "SettingViewController"
    
    @IBOutlet weak var settings: UICollectionView!
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: SettingVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureViewModel()
        self.bindAll()
    }
}

extension SettingViewController {
    private func configureCollectionView() {
        self.settings.dataSource = self
        self.settings.delegate = self
    }
    
    private func configureViewModel() {
        self.viewModel = SettingVM()
    }
    
    private func bindAll() {
        self.bindCells()
    }
    
    private func bindCells() {
        self.viewModel?.$cells
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.settings.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

extension SettingViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel?.sectionTitles.count ?? 0
    }
}

extension SettingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.cells[safe: section]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell else { return UICollectionViewCell() }
        guard let cellInfo = self.viewModel?.cells[indexPath.section][indexPath.item] else { return cell }
        cell.configure(with: cellInfo)
        
        return cell
    }
}

extension SettingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.settings.bounds.width
        guard let info = self.viewModel?.cells[indexPath.section][indexPath.item] else { return CGSize(width: width, height: 43)}
        print(info.cellHeight)
        return CGSize(width: width, height: CGFloat(info.cellHeight))
    }
}
