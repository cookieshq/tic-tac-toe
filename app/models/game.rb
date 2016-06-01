class Game < ApplicationRecord
  def self.start(player1, player2)
    # Randomly choses who gets to be noughts or crosses
    cross, nought = [player1, player2].shuffle

    # Broadcast back to the players subscribed to the channel that the game has started
    ActionCable.server.broadcast "player_#{cross}", {action: "game_start", msg: "cross"}
    ActionCable.server.broadcast "player_#{nought}", {action: "game_start", msg: "nought"}

    # Store the details of each opponent
    REDIS.set("opponent_for:#{cross}", nought)
    REDIS.set("opponent_for:#{nought}", cross)
  end

  def self.withdraw(uuid)
    if winner = opponent_for(uuid)
      ActionCable.server.broadcast "player_#{winner}", {action: "opponent_withdraw"}
    end
  end

  def self.opponent_for(uuid)
    REDIS.get("opponent_for:#{uuid}")
  end

  def self.take_turn(uuid, move)
    opponent = opponent_for(uuid)

    ActionCable.server.broadcast "player_#{opponent}", {action: "take_turn", move: move['data']}
  end

  def self.new_game(uuid)
    opponent = opponent_for(uuid)

    ActionCable.server.broadcast "player_#{opponent}", {action: "new_game"}
  end
end
