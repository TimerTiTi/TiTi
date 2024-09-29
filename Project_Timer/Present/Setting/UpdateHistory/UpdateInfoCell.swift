//
//  UpdateInfoCell.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2022/06/04.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit

final class UpdateInfoCell: UICollectionViewCell {
    static let identifier = "UpdateInfoCell"
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    func configure(with info: UpdateHistoryInfo, superWidth: CGFloat) {
        self.versionLabel.text = "ver \(info.version.value)"
        self.dateLabel.text = "\(info.date.value)"
        self.textLabel.text = info.text.value
        self.textLabel.preferredMaxLayoutWidth = superWidth - 32
        self.textLabel.sizeToFit()
    }
}
