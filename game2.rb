require "Gosu"
require 'rufus/lua/win' if Gem.win_platform?
require "rufus-lua"

class MapMaker
  def Map
    
  end
end

class Game < Gosu::Window
  def initialize
    super(800,600)
    @lua = Rufus::Lua::State.new
    @lua.eval(File.read('dungeon_generator.lua'))
  
    lua_table = @lua.eval("return generate_map(16, 16)")
    @map = lua_table.to_a.map { |row| row.to_a }
  end

  def update
    
  end

  def draw
    @character.draw_rot()
    @map.draw_rot()
  end
end

Game.new.show