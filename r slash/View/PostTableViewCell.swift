//
//  PostTableViewCell.swift
//  r slash
//
//  Created by Jason Goodney on 9/4/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    var thumbnail: UIImage? {
        didSet {
            thumbnailImageView.image = thumbnail
        }
    }
    
    var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    var upvotesLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var numberOfCommentsLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var bottomStackView: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
    }
}

// MARK: - Reuse Identifier
extension PostTableViewCell {
    static func reuseIdentifier() -> String {
        return "PostTableViewCell"
    }
}

// MARK: - Update View
private extension PostTableViewCell {
    func updateView() {
        guard let post = post else { return }
        
        titleLabel.text = post.title
        upvotesLabel.text = "Ups \(post.numberOfUpvotes)"
        numberOfCommentsLabel.text = "Comments \(post.numberOfComments)"
        thumbnailImageView.image = #imageLiteral(resourceName: "imageNotFound")
        
        [titleLabel, thumbnailImageView, bottomStackView].forEach({
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        
        [upvotesLabel, numberOfCommentsLabel].forEach({
            bottomStackView.addArrangedSubview($0)
        })
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 100),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 100),
            
            bottomStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 16),
            bottomStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            bottomStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            bottomStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
        ])
    }
}






















