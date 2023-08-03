//
//  ScoreController.swift
//  Mini Challenge 01
//
//  Created by Thiago Liporace on 03/08/23.
//

import Foundation
import CoreData

class ScoreController: ObservableObject {
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        createInitialScore()
    }
    
    func createInitialScore() {
        let fetchRequest: NSFetchRequest<Score> = Score.fetchRequest()
        let objectCount = try? context.count(for: fetchRequest)
        
        guard objectCount == 0 else {
            //Já foi inicializado pela primeira vez
            return
        }
        
        let initialScore = Score(context: context)
        initialScore.score = 0
        
        do {
            try context.save()
        }
        catch{
            print("Initial data wasn't saved")
        }
    }
    
    func createScore(score: Int32) {
        let newScore = Score(context: context)
        newScore.score = score
        
        do {
            try context.save()
        } catch {
            print("Could not save data.")
        }
    }
}
