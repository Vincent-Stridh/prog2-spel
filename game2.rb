require "Gosu"
require 'rufus/lua/win' if Gem.win_platform?
require "rufus-lua"

class MapMaker
  def Map
    
  end
end

class Game < Gosu::Window
  def initialize
    @lua = Rufus::Lua::State.new
    @lua.eval(File.read('dungeon_generator.lua'))
  end

  def update
    
  end

  def draw
    @character.draw_rot()
    @map.draw_rot()
  end
end

Game.new.show