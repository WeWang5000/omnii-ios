//
//  PageViewControllerDataSource.swift
//  PageViewController
//
//  Created by huxiaoyang on 2023/3/24.
//

import UIKit

public protocol PageViewControllerDatasource: NSObjectProtocol {
        
    func objects(for pageViewController: PageViewController) -> [PageDiffable]
    
    func pageViewController(_ pageViewController: PageViewController,
                            controllerFor object: PageDiffable) -> Pageable?
    
}

