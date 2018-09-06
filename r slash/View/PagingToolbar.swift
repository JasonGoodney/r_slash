//
//  PagingToolbar.swift
//  r slash
//
//  Created by Jason Goodney on 9/5/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

protocol PagingToolbarDelegate: class {
    func prevPage()
    func nextPage()
}

class PagingToolbar: UIToolbar {
    
    weak var pagingDelegate: PagingToolbarDelegate?
    
    lazy var previousPageButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Previous", style: .plain,
                                     target: self, action: #selector(prevButtonTapped(_:)))
        return button
    }()
    
    lazy var nextPageButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Next", style: .plain,
                                     target: self, action: #selector(nextButtonTapped(_:)))
        return button
    }()
    
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        items = [previousPageButton, flexibleSpace, nextPageButton]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions
extension PagingToolbar {
    @objc func prevButtonTapped(_ sender: UIBarButtonItem) {
        pagingDelegate?.prevPage()
    }
    
    @objc func nextButtonTapped(_ sender: UIBarButtonItem) {
        pagingDelegate?.nextPage()
    }
}
