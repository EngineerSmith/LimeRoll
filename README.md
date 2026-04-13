# LimeRoll
True to it's name. The 3D library idea has rolled into a 3D game framework built on top of love just for my game. Once started unopinionated, and quickly became opinionated.

## Summarised plans
### Core Principals
- KISS + no scaffolding architecture
- 'Purely' a rendering + asset + helper + lightweight simulation box (it's a big box)
- Goal: be as lazy as possible - writing game code once and never touch infrastructure again
- Works with or without ECS (pass tables or full ECS components)
- Vulkan-only focus (2014+ GPUs, test on GTX 960 4Gig, mobile-ready to explore android consoles)
  * If possible, aim for 960 2Gig - it should run amazing on my 3060 12Gig

### Asset Management
[ ] Centralized loading/unloading/ref-counting by ID + persistent state
[ ] GLTF/GLB loader for crocotile (static + baked UV anim + metadata)
[ ] Automatic texture + clothing + meta registration from file
[ ] Texture arrays everywhere + auto-flip for 8-dir sprites
[ ] Precomputed & cached character spritesheets (on-the-fly or loading-screen generation, saved to disk for cache) (Consider texture compression, and even compressing the cached to disk)

### Rendering Pipeline
[ ] GPU-driven (compute culling + indirect draw + static SSBO for levels)
[ ] HDR + post-process lighting
[ ] Billboard system with modular clothing + normal maps + library-managed state w/ animation
[ ] OIT, SSAO, cascaded shadows + projected blobs, planar reflections
[ ] Build-in lightweight particles (rain, drops, weather-driven)

### Animation & Alive World
[ ] Library-managed state machine (fully JSON-define, reusable, with conditions and transitions)
[ ] Dynamic prop / characters (single concept): static + dynamic activation. persistent state via uniqueID
[ ] GPU-driven animation via uniforms (windmills, turbines, weather effects)
[ ] Library owns timing (`love.timer.getTime`), no `LR.update(dt)`

### Camera & Level Control
[ ] Rail-based + cinematic triggers (all hot-reloadable JSON)
[ ] Battle system: "skybox camera" trick (gmod-style) - battles happens in a tiny separate scene rendered on top of the world map with the depth buffer to prevent close overlap.

### Special Game Features
[ ] Native single-plane yoyo rope (Need to explore how I want it to work)
[ ] Weather system that drives sky, puddles, GPU uniforms, and prop behaviour
[ ] Non-axis aligned 2x2 cell grid movement helpers

### Stretch / Future
[ ] Full graphics thread offload
[ ] Snow indentation
[ ] Grid vs free movement prototyping helpers

## Milestones
### 1 Billboard
[ ] Single(not-layered) 2D sprite billboard rendering in 3D space via indirect compute shader.
[ ] Hook up `love.timer.getTime`, animate the texture on the billboard.
[ ] Make the sprite controllable with [Baton](https://github.com/tesselode/baton). WASD / left stick (8 dir movement, idle/walk states via simple lua)

### 2 Dynamic Prop
[ ] Add a dynamic prop json + loading
[ ] Render it with GPU driven animation (wind turbine blades spinning via uniform)
[ ] Simple activation range (prop becomes "active" when near camera (configure so we can see it working at tiny ranges))

### 3 State machine
[ ] json-defined state machine with conditions/transitions
[ ] Walk/idle on the controllable billboard using new state machine
[ ] One interactive dynamic prop (e.g. automatic sliding door that opens when approached)

### TODO
Write more milestones later, once the above have been done
