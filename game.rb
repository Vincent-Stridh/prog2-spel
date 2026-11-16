require "gosu"

class Game < Gosu::Window
  def initialize
    @width = 1000
    @height = 500
    #if Gosu.available_width < @width
    #  @width = Gosu.available_width
    #end
    #if Gosu.available_height < @height
    #  @height = Gosu.available_height
    #end
    super(@width,@height)

    self.caption = "Lunar Lander"
    
    @background = Gosu::Image.new("media/img/skybox-space-nebula.png")
    @lander = Gosu::Image.new("media/img/lander.png")
    @plate = Gosu::Image.new("media/img/plate.png")


    #Lunar
    @lh = @lander.height
    @lw = @lander.width
    @org_x = @lx = @width/2
    @org_y = @ly = @height/2 #+ @height/5
    @lm = 1.0  #Kg
    @org_vx = @lvx = 0.0 
    @org_vy = @lvy = 0.0 
    @lock = false
    @n = 1

    #Landing plate
    @px = @width/2
    @py = @height-(@height/16.666666666666)
    @floor_height = 50
    
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
    @max_thrust = 0.05
    @side_force = 5.0
    @org_grav = @gravity = 0.01

    @font = Gosu::Font.new(24)
  end

  def update
    @distance_y = @ly - @py
    @distance_y = @distance_y.abs

    @distance_x = @lx-@px
    @distance_x = @distance_x.abs

    #If the lander has landed on the landing plate
    if @distance_y <= 65 && @distance_x <= 175
      @lvy = @gravity = @omega = 0
      @n += 0.1
      if @lvx > 1
        @lvx = @lvx / @n 
      elsif @lvx <= 1
        @lvx = 0
      end
      @lock = true
    else
      @n=0
      @lock = false
      @gravity = @org_grav
    end

    #Reset
    if Gosu.button_down?(Gosu::KB_R)
      @lx = @org_x
      @ly = @org_y
      @lvx = @org_vx
      @lvy = @org_vy
      @angle = 0
      @omega = 0
    end

    #Thrusters
    if Gosu.button_down?(Gosu::KB_W)
      @throttle += 1.0 
    elsif Gosu.button_down?(Gosu::KB_S)
      @throttle -= 10.0 
    else
      @throttle -= 1.5
    end
    @throttle = @throttle.clamp(0.0, 100.0)

    @thrust = (@throttle / 100.0) * @max_thrust * @lm

    #Moveset
    @ax = Gosu.offset_x(@angle, @thrust) / @lm
    @ay = Gosu.offset_y(@angle, @thrust) / @lm + @gravity
    
    @lvx += @ax
    @lvy += @ay
    @lx += @lvx
    @ly += @lvy

    @speed = @lvx + @lvy
    @speed = @speed.abs
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
    @base = 10
    @mult = 28
    @background.draw(@bx,@by)
    
    @lander.draw_rot(@lx,@ly,z=1,@angle,center_x=0.5,center_y=0.5,scale_x=1,scale_y=1)
    @plate.draw_rot(@px,@py, z=1,center_x=0.5,center_y)
    @font.draw_text("Angle: #{@angle.round(2)}°", 10, @base, 10)
    @font.draw_text("Lock: #{@lock}", 10, @base+@mult,10)
    @font.draw_text("Rotation speed: #{(@omega * 60).round(2)} °/s", 10, @base+@mult*2, 10)
    @font.draw_text("Thruster: #{@throttle.round(2)}% = #{@speed.round(2)}", 10, @base+@mult*3, 10)
    @font.draw_text("", 10, @base+@mult*4, 10)
    @font.draw_text("Lander position:", 10, @base+@mult*5, 10)
    @font.draw_text("X= #{@lx.round(2)}", 10, @base+@mult*6, 10)
    @font.draw_text("Y= #{@ly.round(2)}", 10, @base+@mult*7, 10)
    @font.draw_text("", 10, @base+@mult*8, 10)
    @font.draw_text("Lander position:", 10, @base+@mult*9, 10)
    @font.draw_text("X= #{@px.round(2)}", 10, @base+@mult*10, 10)
    @font.draw_text("Y= #{@py.round(2)}", 10, @base+@mult*11, 10)
    @font.draw_text("Distancer_x: #{@distance_x.round(2)}", 10, @base+@mult*12, 10)
    @font.draw_text("Distancer_y: #{@distance_y.round(2)}", 10, @base+@mult*13, 10)
    @font.draw_text("N: #{@n}", 10, @base+@mult*14, 10)
  end
end

Game.new.show