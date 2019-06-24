//
//  FeedParser.swift
//  SimpleRSSReader
//
//  Created by Mai Le on 5/30/19.
//  Copyright © 2019 AppCoda. All rights reserved.
//


import Foundation

typealias ArticleItem = (title: String, content : String, pubDate: String, detail: String)

extension String {
    
    init?(htmlEncodedString: String) {
        
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
    
//    extension String{
//        func convertHtml() -> NSAttributedString{
//            guard let data = data(using: .utf8) else { return NSAttributedString() }
//            do{
//                return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
//            }catch{
//                return NSAttributedString()
//            }
//        }
//    }
    
}


class FeedParser : NSObject, XMLParserDelegate {
    
    //: ###Properties
    enum RssTag :  String {
        case item = "item"
        case title = "title"
        case content = "description"
        case pubDate = "pubDate"
        case detail = "content:encoded"
    }
    
    private var rssItems : [ArticleItem] = []
    
    private var currentElement = ""
    
    private var currentTitle : String = "" {
        didSet{
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentContent = "" {
        didSet{
            currentContent = currentContent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentPubDate = "" {
        didSet{
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentDetail = "" {
        didSet{
            currentDetail = currentDetail.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var parserCompletionHandler : ( ([ArticleItem]) -> Void )?
    
    //: ###Functions
    
    // This function is to feed the URL, download the XML content asynchronously, and parse the XML
    // into documents
    func parseFeed ( feedUrl : String, completionHandler : (([ArticleItem]) -> Void)? ) {
        
        self.parserCompletionHandler = completionHandler
        
        let request = URLRequest( url: URL(string : feedUrl)! )
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                if let error = error {
                    print ("Error getting data from requested Url -> detail : \(error)")
                }
                return
            }
            
            // Parse XML data
            let parser = XMLParser(data : data)
            
            parser.delegate = self
            
            parser.parse()
        }
        
        task.resume()
    }
    
    // Start working on the documents
    
    func parserDidStartDocument(_ parser: XMLParser) {
        rssItems = []
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        
        currentElement = elementName
        
        if currentElement == RssTag.item.rawValue { // if the <item> tag is found
            currentTitle = ""
            currentContent = ""
            currentPubDate = ""
            currentDetail = ""
        }
    }
    
    // when the <title> <content> <pubDate> tags are found
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        switch currentElement {
            
            case RssTag.title.rawValue : currentTitle += string
            
            case RssTag.content.rawValue : currentContent += string
            
            case RssTag.pubDate.rawValue : currentPubDate += string
            
            case RssTag.detail.rawValue : currentDetail += string
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == RssTag.item.rawValue {
            
            if let detailContent = String(htmlEncodedString: currentDetail) {
                currentDetail = detailContent
            }
            
            if let description = String(htmlEncodedString: currentContent){
                currentContent = description
            }
            
            let rssItem = (title: currentTitle, content : currentContent, pubDate: currentPubDate, detail: currentDetail)
            
            rssItems += [rssItem]
        }
    }
    
    // end the document
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItems)
    }
    


    
}
