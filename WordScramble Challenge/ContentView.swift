//
//  ContentView.swift
//  WordScramble Challenge
//
//  Created by Orlando Moraes Martins on 20/12/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWorld = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var userScore = 0
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your Word", text: $newWorld)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                }
                Section{
                    ForEach(usedWords, id:\.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
                Section{
                    Text("Score: \(userScore)")
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: {
                startGame()
            })
            .alert(errorTitle, isPresented: $showingError){
                Button("OK", role: .cancel){}
            } message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("New Word") {startGame()}
            }
        }
    }
    func addNewWord(){
        let answer = newWorld.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return } // aqui iremos buscar algumas letras que sejam diferentes de vazios
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used alterady", message: "be more original")
            validWord(valid: false)
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            validWord(valid: false)
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't make them up, you know!")
            validWord(valid: false)
            return
        }
        
        validWord(valid: true)
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWorld = ""
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    //verifica se a palavra escrita eh diferente da palavra escrita inicialmente no game
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    //verifica se todas as letras da nova palavra escrita pertencem a palavra sugerida pelo game
    func isPossible(word: String) ->Bool{
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    //verificar se a palavra eh valida
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound //se for NSNotFound 'é uma palavra real
    }
    
    //metodo que ira apresentar mensagem de erro caso qualquer um dos metodos anteriores retornar falso
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    //metodo que ira calcular a pontuacao do usuario
    func validWord(valid: Bool) {
        if valid {
            userScore += 2
        } else {
            if userScore == 0 {
                userScore = 0
            } else {
                userScore -= 3
                if userScore < 0{
                    userScore = 0
                }
            }
        }
    }
}
