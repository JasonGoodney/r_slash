//
//  PostListViewController.swift
//  r slash
//
//  Created by Jason Goodney on 9/4/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {
    
    // MARK: - Properties
    var posts: [Post]?
    var subreddit = "funny"
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.register(PostTableViewCell.self,
                      forCellReuseIdentifier: PostTableViewCell.reuseIdentifier())
        view.estimatedRowHeight = 128
        view.rowHeight = UITableViewAutomaticDimension
        return view
    }()
    
    lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        
        return view
    }()
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.delegate = self
        search.hidesNavigationBarDuringPresentation = false
        search.dimsBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search"
        return search
    }()
    
    let subredditLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 72, height: 44)
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
        
        displaySubreddit(subreddit)
    }
}

// MARK: - Update View
private extension PostListViewController {
    func updateView() {
        
        [tableView, progressView].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        setupConstraints()
        
        setupNavigationBar()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.updateSubredditLabel()
        }
    }
    
    func updateSubredditLabel() {
        subredditLabel.text = "\(subreddit)"
    }
    
    func setupNavigationBar() {
        
//        subredditLabel.numberOfLines = 0
        
        let barButtonItem = UIBarButtonItem(customView: subredditLabel)
        navigationItem.rightBarButtonItem = barButtonItem
        navigationItem.title = "r slash"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
    }
}

// MARK: - Fetching
private extension PostListViewController {
    func displaySubreddit(_ subreddit: String) {
        PostController.shared.fetchPosts(by: subreddit) { (posts) in
            guard let posts = posts else { return }
            self.posts = posts
            self.subreddit = subreddit
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.reloadTableView()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseIdentifier(), for: indexPath) as? PostTableViewCell
        
        guard let post = posts?[indexPath.row] else { return UITableViewCell() }
        
        PostController.shared.fetchImage(from: post) { (image) in
            
            DispatchQueue.main.async {
                cell?.thumbnailImageView.image = image != nil ? image : #imageLiteral(resourceName: "imageNotFound")
            }
        }
        
        cell?.post = post
        
        return cell ?? UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension PostListViewController: UITableViewDelegate {
    
}

// MARK: - UISearchResultsUpdating
extension PostListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        // When searchText == "", so does subreddit
        subreddit = searchText
    }
}

// MARK: - UISearchBarDelegate
extension PostListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        displaySubreddit(subreddit)
        searchBar.text = ""
        searchController.isActive = false        
    }
}

