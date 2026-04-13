local LR = require("libs.LimeRoll")

LR.registerAssets("assets/") -- scans clothing/, characters/, npcs/, levels/, weather/, stateMachines/, etc.

LR.setWeather("rain") -- Sets to weather/rain.json + sky + shader + puddle logic

-- Register custom transition conditions for LR state machines
LR.registerCondition("onSteppingStone", function(entity) ... end)
LR.registerCondition("yoyoCaught",      function(entity) ... end)
LR.registerCondition("isPlayer",        function(entity) return entity:has("player") end)

-- Streaming callbacks (Enter view refers to the chunk being loaded)
LR.onDynamicPropsEnterView(function(newProps) -- props should have a unique ID, that is the same on all loads, even on hot-reload.
  for _, propDef in ipairs(newProps) do
    if propDef.isCharacter then
      -- character caching, so we can save their state when we stay within the same level
      if not characters[propDef.id] then
        local e = Concord.entity(world):give("dynamicProp", propDef):give("character")
        characters[propDef.id] = e
      else
        world:addEntity(characters[propDef.id])
      end
    else
      Concord.entity(world):give("dynamicProp", propDef)
    end
    -- Used to load a prop's save data
    LR.setPersistentState(propDef.id, state) -- state being a table
  end
end)

LR.onDynamicPropsLeaveView(function(oldDefs)
  for _, propDef in ipairs(oldDefs) do
    if propDef.type == "character" then
      local e = characters[propDef.id]
      if e and e:hasWorld() then
        e:destroy() -- Keep in character table, so we can add it back as an entity
      end
    else
      -- Save current dynamic prop state, so it can be reloaded
      local state = LR.getPersistentState(propDef.id)
      -- LR.setPersistentState(propDef.id, state) --< I like this idea more than `LR.loadDynamicPropDefinition
    end
  end
end)

-- Load a dynamic prop definition that wasn't part of assets to self-register
local playerDef = LR.loadDynamicPropDefinition("save/player-looks.json")
-- or "characters/player-template.json" for new saves where it isn't part of assets

LR.setPersistentState(playerDef.id, state) -- so we can save player clothes this way, and just always load default first?

-- In love.draw
LR.drawLevel("space_station") -- environment + weather sky + puddles + reflections

-- Draw everything via ECS (dynamic props + characters)
for _, e in ipairs(dynamicPropPool) do -- this bad, way too many GPU calls, put it in a SSBO, and send updates to that.
  LR.drawDynamicProp(e.dynamicProp.id, e.transform, e.dynamicProp.currentState, partialTick)
end

-- This is bloat for now, best focus on drawDynamicProp for all characters, then look at player specific state drawings, see below for reason/ideas
-- Player special case for layered draw for yoyo animation blend (e..g hand states for catch and throw while walking)
LR.drawCharacterLayered(playerDef.id, player.transform, {
  baseState = player.baseState,  -- legs + body
  overlayState = { state = "catch_yoyo", args = { progress = 0.7 } }
})
-- Maybe it can be made more simple? Could we tell the player's character to precompute the
-- spritesheets, BUT don't add any hands! So, then when we draw the player, we check the hand state
-- draw the hands, then draw the normal spritesheet over it - we would need to track the hand position to arm.
-- Maybe I'm over thinking this? It feels a problem I'm solving before I even have character rendering working


-- Pass rope table, this is what holds it's point memory of where the rope has travelled so far.
LR.drawYoyoRope(rope, player.handPos, yoyo.pos, "space_station")


----
--[[
Clothing (e.g. shirt-68.json)
{
  "typeDef": "clothing",
  "category": "shirt",
  "flippable": true,
  "normalMap": "shirt-68_n.png",
  "animationSpeedMultiplier": 1.0
}

Texture meta (e.g. shirt-68.png.meta)
{
  "padding": { "x": 1, "y": 1 },
  "dimensions": { "width": 48, "height": 48 },
  "rows": [ { "dir": "north", "y": 0, "frames": 6 }, ... ]
}

Reuseable state machine (e.g. wander.json)
{
  "typeDef": "stateMachine",
  "default": "idle",
  "states": {
    "idle": { "anim": "idle", "speed": 1.0, "loop": true },
    "walking": { "anim": "walk", "speed": 1.0, "loop": true },
    "on_stone": { "anim": "hop", "speed": 1.2, "loop": false, "onFinish": "walking" },
    "randomIdleVariant": { "anim": "stretch", "speed": 1.0, "loop": false, "oneShot": true }
  },
  "transitions": [
    { "from": "walking", "to": "on_stone", "condition": "onSteppingStone" },
    { "from": "idle", "to": "randomIdleVariant", "condition": "randomChance", "chance": 0.1 }
  ]
}

Weather (e.g. rain.json)
{
  "typeDef": "weather",
  "parent": "clear", // optional hierarchy
  "sky": { "cubemap": "rain_sky.hdr" }, // We should be able to phase it from the previous if there was a previous
  "shader": "shaders/rain.glsl",
  "behaviour": { "puddleRaiseSpeed": 0.8, "particleCount": 800 }
}

Dynamic prop
{
  "typeDef": "dynamicProp",
  "uniqueID": "button_01",
  "stateMachine": "button_idle",
  "model": "level_node_name",
  "isCharacter": false,
  "interaction": {
    "stateMachine": "press_button",
    "condition": "isPlayer", -- uses same funcs that state machine can
    "offset": { "x": 0, "y": 0.3, "z": 0 }
  }
}

Character
{
  "typeDef": "dynamicProp",
  "uniqueID": "priest_01",
  "stateMachine": "wander",
  "isCharacter": true,
  "clothing": { "body": "body-6", "shirt": "shirt-99", ... }
}


]]