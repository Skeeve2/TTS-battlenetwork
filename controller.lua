#include Grid


-- RED is on the left, BLUE is on the right.

---------------------------
------ CONFIGURATION / INIT
---------------------------
grid_height = 3 -- Grid size
grid_width = 6

red_spawn_x = 2 -- Where the players spawn
red_spawn_y = 2
blue_spawn_x = 5
blue_spawn_y = 2

blue_area = 4 -- Controls how far players can move - should not overlap (but can!) Used for area-grabbing.
red_area = 3

delay = 0.15 -- delay between button presses

effectplayer_guid = "3c926f"

function onLoad(save_state)
  battlemat = Grid:new()
  effectplayer = getObjectFromGUID("3c926f")
  effectplayer.interactable = false
  battlemat_obj = getObjectFromGUID("9ccd8c")
  battlemat_obj_pos = battlemat_obj.getPosition()
end

---------------------------
------------------ CONTROLS
---------------------------

reset1 = 1
reset2 = 1

function onChat(message)
  if message == "a" then
    local hit = grenadeAttack("Blue")
    if hit == true then
      broadcastToAll("Hit!")
    else
      broadcastToAll("Missed!")
    end
  end
  if message == "b" then
    aiMettaur()
  end
end

function onScriptingButtonDown(index, player_color)
  if index == 8 then
    if player_color == "Blue" and reset2 == 1 then
      up(player_color)
      reset2 = 0
      Wait.time(|| Reseter(player_color), delay)
    end
    if player_color == "Red" and reset1 == 1 then
      up(player_color)
      reset1 = 0
      Wait.time(|| Reseter(player_color), delay)
    end
  end

  if index == 5 then
    if player_color == "Blue" and reset2 == 1 then
      down(player_color)
      reset2 = 0
      Wait.time(|| Reseter(player_color), delay)
    end
    if player_color == "Red" and reset1 == 1 then
      down(player_color)
      reset1 = 0
      Wait.time(|| Reseter(player_color), delay)
    end
  end

  if index == 4 then
    if player_color == "Blue" and reset2 == 1 then
      left(player_color)
      reset2 = 0
      Wait.time(|| Reseter(player_color), delay)
    end
    if player_color == "Red" then
      left(player_color)
      reset1 = 0
      Wait.time(|| Reseter(player_color), delay)
    end
  end

  if index == 6 then
    if player_color == "Blue" and reset2 == 1 then
      right(player_color)
      reset2 = 0
      Wait.time(|| Reseter(player_color), delay)
    end
    if player_color == "Red" and reset1 == 1 then
      right(player_color)
      reset1 = 0
      Wait.time(|| Reseter(player_color), delay)
    end
  end

  function Reseter(color)
    if color == "Red" then
      reset1 = 1
    end
    if color == "Blue" then
      reset2 = 1
    end
  end
end

function spawn()
  battlemat:spawn(grid_width, grid_height, 2.3, 0.1, 0.7, 2.6, 1.5, 0.5, battlemat_obj_pos)
end

function up(color)
  if color == "Blue" then
    local moved, x, y = objMove("Blue", 1, 0, true)
  end
  if color == "Red" then
    local moved, x, y = objMove("Red", 1, 0, true)
  end
end

function down(color)
  if color == "Blue" then
    local moved, x, y = objMove("Blue", - 1, 0, true)
  end
  if color == "Red" then
    local moved, x, y = objMove("Red", - 1, 0, true)
  end
end

function left(color)
  if color == "Blue" then
    local moved, x, y = objMove("Blue", 0, - 1, true)
  end
  if color == "Red" then
    local moved, x, y = objMove("Red", 0, - 1, true)
  end
end

function right(color)
  if color == "Blue" then
    local moved, x, y = objMove("Blue", 0, 1, true)
  end
  if color == "Red" then
    local moved, x, y = objMove("Red", 0, 1, true)
  end
end

function attack()
  local hit = basic_attack("Blue")
  if hit == true then
    broadcastToAll("Hit!")
  else
    broadcastToAll("Missed!")
  end
end

---------------------------
------------------- SCRIPTS
---------------------------
-- Utilities for attacks and misc.

