--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
  splash_screen_animation()
  button_animation()
  play = true
end

local framebg = 0
local framebut = 0

function splash_screen_animation()
  if play == false then return nil end
  framebg = framebg + 1
  if framebg == 12 then framebg = 1 end
  UI.setAttribute("frame","image", tostring(framebg))
  Wait.time(splash_screen_animation, 0.11)
end

function button_animation()
  if play == false then return nil end
    framebut = framebut + 1
      if framebut == 3 then framebut = 1 end
    UI.setAttribute("frame2","image", "select" .. tostring(framebut))
    UI.setAttribute("frame3","image", "select" .. tostring(framebut))
    print ("b" .. tostring(framebut))
  Wait.time(button_animation, 0.75)
end

function startgame()
  local function stop()
  play = false
  end
  UI.hide("splashscreen")
  Wait.time(stop,1) -- Keeps animation playing until panel is fully gone
end
