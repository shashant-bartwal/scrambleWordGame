//
//  ContentView.swift
//  ScrambleWorldList
//
//  Created by shashant on 10/06/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootword = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMsg = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter the word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                    
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }.navigationBarTitle(rootword)
            .onAppear(perform: startGame)
            .alert(isPresented: $showError, content: {
                Alert(title: Text(errorTitle).bold(), message: Text(errorMsg), dismissButton: .default(Text("OK")))
            })
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(words: answer) else {
            wordError(title: "Word used already", msg: "Be more original")
            return
        }
        
        guard isPossible(words: answer) else {
            wordError(title: "Word not recognised", msg: "You can't just make them up you now")
            return
        }
        
        guard isRealWord(words: answer) else {
            wordError(title: "Word not possible", msg: "That is not the real word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allwords = startWords.components(separatedBy: "\n")
                rootword = allwords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(words: String) -> Bool {
       return !usedWords.contains(words)
    }
    
    func isPossible(words: String) -> Bool {
        var tempword = rootword.lowercased()
        for letter in words {
            if let pos = tempword.firstIndex(of: letter) {
                tempword.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isRealWord(words: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: words.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: words, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, msg: String) {
        errorTitle = title
        errorMsg = msg
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
