# LimeRoll
3D library for LÖVE with no scaffolding

## Summarised plans
### Core Principals
#### KISS + "no scaffolding" architecture
- No enforced scene graph, entity hierarchy, or editor workflow
- Library is purely a rendering + asset + helper box
- The goal is to be as lazy as possible for future me, where I can just write game code once this is finished.
#### Works with or without ECS
- Game code can pass simple tables `{ modelID, textureID, transform }`, or full ECS component.
#### Vulkan Focus
- Compute shaders, indirect draw, HDR, mobile-ready as bonus
- Aim for 2014+ GPUs, like 960 (since I own one to test on, if it still works)
### Asset Management
#### Centralized asset loading/unloading/ref-counting by ID
- Game registers models/textures/sprite IDs; library handles GPU upload, streaming LODs, and auto unload when unused
- Solves: game code focuses on game, not infrastructure (scaffolding), never have to worry about memory or how textures are bind, it just works™
#### GLTF/GLB loader optimised for Croctile 3D
- Full support for Croctile's export (static meshes, baked UV animation, per-objkect metadata via extras)
- Solves: build sets/levels in Croctile without having to write a level editor
#### Texture + metadata auto-registration
- Have `texture.png` and `texture.png.meta` (JSON: frame time, animation loops, etc.)#
- Library automatically registers and managers animation states.
- Solves: removes boilerplate timer/animation from game code
#### Texture Arrays everywhere
- One array for body parts, clothing layer, angles, frames, normals.
- Flipped textures supported (only need to draw 5 directions [S, SE, E, NE, N] -> mirror for west)
- Textures can still add all 8 direction, but we can generate them if they don't exist
- Solves: reduction of art workload
### Rendering Pipeline
#### GPU-driven rendering (compute shader culling + indirect draw)
- One compute pass handles visibility, LOD selection, and indirect arguments for the entire scene.
- Chunks/terrain from Crocotile treated as regular models (fill culling or LOD)
- Solves: Don't have to care about optimization, it just works™
#### HDR lighting + post-process pipeline
- HDR lights + emissive textures.
- Lighting done entirely in post-process
- Solves: cyberpunk aesthetic
#### Billboard system
- 8 direction movement, normal maps, modular layers (body / shirt / legs / head)
- Soft billboards option
- Library handles state -> animation (pass sprite ID + state e.g. "walking" + facing direction + start time)
- Precompute sprite sheets, so each layer in the array has all the frames on (traverse the array for different direction)
- Solves: Art style vision + reusable for player + NPCs
#### Order independent transparency
- Weighted blended OIT
- Solves: clean windows, stained glass, semi-transparent textures without sorting headaches
#### SSAO
- Built-in screen-space occlusion
- Solves: gritty low-poly look in dark corners, space stations, and forest planet settings
#### Shadows
- Cascaded shadow maps for environment
- Projected blob shadows for billboards/sprites
- Optional soft character shadows (prototype muilti-sample blob to avoid spiky pixel art issues)
- Environment casts onto sprites; sprites do not cast back(?)
- Solves: grounded feel without breaking pixel-art style, goes for the modern look I'm envisioning
#### Planar reflections
- Simple planar mirrors for flat surfaces, where I want rain puddles, and maybe mirrored surfaces (see https://docs.vulkan.org/tutorial/latest/Building_a_Simple_Engine/Advanced_Topics/Planar_Reflections.html)
- Solves: nice reflections on spaceship, and rain puddles without expensive screen-space solution
### Animation & "alive" world
#### Library Managed animation system
- Texture animation (from .meta), vertex/skeleton animations for props (plants, grass, leaky pipes).
- Global timer + per-sprite start time
- Supports custom love.run particle tick / fixed Update
- Solves: AFK scenes feel alive with zero game-side animation code.
#### Built-in lightweight particle support
- Dripping water, rain, etc. (no generic "dust" spam)
- Solves: living environment details without pulling in a heavy particle sim
### Camera & Level Control
#### Rail-based camera + cinematic triggers
- Default top-down 45deg following character (Maybe experiment with camera dragging when player moves)
  * The 45deg is more of a goal, since it will be on a rail - it depends on the rail-to-character relation for that angle
- Camera rails and trigger points defined in GLTF extras or hot-reloadable JSON (I'm preferring JSON)
- Free-camera mode for prototyping to see if I like it more than the rails idea
- Solves: Player freedom, I can control where they look, frees up right stick/mouse for yoyo controls
#### Hot-reloading of level metadata
- JSON files (camera rails, lights, etc.) watched for last modified time.
- Automatically disabled when fused; optional command-line override.
- Solves: iteration without restarting the game
### Special Game Features (Yoyo)
#### Native yoyo rope system
- 3D edge-based pathfinding (Dijkstra on extrracted GLTF edges, not just vertices like in the 2D prototype)
- "memory" path so string stays taught and wraps naturally around columns for example
- yoyo itself rendered as 8-dir sprite with rotation sheet (speed of animation depends on yoyo state machine)
- Solves: core gameplay mechanic feels right and natural in 3D without hacky workarounds in game code
### Weather & Atmosphere
#### Rain + puddle system
- Decent (non-Rockstar) rain particles + decal puddles
- No screen rain streaks (player in inside the world, not behind a camera)
- Solves: World feels more alive, as the weather system isn't on/off, but has an effect on it's environment (puddles)
#### Custom sky/dyson-ring sun
- Procedural or cubemap sky with the solar-system lore star (dyson ring + central eye)
- Solves: matches my unique lore visually if the sun is ever visible
### Stretch / Future ideas
#### Full graphics thread offload
- Render + compute on seperate love thread
- UI would need a custom solution -> very far future
- Solves: potential CPU bottlenecks
#### Snow indentation
- Nice to have, but low priority
#### Grid vs free movement prototying
- built0in helpers to test 2x2 cell grid, 4/8dir movement vs free movement with 8 dir sprites
- solves: lets me decide what feels best for the player/character before committing too hard



# TODO
Just remembered, we need to support battles too! So, how I imagine battles (graphically) is that they occur in the world map, it transitions to basically that same location, but the level is scaled up - somewhat like how I imagine HD Neptunia Rebirth;1.

So, the player is in the level, and a battle occurs at the player character's position, some sort of transition into the battle, where it's the same level, and position, but scaled. There is some sort of invisible wall, to limit the battle field.
