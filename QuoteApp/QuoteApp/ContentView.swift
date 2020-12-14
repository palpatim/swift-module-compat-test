//
//  ContentView.swift
//  QuoteApp
//
//  Created by Schmelter, Tim on 11/6/20.
//

import SwiftUI
import QuoteProvider

struct ContentView: View {
    @State var currentQuote: String = "Press button to grab a quote"

    var body: some View {
        HStack {
            VStack {
                Text(currentQuote)
                    .padding()
                Button("Get new quote") {
                    getNewQuote()
                }
            }
        }
    }

    func getNewQuote() {
        currentQuote = QuoteProvider.getQuote()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
