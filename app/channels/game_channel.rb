# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
     stream_from "player_#{uuid}"
     Match.create(uuid)
  end

  def unsubscribed
    Game.withdraw(uuid)
    Match.remove(uuid)
  end

  def take_turn(data)
    Game.take_turn(uuid, data)
  end

  def new_game()
    Game.new_game(uuid)
  end
end
