//
//  ScoreController.swift
//  Mini Challenge 01
//
//  Created by Thiago Liporace on 03/08/23.
//

import Foundation
import CoreData

class HighscoreController: ObservableObject {
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        createInitialHighscore()
    }
    
    func createInitialHighscore() {
        let fetchRequest: NSFetchRequest<Highscore> = Highscore.fetchRequest()
        let objectCount = try? context.count(for: fetchRequest)
        
        guard objectCount == 0 else {
            //Já foi inicializado pela primeira vez
            return
        }
        
        let initialHighscore = Highscore(context: context)
        initialHighscore.highscore = 0
        
        do {
            try context.save()
        }
        catch{
            print("Initial data wasn't saved")
        }
    }
    
    func createHighscore(highscore: Int32) {
        let newHighscore = Highscore(context: context)
        newHighscore.highscore = highscore
        
        do {
            try context.save()
        } catch {
            print("Could not save data.")
        }
    }
}