function debug_spawn()
  red_spawn = battlemat[red_spawn_y][red_spawn_x]["zone"].getPosition()
  blue_spawn = battlemat[blue_spawn_y][blue_spawn_x]["zone"].getPosition()

  blue_spawn["y"] = blue_spawn["y"] - 1.05
  blue_spawn["z"] = blue_spawn["z"] + 0.63
  local params = {
    assetbundle = "http://cloud-3.steamusercontent.com/ugc/832512818124978502/D674868683DA55A701EEA79EEFF8B585AB765902/"
  }

  spawnObject({type = "Chess_Pawn", position = red_spawn, callback_function = function(obj) spawn_callback(obj, "Red") end})
  spawnObject({type = "Custom_Assetbundle", position = blue_spawn, callback_function = function(obj) spawn_callback(obj, "Blue") end}).setCustomObject(params)

  function spawn_callback(object_spawned, color)
    if color == "Red" then
      object_spawned.setName("Red")
      battlemat[red_spawn_y][red_spawn_x]["obj"] = object_spawned
    else
      object_spawned.setScale({5.05, 5.05, 5.05})
      object_spawned.setRotation({0.00, 0.03, 0.18})
      object_spawned.setName("Blue")
      battlemat[blue_spawn_y][blue_spawn_x]["obj"] = object_spawned
    end
   object_spawned.interactable = false -- Since these objects are not interactable we can use their name variable to store playername.
    object_spawned.setLock(true)
  end
end

-- Returns position in x, y coords
function findObj(obj) -- Finds an object with the given name.
  for x, y, v in battlemat:iterate() do
    if battlemat[x][y]["obj"] ~= nil then
      if battlemat[x][y]["obj"].getName() == obj then
        return x, y
      end
    end
  end
end

-- Moves an object
function objMove(name, x, y, smooth, mx, my, mz) -- Object movement, returns true if the object successfully moved and the objects new position
  local ox, oy = findObj(name) -- finds the object's position
  local px = ox + x
  local py = oy + y
  local moved = false
  local obj = battlemat[ox][oy]["obj"]

  if px > 0 and py > 0 and px <= grid_height and py <= grid_width then -- Prevention from going off grid and erroring
    if battlemat[px] ~= nil or battlemat[px][py] ~= nil then -- Checks to make sure tile isn't already occupied/missing a zone
      if battlemat[px][py]["obj"] == nil then -- But it wasn't
        if battlemat[ox][oy]["obj"].getName() == "Blue" or battlemat[ox][oy]["obj"].getName() == "Red" then
          if name == "Blue" and py < blue_area then
            return moved
          end
          if name == "Red" and py > red_area then
            return moved
          end
        end -- Extra line to prevent going of
        battlemat[ox][oy]["obj"] = nil -- Remove old obj
        battlemat[px][py]["obj"] = obj -- Add new instance

        local new_pos = battlemat[px][py]["zone"].getPosition()
        if mx ~= nil and my ~= nil and mz ~= nil then
          new_pos["x"] = new_pos["x"] + mx
          new_pos["y"] = new_pos["y"] + my
          new_pos["z"] = new_pos["z"] + mz
        end

        if smooth == true then
          obj.setPositionSmooth(new_pos, false, true)
        else
          obj.setPosition(new_pos)
        end
        moved = true
        return moved, px, py
      end
    else
      -- Nothing
    end
  else
    -- Nothing
  end
  return moved
end


-- Determines if an object is hit
function objHit(mode, hit_mode, x, y, radius, endX, endY, defender) -- x, y is always start. Change defender to something else
  local hit = false

  if mode == "line" then
    for x, y, v in battlemat:line(hit_mode, x, y, endX, endY) do
      if battlemat[x][y]["obj"] ~= nil then
        local obj = battlemat[x][y]["obj"]
        if obj.getName() == defender then
          hit = true
          return hit -- will cause only first found target to hit
        end
      end
    end
    return hit
  end

  if mode == "circle" then
    for x, y, v in battlemat:circle(hit_mode, x, y, radius) do
      if battlemat[x][y]["obj"] ~= nil then
        local obj = battlemat[x][y]["obj"]
        if obj.getName() == defender then
          hit = true
          return hit -- will cause only first found target to hit
        end
      end
    end
  end

  return hit
end


-- Chooses a distance based on attacker (blue or red.)
function reverser(attacker, rd, bd)
  if attacker == "Red" then
    distance = rd
    defender = "Blue"
    return defender, distance
  else
    distance = bd
    defender = "Red"
    return defender, distance
  end
end

function typecheck(attack, type)
  for i, b in Battlecards[attack]["Types"] do
    if b == type then
      return true
    end
  end
  return false
end

---------------------------
------------------- ATTACKS
---------------------------
-- Attacks return true if they hit
-- > = player, ~ projectile (delayed), * = hit zone, # = delayed hit zone
-- No > = same from anywhere

-- ------
-- >*****
-- ------
function basic_attack(attacker)
  local hit = false
  local defender, distance = reverser(attacker, 6, 0)
  local x, y = findObj(attacker)
  local hit = objHit("line", "rigid", x, y, nil, x, distance, defender)
  return hit
end

-- ---*--
-- >~***-
-- ---*--
function grenadeAttack(attacker)
  local distance
  local x, y = findObj(attacker)
  local hit = false
  local defender, distance = reverser(attacker, 3, - 3)
  local blast_zone = y + distance
  local hit = objHit("circle", "filled", x, blast_zone, 1, nil, nil, defender)
  return hit
