//
//  NewsTableViewController.swift
//  SimpleRSSReader
//
//  Created by Simon Ng on 26/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    private var rssItems : [ArticleItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 155.0
        tableView.rowHeight = UITableView.automaticDimension
        
        
        let feedParser = FeedParser()
        
        feedParser.parseFeed(feedUrl: "https://techcrunch.com/feed/", completionHandler:  { (rssItems : [ArticleItem]) -> Void in
            self.rssItems = rssItems
                                
            OperationQueue.main.addOperation( { () -> Void in
                self.tableView.reloadSections(IndexSet(integer:0), with: .none )
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        guard let rssItems = rssItems else {
            return 0
        }
        
        return rssItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        
        if let item = rssItems?[indexPath.row] {
            cell.titleLabel.text = item.title
            cell.descriptionLabel.text = item.content
            cell.dateLabel.text = item.pubDate
            
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
        
            if let indexPath = tableView.indexPathForSelectedRow {
                if let item = rssItems?[indexPath.row] {
                    let destination = segue.destination as! DetailViewController
                    print("Detail content: \n \(item.detail)")
                    destination.content = item.detail
                }
                
            }
        }
    }

}
