//
//  GameViewModel.swift
//  Rune
//
//  Created by james bouker on 11/6/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

class GameViewModel: StoreSubscriber {

    // MARK: - Variables
    weak var scene: GameScene?
    var playerAction: PlayerAction = .pressed {
        didSet {
            actionQueue.append(playerAction)
            if actionQueue.count == 1 && !isAnimating {
                executeFirstAction()
            }
        }
    }

    private var actionQueue = [PlayerAction]()
    private var isAnimating = false

    // MARK: - Init!
    init(_ scene: GameScene) {
        self.scene = scene
        store.subscribe(self)
    }

    private func executeFirstAction() {
        isAnimating = true
        let action = actionQueue.removeFirst()
        store.dispatch(action)
    }

    // MARK: - Store Subscriber
    func newState(state _: GameState) {
        guard let scene = self.scene else {
            return
        }

        if scene.player != nil {
            //            self.action.value = diff(to: state)
        } else {
            //            scene.layout(state)
            //            self.completedTransition()
        }
    }

    func completedTransition() {
        isAnimating = false

        if actionQueue.count > 0 {
            executeFirstAction()
        }
    }
}
