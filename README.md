# 🌌 Hollow Knight Movement recreated in Godot 🗡️

## ⚠️ Disclaimer
To Team Cherry, the creators of *Hollow Knight* and *Silksong*: I sincerely apologize for using any extracted sprites or assets from *Hollow Knight* in this project. 🙏 This is purely a coding exercise to replicate the game's movement mechanics as a learning experience. I am not an artist and have no intention of claiming or redistributing your incredible work. This project is for educational purposes only, and I deeply respect your work. 💖

## 🌟 Overview
This project is a recreation of the player movement mechanics from *Hollow Knight*, a critically acclaimed 2D Metroidvania game, built using the **Godot Engine (4.x)**. 🎮 The goal is to emulate the smooth, precise, and responsive movement of the Knight (and inspired by Hornet from *Silksong*), including features like 8-way movement, jumping, dashing, wall sliding, and wall jumping. This is a coding-focused project to study 2D platformer mechanics, with a focus on achieving the tight, fluid feel of *Hollow Knight*. 🐞

## ✨ Features
- **8-Way Movement** 🏃: Smooth horizontal movement with input-based direction. (As of the first upload it just goes left/right w/Jump & slide mechanics)
- **Jumping** 🦗: Precise, snappy jumps with a *Hollow Knight*-like arc (tuned with gravity ~2000 pixels/s² and jump velocity ~-600).
- **Dashing** 💨: A quick burst of speed in the facing direction, with a lock on vertical movement.
- **Wall Sliding** 🧗: Slow descent when holding toward a wall while falling.
- **Wall Jumping** 🦘: Dynamic leaps off walls with directional pushback.
- **Sprite Flipping** 🔄: The player sprite flips horizontally based on movement direction.
- **Animation System** 🎥: State-based animations using `AnimatedSprite2D` for idle, run, jump (rise/fall), dash, wall slide, and wall jump.
- **Camera System** 📷: A *Hollow Knight*-style camera with smooth tracking, room-based limits, and dynamic zoom.

## 🛠️ Technical Details
- **Engine**: Godot 4.x (GDScript) 🚀
- **Nodes**:
  - `CharacterBody2D` for physics-based movement.
  - `AnimatedSprite2D` for frame-based animations from sprite sheets.
  - `Camera2D` for smooth player tracking and room transitions.
- **Physics** ⚖️:
  - Gravity: ~2000 pixels/s² to match *Hollow Knight*'s snappy fall (approximated from Unity's ~-30 to -40).
  - Jump Height: Tuned to cover ~2-3 sprite heights, similar to the Knight.
- **Animation** 🎞️:
  - Uses a state machine (`enum`) to switch between animations (e.g., `idle`, `run`, `jump_rise`, `dash`).
  - Animations are driven by a sprite sheet (12 FPS for a 12-frame animation lasts 1.0 second, as calculated).
  - Sprite flipping via `flip_h` for directional facing.
