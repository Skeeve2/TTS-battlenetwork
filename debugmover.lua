controller_guid ="939f58"

function onLoad()
  controller = getObjectFromGUID(controller_guid)
end

function up()
  controller.call("up")
end

function down()
  controller.call("down")
end

function left()
  controller.call("left")
end

function right()
  controller.call("right")
end

function attack()
  controller.call("attack")
end

function spawn_player()
  controller.call("debug_spawn")
end

function spawn()
  controller.call("spawn")
end
