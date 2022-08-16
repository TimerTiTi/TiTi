//
//  CategoryLabel.swift
//  Project_Timer
//
//  Created by 최수정 on 2022/08/16.
//  Copyright © 2022 FDEE. All rights reserved.
//

import UIKit

/// 인터렉션 뷰의 좌측 항목 명을 위한 커스텀 Label
class CategoryLabel: UILabel {
    convenience init(title: String) {
        self.init(frame: CGRect())
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = title
        self.font = TiTiFont.HGGGothicssiP60g(size: 16)
        self.textColor = UIColor.label
    }
}
