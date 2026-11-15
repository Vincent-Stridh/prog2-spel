require "gosu"

class Game < Gosu::Window
  def initialize
    @width = 1980
    @height = 1080
    super(@width,@height)

    self.caption = "Lunar Lander"
    
    @background = Gosu::Image.new("media/img/skybox-space-nebula.png")
    @lander = Gosu::Image.new("media/img/lander.png")
    #@plate = Gosu::Image.new("media/img/plate.png")


    #Lunar
    @lh = @lander.height
    @lw = @lander.width
    @lx = @width/2
    @ly = @height/2 + @height/5
    @lm = 1.0  #Kg
    @lvx = 0.0
    @lvy = 0.0

    #Landing plate
    @px = @width/2
    @py = @height-(@height/8)
    
    #Background
    @bx = 0
    @by = 0
    
    #Angular rotation velocity
    @angle = 0.0
    @omega = 0.0
    @torque = 0.0
    @i = (1.0/12)*@lm*(@lw**2 + @lh**2)

    #Thruster velocity
    @throttle = 0.0
    @max_thrust = 0.1
    @side_force = 5.0
    @gravity = 0.01

    @font = Gosu::Font.new(24)
  end

  def update
    #Thrusters
    if Gosu.button_down?(Gosu::KB_W)
      @throttle += 1.0 
    elsif Gosu.button_down?(Gosu::KB_S)
      @throttle -= 2.0 
    else
      @throttle -= 1.5
    end
    @throttle = @throttle.clamp(0.0, 100.0)

    @thrust = (@throttle / 50.0) * @max_thrust * @lm

    #Actual movement
    @ax = Gosu.offset_x(@angle, @thrust) / @lm
    @ay = Gosu.offset_y(@angle, @thrust) / @lm + @gravity

    @lvx += @ax
    @lvy += @ay
    @lx += @lvx
    @ly += @lvy

    #Side thrusters
    @torque = 0.0
    @torque += @side_force * (@lw/2.0) if Gosu.button_down?(Gosu::KB_D)
    @torque -= @side_force * (@lw/2.0) if Gosu.button_down?(Gosu::KB_A)

    @alpha = @torque/@i
    @omega += @alpha
    @omega *=  0.98
    @angle += @omega

    @angle %= 360
  end
  
  def draw
    @background.draw(@bx,@by)
    
    @lander.draw_rot(@lx,@ly,z=1,@angle,center_x=0.5,center_y=0.5,scale_x=1,scale_y=1)
    #@plate.draw(@px,@py)
    @font.draw_text("Angle: #{@angle.round(2)}°", 10, 10, 10)
    @font.draw_text("Rotation speed: #{(@omega * 60).round(2)} °/s", 10, 38, 10)
    @font.draw_text("Thruster: #{@throttle.round(2)}%", 10, 66, 10)
  end
end

Game.new.show