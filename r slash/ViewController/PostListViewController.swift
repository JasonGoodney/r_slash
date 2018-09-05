//
//  PostListViewController.swift
//  r slash
//
//  Created by Jason Goodney on 9/4/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit
import SafariServices

class PostListViewController: UIViewController {
    
    // MARK: - Properties
    var posts: [Post]?
    var subreddit = RedditURL.defaultSubreddit
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.register(PostTableViewCell.self,
                      forCellReuseIdentifier: PostTableViewCell.reuseIdentifier())
        view.estimatedRowHeight = 128
        view.rowHeight = UITableViewAutomaticDimension
        if #available(iOS 10.0, *) { view.refreshControl = refreshControl }
            else { view.addSubview(refreshControl) }
        return view
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshSubreddit), for: .valueChanged)
        return control
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
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
}

// MARK: - Update View
private extension PostListViewController {
    func updateView() {
        
        [tableView].forEach({
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
        ])
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func updateSubredditLabel(_ subreddit: String) {
        subredditLabel.text = "\(subreddit)"
    }
    
    func setupNavigationBar() {
        let barButtonItem = UIBarButtonItem(customView: subredditLabel)
        navigationItem.rightBarButtonItem = barButtonItem
        navigationItem.title = "r slash"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
    }
    
    @objc func refreshSubreddit() {
        refreshControl.beginRefreshing()
        displaySubreddit(subreddit)
    }
}

// MARK: - Fetching
private extension PostListViewController {
    func displaySubreddit(_ subreddit: String) {
        PostController.shared.fetchPosts(by: subreddit) { (posts, error) in
            if let _ = error {
                DispatchQueue.main.async {
                    self.notFoundAlert(subreddit)
                    return
                }
            }
            
            guard let posts = posts else { return }
            self.posts = posts
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.reloadTableView()
                self.updateSubredditLabel(subreddit)
                self.refreshControl.endRefreshing()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseIdentifier(),
                                                       for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        guard let post = posts?[indexPath.row] else { return UITableViewCell() }
        cell.post = post
        
        if post.thumbnailEndpoint != RedditURL.thumbnailSelf {
            PostController.shared.fetchImage(at: post.thumbnailEndpoint) { (image, error) in
                DispatchQueue.main.async {
                    if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath {
                        cell.thumbnailImageView.image = image
                    } else {
                        print("Got image for now-reused cell")
                        return // Cell has been reused
                    }
                }
            }
        } else { cell.thumbnailImageView.isHidden = true }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let posts = posts else { return }
        let post = posts[indexPath.row]
        
        if let url = URL(string: RedditURL.baseString)?.appendingPathComponent(post.permalink) {
            let sfv = SFSafariViewController(url: url)
            sfv.delegate = self
            present(sfv, animated: true, completion: nil)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension PostListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
////        // When searchText == "", so does subreddit
//        subreddit = searchText
        
    }
}

// MARK: - UISearchBarDelegate
extension PostListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.lowercased() else { return }
        
        subreddit = searchText
        displaySubreddit(subreddit)
        searchBar.text = ""
        searchController.isActive = false
    }
}

// MARK: - SFSafariViewControllerDelegate
extension PostListViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Alert
extension PostListViewController {
    func notFoundAlert(_ subreddit: String) {
        let alertLabel = UILabel(frame: CGRect(x: 16, y: -64, width: self.view.frame.width - 32, height: 64))
        alertLabel.backgroundColor = #colorLiteral(red: 1, green: 0.3033397018, blue: 0.2027637527, alpha: 1)
        alertLabel.textColor = .white
        alertLabel.text = "r/\(subreddit) not found"
        alertLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        alertLabel.textAlignment = .center
        alertLabel.layer.cornerRadius = 5
        alertLabel.clipsToBounds = true
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.addSubview(alertLabel)

        UIView.animate(withDuration: 0.5, animations: {
            alertLabel.frame.origin.y = 22
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.5, options: [], animations: {
                alertLabel.frame.origin.y = -64
            }, completion: nil)
        }
    }
}
