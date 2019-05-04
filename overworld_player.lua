player_color = "White"
speed = 1

function onLoad()
  player = getObjectFromGUID("9ff823")
  local pos = player.getPosition()
  Player[player_color].lookAt({
    position = pos,
    pitch = 180,
    yaw = 90,
    distance = 49,
  })
  Wait.time(|| Player[player_color].attachCameraToObject({object = player, offset = {0, 20, 0}}), 1)
end

function onUpdate() -- Controls. Should have 10.
  local pos = player.getPosition()

-- ILLEGAL COMBOS
  --Left-Right
  if left_key == true and right_key == true then
    player.AssetBundle.playLoopingEffect(0)
    left_key = false
    right_key = false
    return nil
  end

-- GOOD COMBOS
  -- Up
  if up_key == true and right_key ~= true and left_key ~= true then
    player.AssetBundle.playLoopingEffect(1)
    pos["z"] = pos["z"] + 0.03
    player.setPosition(pos)
    function onScriptingButtonUp(index, player_color)
      if index == 8 then
        up_key = false
        player.AssetBundle.playLoopingEffect(0)
      end
    end
  end

  -- Right
  if right_key == true and up_key ~= true and left_key ~= true then
    player.AssetBundle.playLoopingEffect(3)
    pos["x"] = pos["x"] + 0.03
    player.setPosition(pos)
    function onScriptingButtonUp(index, player_color)
      if index == 6 then
        right_key = false
        player.AssetBundle.playLoopingEffect(4)
      end
    end
  end

  -- Left
  if left_key == true and up_key ~= true and right_key ~= true then
    player.AssetBundle.playLoopingEffect(6)
    pos["x"] = pos["x"] - 0.03
    player.setPosition(pos)
    function onScriptingButtonUp(index, player_color)
      if index == 4 then
        left_key = false
        player.AssetBundle.playLoopingEffect(7)
      end
    end
  end

  -- Right-Up
  if right_key == true and up_key == true then
    player.AssetBundle.playLoopingEffect(2)
    pos["x"] = pos["x"] + 0.04
    pos["z"] = pos["z"] + 0.02
    player.setPosition(pos)
    function onScriptingButtonUp(index, player_color)
      if index == 6 then
        Wait.frames(function() right_key = false if up_key == false then player.AssetBundle.playLoopingEffect(5) end end, 1)
      end
      if index == 8 then
        Wait.frames(function() up_key = false if right_key == false then player.AssetBundle.playLoopingEffect(5) end end, 1)
      end
    end
  end
end

function onScriptingButtonDown(index, player_color)
  keydown = true
  if index == 8 then
    up_key = true
  end
  if index == 6 then
    right_key = true
  end
  if index == 4 then
    left_key = true
  end
end
