//
//  QuoteProvider.swift
//  QuoteProvider
//
//  Created by Schmelter, Tim on 11/6/20.
//  Copyright © 2020 Amazon Web Services. All rights reserved.
//

import Foundation

public class QuoteProvider {
    public static func getQuote() -> String {
        QuoteList().getQuoteList().randomElement() ?? "(No quotes found)"
    }
    public static func getQuoteList() -> QuoteList {
        QuoteList()
    }
}

public class QuoteList {
    private static let quotes = [
        """
        Before you judge a man, walk a mile in his shoes. After that who cares? \
        He’s a mile away and you’ve got his shoes!
        — Billy Connolly
        """,

        """
        People say nothing is impossible, but I do nothing every day.
        – A. A. Milne
        """,

        """
        At every party there are two kinds of people – those who want to go home and those \
        who don’t. The trouble is, they are usually married to each other.
        – Ann Landers
        """
    ]

    public func getQuoteList() -> [String] {
        QuoteList.quotes
    }
}
