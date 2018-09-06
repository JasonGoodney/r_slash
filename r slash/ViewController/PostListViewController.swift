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
        
        displaySubreddit(subreddit, page: nil)
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
        setupTableView()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
    
    func setupTableView() {
        tableView.contentOffset.y = -64
    }
    
    func previousButton(isHidden: Bool) {
        
    }
}

// MARK: - Fetching
private extension PostListViewController {
    func displaySubreddit(_ subreddit: String, page: [String : String]?) {
        
        PostController.shared.fetchPosts(by: subreddit, page: page) { (posts, error) in
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

// MARK: - Actions
private extension PostListViewController {
    @objc func refreshSubreddit() {
        refreshControl.beginRefreshing()
        
        displaySubreddit(subreddit, page: PostController.shared.currentPage)
    }
    
    func openInReddit(from post: Post) -> Bool {
        let redditHook = "reddit://\(post.permalink)"
        guard let redditURL = URL(string: redditHook) else { return false }
        
        if UIApplication.shared.canOpenURL(redditURL) {
            UIApplication.shared.open(redditURL, options: [:], completionHandler: nil)
            return true
        }
        print("Reddit not on device")
        return false
    }
    
    func openInSafari(from post: Post) {
        guard let url = URL(string: RedditURL.baseString)?.appendingPathComponent(post.permalink) else { return }
        let sfv = SFSafariViewController(url: url)
        sfv.delegate = self
        present(sfv, animated: true, completion: nil)
    }
    
    func deselectCell() {
        print("\(#function)")
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    func scrollToTop() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension PostListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseIdentifier(),
                                                       for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        guard let posts = posts else { return UITableViewCell() }
        let post = posts[indexPath.row]
        cell.post = post
        
        PostController.shared.fetchImage(at: post.thumbnailEndpoint) { (image, error) in
            DispatchQueue.main.async {

                if image != nil {
                    cell.thumbnailImageView.image = image
                } else {
                    cell.thumbnailImageView.image = #imageLiteral(resourceName: "imageNotFound")
                }
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let posts = posts else { return }
        let post = posts[indexPath.row]
        
        if !openInReddit(from: post) {
            openInSafari(from: post)
        }
        
        deselectCell()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let pagingToolbar = PagingToolbar()
        pagingToolbar.pagingDelegate = self
        return pagingToolbar
    }
}

// MARK: - PagingToolbarDelegate
extension PostListViewController: PagingToolbarDelegate {
    func nextPage() {
        if let nextPage = PostController.shared.nextPage {
            displaySubreddit(subreddit, page: ["after" : nextPage])
            PostController.shared.postCount += 25
            PostController.shared.currentPage = ["after" : nextPage]
            scrollToTop()
        }
    }
    
    func prevPage() {
        if let prevPage = PostController.shared.prevPage {
            displaySubreddit(subreddit, page: ["before" : prevPage])
            PostController.shared.postCount -= 25
            PostController.shared.currentPage = ["before" : prevPage]
            scrollToTop()
        }
    }
}

// MARK: - UISearchResultsUpdating
extension PostListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {   
    }
}

// MARK: - UISearchBarDelegate
extension PostListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.lowercased() else { return }
        
        subreddit = searchText
        displaySubreddit(subreddit, page: nil)
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

