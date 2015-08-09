//
//  ViewController.swift
//  UISearchBarSample
//
//  Created by Toshikazu Fukuoka on 2015/08/08.
//  Copyright (c) 2015年 travitu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let sampleData: [String] = ["テスト","てすと","ほげほげ","ホゲホゲ","abc","ABC"]
    var filtered:[String] = []
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        if searchActive {
            cell.textLabel!.text = self.filtered[indexPath.row]
        }else {
            cell.textLabel!.text = self.sampleData[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        return sampleData.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func judgeHiragana(str: String) -> String{
        var tmpHiragana: NSString = "[ぁ-ん]"
        let range = (str as NSString).rangeOfString(tmpHiragana as String, options: NSStringCompareOptions.RegularExpressionSearch)
        if range.location != NSNotFound {
            let description: String
            var mutableString = NSMutableString(string: str) as CFMutableString
            if CFStringTransform(mutableString, nil, kCFStringTransformHiraganaKatakana, 0) == 1 {
                description = mutableString as NSString as String
                return description
            }
        }
        return ""
    }
    
    func judgeKatakana(str: String) -> String{
        var tmpKatakana: NSString = "[ァ-ヶ]"
        let range = (str as NSString).rangeOfString(tmpKatakana as String, options: NSStringCompareOptions.RegularExpressionSearch)
        if range.location != NSNotFound {
            let description: String
            var mutableString = NSMutableString(string: str) as CFMutableString
            if CFStringTransform(mutableString, nil, kCFStringTransformHiraganaKatakana, 1) == 1 {
                description = mutableString as NSString as String
                return description
            }
        }
        return ""
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
//        println("searchBar.text:\(searchBar.text)")
//        println("range.location:\(range.location)")
//        println("range.length:\(range.length)")
        println("text:\(text)")

        var newRange: NSRange = range
        println("newRange.length:\(newRange.length)")
        
        var str = (searchBar.text as NSString).stringByReplacingCharactersInRange(newRange, withString: text)
        
        /**
        Normalize このへん試すがうまくいかず
        precomposedStringWithCanonicalMappingとか
        */
//        var searchText: String = searchBar.text + str
//        println("searchBar.text:\(searchBar.text)")
//        println("searchText:\(searchText)")
//        println("str:\(str)")
//        println("\u{304C}")
//        println("\u{304B}\u{3099}")
        
//        str = str.precomposedStringWithCanonicalMapping
//        println("str:\(str)")
        
//        for c in str.utf8 {
//            print(NSString(format: "%2X", c)); print(" ")
//        }
        
//        let codes:String.UTF8View = String(str).utf8
//        println("codes:\(codes)")

//        for code in str.utf8 {
//            println(code)
//        }
        
//        let char:CChar = first(str.cStringUsingEncoding(NSUTF8StringEncoding)!)!
//        println("char:\(char)")
//
//        var count: Int = countSequence(str)
//        println("count:\(count)")

//        var normalizeStr = str.precomposedStringWithCanonicalMapping
//        println("normalizeStr:\(normalizeStr)")
        
        println("str:\(str)")
        

        filtered = sampleData.filter({ (text) -> Bool in

            /**
             CaseInsensitiveSearch : 大文字/小文字の区別を無視
             AnchoredSearch : 最初にマッチした文字を返す
            */
            
            // 変換せずにそのまま入力された文字で検索
            let historyTmp: NSString = text
            let range = historyTmp.rangeOfString(str, options: NSStringCompareOptions.CaseInsensitiveSearch | NSStringCompareOptions.AnchoredSearch)
            
            // ひらがなorカタカナに変換して検索する
            let transformClosure = {(str: String, transformStr: NSString, reverseMode: Boolean) -> NSRange in
                let range = (str as NSString).rangeOfString(transformStr as String, options: NSStringCompareOptions.RegularExpressionSearch)
                if range.location != NSNotFound {
                    let description: String
                    var mutableString = NSMutableString(string: str) as CFMutableString
                    if CFStringTransform(mutableString, nil, kCFStringTransformHiraganaKatakana, reverseMode) == 1 {
                        description = mutableString as NSString as String
                        // 変換した文字が検索履歴で一致するか調べる
                        let matchRange = historyTmp.rangeOfString(description, options: NSStringCompareOptions.CaseInsensitiveSearch | NSStringCompareOptions.AnchoredSearch)
                        return matchRange
                    }
                }
                return range
            }
            var hiraganaRange = transformClosure(str, "[ぁ-ん]", 0)
            var katakanaRange = transformClosure(str, "[ァ-ヶ]", 1)

//            let hiraganaRange = tmp.rangeOfString(hiragana, options: NSStringCompareOptions.CaseInsensitiveSearch | NSStringCompareOptions.AnchoredSearch)
            
            // カタカナ->ひらがなに変換して検索する
//            let katakanaClosure = {(str: String) -> String in
//                var tmp: NSString = "[ァ-ヶ]"
//                let range = (str as NSString).rangeOfString(tmp as String, options: NSStringCompareOptions.RegularExpressionSearch)
//                if range.location != NSNotFound {
//                    let description: String
//                    var mutableString = NSMutableString(string: str) as CFMutableString
//                    if CFStringTransform(mutableString, nil, kCFStringTransformHiraganaKatakana, 1) == 1 {
//                        description = mutableString as NSString as String
//                        return description
//                    }
//                }
//                return ""
//            }
//            var katakana = katakanaClosure(str)
//            let katakanaRange = historyTmp.rangeOfString(katakana, options: NSStringCompareOptions.CaseInsensitiveSearch | NSStringCompareOptions.AnchoredSearch)
            
            return range.location != NSNotFound || hiraganaRange.location != NSNotFound || katakanaRange.location != NSNotFound
        })
        
        println("filtered:\(filtered)")

        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
        
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
        self.searchBar.becomeFirstResponder()
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    

}

