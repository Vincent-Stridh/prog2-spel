-- dungeon generator
-- @johanpeitz

-- special thanks to
-- @jwaaaap for the initial idea

-- this cart draws a randomly
-- generated dungeon, and 
-- visualises the algorithm.

-- the basic idea is to spawn 
-- a bunch of rooms on top of
-- each other and then move
-- them around until they
-- don't overlap. a doorway to
-- a previous room is added 
-- as soon as a room finds a 
-- free slot.


-- parameters:

-- - wide_doors
--   chance for door to 
--   be full room width.
--   creates nice corridors.

-- - connectedness
--   chance for extra 
--   doors to appear. 
--   creates nice loops.

-- - deco_rate
--   chance for a room to
--   have decoration
--   creates pretty dungeons.

-- - big rooms
--   chance to spawn bigger 
--   rooms
--   creates interesting dungeons.

-- - block amnt/size
--   how much clutter to appear
--   on screen before generation.
--   gives the algorithm a
--   challenge and makes the 
--   dungeon look more organic.


function _init() 
 -- holds dungeon parameters
 params={}

 -- start first dungeon
 new_dungeon()
end

function new_dungeon()
 -- set up generation
 init_generation(get_random_params())
 
 -- generate 15-31 rooms
 generate(15+rnd(16))
end

function get_base_params()
 return {
  wide_doors=0.2,
  connectedness=0.3,
  deco_rate=0.3,
  big_rooms=0.2,
  block_amnt=0.1,
  block_size=0.5
 }
end

function get_random_params()
 return {
  wide_doors=rnd(),
  connectedness=rnd(),
  deco_rate=rnd(),
  big_rooms=rnd(),
  block_amnt=rnd(0.5),
  block_size=rnd(0.5)
 }
end


