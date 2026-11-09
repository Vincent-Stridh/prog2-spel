require "gosu"

class Game < Gosu::Window
  def initialize
    @width = 800
    @height = 300
    super(@width,@height)

    self.caption = "Lunar Lander"
    
    @background = Gosu::Image.new("media/img/skybox-space-nebula.png")
    @lander = Gosu::Image.new("media/img/lander.png")
    #@plate = Gosu::Image.new("media/img/plate.png")

    @i = 0
    @lx = @width/2
    @ly = @height/2 + @height/5
    @px = @width/2
    @py = @height-(@height/8)
    @bx = 0
    @by = 0
    @angle = 0
    @rot = 0.05
    @font = Gosu::Font.new(24)
  end

  def update
    #@i %= 60
    @i += 1
    if @angle >= 360
      @angle = 0 
    end
    
    if @angle > 0 && @angle < 180
      @angle += (@rot*@i)/@angle
    end 

    if @angle < 360 && @angle > 180
      @angle -= (@rot*@i)/@angle
    end

    if Gosu.button_down?(Gosu::KB_D)
      @angle+=2
    end
    if Gosu.button_down?(Gosu::KB_A)
      @angle+=-2
    end
    
    if Gosu.button_down?(Gosu::KB_S)
      
    end
    if Gosu.button_down?(Gosu::KB_W)
      
    end
  end
  
  def draw
    @lander.draw_rot(@lx,@ly,z=1,@angle,center_x=0.5,center_y=0.5,scale_x=1,scale_y=1)
    #@plate.draw(@px,@py)
    @background.draw(@bx,@by)
    @font.draw_text("Angle: #{@angle.round(2)}", 10, 10, 10)
  end
end

Game.new.show