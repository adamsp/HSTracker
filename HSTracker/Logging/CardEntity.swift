/*
 * This file is part of the HSTracker package.
 * (c) Benjamin Michotte <bmichotte@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Created on 18/02/16.
 */

class CardEntity: Equatable, CustomStringConvertible {

    var cardId: String?
    var entity: Entity?

    var turn: Int {
        willSet(newTurn) {
            prevTurn = self.turn
        }
    }
    var prevTurn = -1
    var cardMark: CardMark {
        get {
            if cardId == CardIds.NonCollectible.Neutral.TheCoin || cardId == CardIds.NonCollectible.Neutral.GallywixsCoinToken {
                return .Coin
            }
            if returned {
                return .Returned
            }
            if created || stolen {
                return .Created
            }
            if mulliganed {
                return .Mulliganed
            }
            return .None
        }
    }
    var discarded: Bool = false
    var returned: Bool = false
    var mulliganed: Bool = false
    var stolen: Bool = false

    var inHand: Bool {
        return entity != nil && entity!.getTag(GameTag.ZONE) == Zone.HAND.rawValue
    }
    var inDeck: Bool {
        return entity != nil && entity!.getTag(GameTag.ZONE) == Zone.DECK.rawValue
    }
    var unknown: Bool {
        return cardId == nil || cardId!.isEmpty && entity == nil
    }

    private var _created: Bool = false
    var created: Bool {
        get {
            return _created && (entity == nil || entity!.id > 67)
        }
        set {
            _created = newValue
        }
    }

    init(cardId: String? = nil, entity: Entity? = nil) {
        if let entity = entity {
            self.cardId = entity.cardId
        } else {
            self.cardId = cardId
        }
        self.entity = entity
        self.turn = -1
    }

    func reset() {
        self.created = false
        self.cardId = nil
    }

    static let zonePosComparison: ((CardEntity, CardEntity) -> Bool) = {
        let v1 = $0.entity?.getTag(GameTag.ZONE_POSITION) ?? 10
        let v2 = $1.entity?.getTag(GameTag.ZONE_POSITION) ?? 10
        return v1 < v2
    }

    func update(entity: Entity?) {
        if entity == nil {
            return
        }
        if self.entity == nil {
            self.entity = entity
        }
        if self.cardId == nil || self.cardId!.isEmpty {
            self.cardId = entity!.cardId
        }
    }

    var description: String {
        var description = "<\(NSStringFromClass(self.dynamicType)): "
            + "entity=\(self.entity)"
            + ", cardId=\(cardName(self.cardId))"
            + ", turn=\(self.turn)"

        if let entity = self.entity {
            description += ", zonePos=\(entity.getTag(GameTag.ZONE_POSITION))"
        }
        if self.cardMark != CardMark.None {
            description += ", cardMark=\(self.cardMark)"
        }
        if self.discarded {
            description += ", discarded=true"
        }
        if self.created {
            description += ", created=true"
        }
        description += ">"

        return description
    }

    func cardName(cardId: String?) -> String {
        if let cardId = cardId {
            if let card = Cards.byId(cardId) {
                return "[\(card.name) (\(cardId))]"
            }
        }
        return "N/A"
    }
}

func == (lhs: CardEntity, rhs: CardEntity) -> Bool {
    if lhs.entity != nil {
        if lhs.entity == rhs.entity {
            return true
        }
        if lhs.entity!.cardId == rhs.entity!.cardId {
            return true
        }
    }
    if lhs.cardId != nil {
        if lhs.cardId == rhs.cardId {
            return true
        }
    }
    return false
}