function init_generation(p)
 -- random color 
 local cs={14,12,11,9}
 color=cs[1+flr(rnd(#cs))]
 
 params={
  wide_doors=p.wide_doors,
  connectedness=p.connectedness,
  deco_rate=p.deco_rate,
  big_rooms=p.big_rooms,
  block_amnt=p.block_amnt,
  block_size=p.block_size
 }

 new_rooms={}
 rooms={}
 doors={}
 
 -- clear the map
 -- decorations are stored 
 -- in the lower half (y>15)
 for x=0,15 do
  for y=0,31 do
   mset(x,y,0)
  end
 end
 
 -- add blocking tiles
 for i=1,64 do
  if (rnd()<params.block_amnt) then
   local x=flr(rnd(16))
   local y=flr(rnd(16))
   mset(x,y,32)
   if (rnd()<params.block_size) then
    mset(x+1,y,32)
    mset(x-1,y,32)
   end
   if (rnd()<params.block_size) then
    mset(x,y-1,32)
    mset(x,y+1,32)
   end 
  end
 end
 
 -- clear an area for first room
 for x=6,8 do
  for y=6,8 do
   mset(x,y,0)
  end
 end
 
 -- initial room
 add_room(7,7,1,1)
 
end

function generate(amnt)
 -- add the rooms
 for i=1,amnt do
  spawn_room()
 end 
end

-- spawns a room in the middle
function spawn_room()
 if (rnd()<params.big_rooms) then
  add_room(7,7,2+flr(rnd(2)),2+flr(rnd(2)))
 else
  add_room(7,7,1,1)
 end
end


function _update()
 -- add more rooms
 if (btnp(🅾️)) generate(1)
 if (btnp(❎)) new_dungeon()
  
 -- move rooms without set
 -- location to see if they fit
 -- elsewhere
 
 -- increase tries to do more
 -- shuffling around per frame
 local tries=1 
 for i=1,tries do
  push_rooms()
 end
end

-- creates a door with a direction
function make_door(x,y,d)
 local door={}
 door.x=x
 door.y=y
 door.d=d
 door.wide=(rnd()<params.wide_doors)
 return door
end


function _draw()
 cls(6)
 
 pal(12,color)
 -- draw set rooms
 map(0,0,0,0,16,16) 
 -- draw decoration
 map(0,16,0,0,16,16) 
 
 -- draw shadow
 for y=0,15 do
  for x=0,15 do
   if (mget(x,y)>0 and mget(x,y)<32) then
    if (mget(x,y+1)==0 or mget(x,y+1)>31) then
     line(x*8,y*8+8,x*8+7,y*8+8,13)
     line(x*8,y*8+9,x*8+7,y*8+9,5)
    end
   end
  end
 end
  
 -- draw doors
 for d in all (doors) do
  draw_door(d)
 end
 
 -- draw new rooms
 for r in all (new_rooms) do
  rectfill(r.x*8,r.y*8,
   (r.x+r.w)*8-1,(r.y+r.h)*8-1,
   13)
  rect(r.x*8,r.y*8,
   (r.x+r.w)*8-1,(r.y+r.h)*8-1,
   5)
 end
 
 -- draw a simple visualisation
 -- of the params
 rect(1,1,11,11,13)
 rect(1,1,11,10,1)
 rectfill(2,2,10,9,7)
 line(3,3,3+7*params.big_rooms,3,9)
 line(3,4,3+7*params.wide_doors,4,8)
 line(3,5,3+7*params.connectedness,5,11)
 line(3,6,3+7*params.deco_rate,6,12)
 line(3,7,3+7*params.block_amnt,7,5)
 line(3,8,3+7*params.block_size,8,13)

 -- keys
 printo("🅾️ add room",2,113,7,13)
 printo("❎ new dungeon",2,121,7,13)

 -- debug
 -- print(#new_rooms.."/"..(#new_rooms+#rooms).." "..flr(stat(1)*100).."%",1,122,7)
 printo("@johanpeitz",83,121,6,13) 
end

-- adds a room with the specified size
function add_room(x,y,w,h)
 local r={}
 r.x=x
 r.y=y
 r.w=w
 r.h=h
 r.id=(rnd()<params.deco_rate and get_rnd_deco() or 1)
 add(new_rooms,r)
end

-- returns a random decoration
-- from the spritesheet
function get_rnd_deco()
 return 1+flr(rnd(8)+1)
end

-- returns the room at position
-- or nil
function get_room_at(x,y)
 for r in all(rooms) do
  if (x>=r.x and y>=r.y and x<r.x+r.w and y<r.y+r.h) return r
 end
 
 return nil
end

-- removes a room from the map
function remove_room(r)
  for x=r.x,r.x+r.w-1 do
   for y=r.y,r.y+r.h-1 do
    mset(x,y,0)
    mset(x,y+16,0)
   end
  end
end

-- tries to place room r 
-- on the map
-- returns true if successful
function place_room(r)
 -- 1x1 room
 if (r.w==1 and r.h==1) then
  if (mget(r.x,r.y)==0) then
   mset(r.x,r.y,1)
   mset(r.x,r.y+16,r.id)
   add(rooms,r)
   del(new_rooms,r)
   return true
  end
 else
  -- bigger room
  local fits=true
  for x=0,r.w-1 do
   for y=0,r.h-1 do
    if (mget(r.x+x,r.y+y)!=0) fits=false
   end
  end
  
  local pairs={}
  if (fits) then
   for x=r.x,r.x+r.w-1 do
    for y=r.y,r.y+r.h-1 do
     mset(x,y,20)
     add(pairs,{x=x,y=y})
    end
   end
   for x=r.x,r.x+r.w-1 do
    mset(x,r.y,17)
   end
   for x=r.x,r.x+r.w-1 do
    mset(x,r.y+r.h-1,23)
   end
   for y=r.y,r.y+r.h-1 do
    mset(r.x,y,19)
   end
   for y=r.y,r.y+r.h-1 do
    mset(r.x+r.w-1,y,21)
   end
   
   mset(r.x,r.y,16)   
   mset(r.x+r.w-1,r.y,18)
   mset(r.x,r.y+r.h-1,22)
   mset(r.x+r.w-1,r.y+r.h-1,24)
   add(rooms,r)
   del(new_rooms,r)
   
   -- decorate
   local dr=params.deco_rate
   for i=1,(r.h+r.w) do
    if (rnd()<dr) then 
     local p=pairs[flr(rnd(#pairs))+1]
     mset(p.x,p.y+16,get_rnd_deco())
     del(pairs,p)
     dr*=0.5
    end
   end

   return true
  end
 end
 
 return false
end

-- push all non set rooms in
-- random directions to see if 
-- they can be placed
function push_rooms()
 for r in all(new_rooms) do
  if (place_room(r)) then
   -- add doors
   -- get candidates
   local nds={}
   for x=r.x,r.x+r.w-1 do
    -- top
    if (get_room_at(x,r.y-1)!=nil) then
     add(nds,make_door(x,r.y,1))
    end
    -- btm
    if (get_room_at(x,r.y+r.h)!=nil) then
     add(nds,make_door(x,r.y+r.h-1,3))
    end
   end
   for y=r.y,r.y+r.h-1 do
    -- left
    if (get_room_at(r.x-1,y)!=nil) then
     add(nds,make_door(r.x,y,4))
    end
    -- right
    if (get_room_at(r.x+r.w,y)!=nil) then
     add(nds,make_door(r.x+r.w-1,y,2))
    end
   end
   
   if (#nds>0) then    
    -- add one door
    local id=flr(rnd(#nds))+1
    add(doors,nds[id])
    del(nds,nds[id])
   
    -- add some doors
    for d in all(nds) do
     if (rnd()<params.connectedness) add(doors,d)  
    end  
   else
    if (r.h>1 and r.w>1) then
     -- no doors, kill room
     remove_room(r)
     del(rooms,r)
    end
   end 
  else
   -- move room
   r.d=rnd_dir()
   if (mget(r.x+r.d.x,r.y+r.d.y)<32) then
    r.x+=r.d.x
    r.y+=r.d.y
   end
  end
 end
end

-- draws a door
function draw_door(d)
 local c1=7
 local c2=6
 
 local rx=d.x*8
 local ry=d.y*8
 
 if (d.wide) then
  if (d.d==1) rectfill(rx+1,ry-1,rx+6,ry+1,c1)
  if (d.d==3) rectfill(rx+1,ry+7,rx+6,ry+9,c1)
  if (d.d==2) then
   rectfill(rx+7,ry+1,rx+8,ry+6,c1)
   line(rx+7,ry+1,rx+8,ry+1,c2)
  end
  if (d.d==4) then
   rectfill(rx-1,ry+1,rx,ry+6,c1)
   line(rx-1,ry+1,rx,ry+1,c2)
  end
 else
  if (d.d==1) rect(rx+3,ry-1,rx+4,ry+1,c1)
  if (d.d==3) rect(rx+3,ry+7,rx+4,ry+9,c1)
  if (d.d==2) then
   rect(rx+7,ry+3,rx+8,ry+4,c1)
   line(rx+7,ry+3,rx+8,ry+3,c2)
  end
  if (d.d==4) then
   rect(rx-1,ry+3,rx,ry+4,c1)
   line(rx-1,ry+3,rx,ry+3,c2)
  end
 end
end

-->8
-- helpers

function rnd_dir()
 local d={x=0,y=0}
 local r=rnd()
 if (r<0.25) then 
  d.x=1
 elseif (r<0.5) then
  d.x=-1
 elseif (r<0.75) then
  d.y=1
 else
  d.y=-1
 end
 return d
end

function swap_dir(d)
 if (d==1) return 3
 if (d==2) return 4
 if (d==3) return 1
 return 2
end

function get_dir(d)
 local v={x=0,y=0}
 if (d==1) then 
  v.y=-1
 elseif (d==2) then
  v.x=1
 elseif (d==3) then
  v.y=1
 else
  v.x=-1
 end 
 return v
end

function printo(str,x,y,c1,c2)
 for px =-1,1 do
  for py =-1,1 do
   print(str,x+px,y+py,c2)
  end
 end
 print(str,x,y,c1)
end 