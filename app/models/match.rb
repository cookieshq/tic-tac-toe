class Match < ApplicationRecord
  def self.create(uuid)
    if !REDIS.get("matches").blank?
      # Get the uuid of the player waiting
      opponent = REDIS.get("matches")

      Game.start(uuid, opponent)
      # Clear the waiting key as no one new is waiting
      REDIS.set("matches", nil)
    else
      REDIS.set("matches", uuid)
    end
  end

  def self.remove(uuid)
    if uuid == REDIS.get("matches")
      REDIS.set("matches", nil)
    end
  end

  def self.clear_all
    REDIS.del("matches")
  end
end
