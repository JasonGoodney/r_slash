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
    
    var thumbnail: UIImage?
    
    lazy var thumbnailImageView: UIImageView = {
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
        upvotesLabel.text = "\(post.numberOfUpvotes)"
        numberOfCommentsLabel.text = "\(post.numberOfComments)"
        thumbnailImageView.image = #imageLiteral(resourceName: "imageNotFound")
        
        [titleLabel, thumbnailImageView, upvotesLabel].forEach({
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
//            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 100),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 100),
            
            upvotesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            upvotesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 16),
            upvotesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
}






