end

-- ------
-- >#####
-- ------
function mettarAttack(attacker)
  local spawn = true
  local flash = nil
  local activate = false

  local function returntopos()
    flash.destruct()
    return nil
  end

  local function setpos(position, y, mx, my)
    position["y"] = position["y"] - 1

    if activate == true then
      returntopos()
      return nil
    end

    if spawn == true then
      local function spawn_callback_flash(obj)
        flash = obj
        flash.setColorTint({r=1, g=1, b=0})
        flash.interactable = false
        flash.setLock(true)
        spawn = false
      end
      spawnObject({type = "BlockSquare", position = position, scale = {2.59, 0.04, 1.33}, sound = false, callback_function = function(obj) spawn_callback_flash(obj) end})
    end

    if battlemat[mx][my]["obj"] ~= nil then
      activate = true
      print("Hit something!!!!!!")
    end

    if spawn == false then
      flash.setPosition(position)
      if y == 1 then
        Wait.time(|| returntopos(), 0.3)
      end
    end
  end

  local x, y = findObj(attacker)
  local i = 0
  for x, y, v in battlemat:line(rigid, x, y - 1, x, 1) do
    i = i + 1
    local cell_pos = battlemat[x][y]["zone"].getPosition()
    local cell_pos = battlemat[x][y]["zone"].getPosition()
    Wait.time(|| setpos(cell_pos, y, x, y), i * 0.5)
  end
end

---------------------------
------------------- CARDS
---------------------------

Battlecards = {
  ['HiCannon'] = {DMG = 40, CHUNK = 3, MB = 8, ELEMENT = "NULL", DESC = "Cannon attacks one enemy", FUNC = "basic_attack", ['Types'] = {"*", "a", "b", "c"}},
  ['MiniBomb'] = {DMG = 50, CHUNK = 3, MB = 5, ELEMENT = "NULL", DESC = "Throws a MiniBomb 3sq ahead", FUNC = "basic_attack", ['Types'] = {"*", "b", "g", "l"}}
}

---------------------------
------------------- AI
---------------------------
-- AI chooses either a random move or action every tick until asked to stop. (defined by the difficulty of said AI.
-- AI can only move 1 space per tick - if they don't, special action is required.

-- boolean: allow_directional controls whether the AI can move in any direction if the move fails. Returns true if it did ultimately move.
-- 1x movement for all regular movements.
function xmovement(name, allow_directional)
  y = math.random(0, 1)
  if y == 0 then y = -1 end
  local moved = objMove(name, y, 0, true, 0, - 1.05, 0.63)
  if moved == false then
    if y == -1 then
      y = 1
    else
      y = -1
    end
    local moved2 = objMove(name, y, 0, true, 0, - 1.05, 0.63)
    if moved2 == false then
      if allow_directional == true then
        ymovement(name)
      end
      return true -- Moved a different direction
    end
  end
  return false
end

function ymovement(name, allow_directional)
  y = math.random(0, 1)
  if y == 0 then y = -1 end
  local moved = objMove(name, 0, y, true, 0, - 1.05, 0.63)
  if moved == false then
    if y == -1 then
      y = 1
    else
      y = -1
    end
    local moved2 = objMove(name, 0, y, true, 0, - 1.05, 0.63)
    if moved2 == false then
      if allow_directional == true then
        xmovement(name)
        return false --
      end
      return true -- Couldn't move
    end
  end
  return false
end

function xtracker(name, target) -- Tracks an object and returns the X coordinate to move
  local x, y = findObj(target)
  local xb, yb = findObj(name)
  local m = 0
  if xb == 1 and x >= 2 then m = 1 end
  if xb == 2 and x == 3 then m = 1 end
  if xb == 2 and x == 1 then m = -1 end
  if xb == 3 and x <= 2 then m = -1 end
  return m
end

function aiMettaur(stop) -- Only moves up and down
  local function move()
    local moved = xmovement("Blue", true)
    if moved == true then
      attack() -- Attack if can't do anything else
      return nil
    end
  end

  local function movetoplayer()
    local m = xtracker("Blue", "Red")
    objMove("Blue", m, 0, true, 0, - 1.05, 0.63)
    Wait.time(|| aiMettaur(false), 2)
  end

  local function attack()
    local xb = findObj("Red")
    local x, y = findObj("Blue")
    if xb == x then
      battlemat[x][y]["obj"].AssetBundle.playTriggerEffect(0)
      mettarAttack("Blue")
      Wait.time(|| aiMettaur(false), 3)
    else
      movetoplayer()
    end
  end

  if stop == true then return nil end
  ac = math.random(0, 3)

  if ac == 0 then -- Random move
    move()
    Wait.time(|| aiMettaur(false), 3)
  end

  if ac > 0 then -- Move towards player
    attack()
  end
end
