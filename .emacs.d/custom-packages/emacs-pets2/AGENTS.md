# AGENTS.md

This document outlines the structure and components of the emacs-pets project for future feature implementation and maintenance.

## Project Overview

**emacs-pets** is an Emacs package that displays and animates sprites on the Emacs modeline, inspired by the VS Code extension vs-code pets. The package provides an animated virtual pet that wanders left and right on the modeline, occasionally pausing to idle.

## Codebase Structure

### Main Files

1. **emacs-pets.el**: The core Emacs Lisp file containing all the functionality.
   - Defines customization options for pet behavior and appearance.
   - Implements sprite handling, animation, and modeline integration.
   - Provides a minor mode `emacs-pets-mode` to toggle the pet on/off.

2. **Sprite Files**: Text files containing pixel art for different pet states.
   - `duck.txt`, `duck-idle-1.txt`, `duck-idle-2.txt`, `duck-walk-1.txt`, etc.
   - Each file represents a frame of animation for the pet.

3. **README.md**: Documentation for users, including installation and configuration instructions.

4. **LICENSE**: License information for the project.

### Key Components

#### Customization Variables

- `emacs-pets-tick-interval`: Seconds each animation frame is displayed; controls walk speed and all state timing. Restart timer on change when mode active.
- `emacs-pets-field-width`: Total character width of the pet display area in the modeline.
- `emacs-pets-step-size`: Columns the pet moves on each walking frame. Fractions allowed for sub-column movement.
- `emacs-pets-idle-chance`: Probability of the pet entering an idle state.
- `emacs-pets-idle-duration`: Duration of the idle state in seconds.
- `emacs-pets-scale`: Scale factor for the pet sprite.
- `emacs-pets-sprite-file`: Path to a custom sprite file.
- `emacs-pets-sprite-files`: List of sprite files for walk-cycle animation.
- `emacs-pets-idle-files`: List of sprite files for idle animation.
- `emacs-pets-sleep-files`: List of sprite files for idle animation.
- `emacs-pets-sprite-colors`: Color map for sprites.

#### Internal State Variables

- `emacs-pets--position`: Current horizontal position of the pet in canonical columns (may be fractional).
- `emacs-pets--direction`: Current movement direction (left or right).
- `emacs-pets--state`: Current state of the pet (walking or idle).
- `emacs-pets--idle-counter`: Remaining seconds of idle state.
- `emacs-pets--timer`: Timer driving the animation loop.
- `emacs-pets--walk-frames`: Vector of walk frames for animation.
- `emacs-pets--frame-index`: Index into `emacs-pets--walk-frames` for the current walk frame.
- `emacs-pets--idle-frames`: Vector of idle frames for animation.
- `emacs-pets--idle-frame-index`: Index into `emacs-pets--idle-frames` for the current idle frame.

#### Core Functions

- `emacs-pets--move`: Advances the pet by `emacs-pets-step-size` in the current direction.
- `emacs-pets--space`: Builds a mode-line pad of N canonical columns via `space :width` (number, not pixels).
- `emacs-pets--tick`: Advances one animation frame.
- `emacs-pets--build-xpm`: Builds XPM data string from rows and colors.
- `emacs-pets--mirror-rows`: Mirrors rows horizontally.
- `emacs-pets--scale-rows`: Scales rows by a factor.
- `emacs-pets--load-sprite-file`: Loads a sprite file and returns pixel rows.
- `emacs-pets--make-frame`: Creates a frame for left and right images.
- `emacs-pets--create-images`: Creates and caches walk and idle frames.
- `emacs-pets--mode-line-string`: Returns the string to display in the modeline.
- `emacs-pets--install-mode-line`: Adds the pet construct to `global-mode-string`.
- `emacs-pets--remove-mode-line`: Removes the pet construct from `global-mode-string`.
- `emacs-pets--start-timer`: Starts the animation timer.
- `emacs-pets--restart-timer`: Restarts the animation timer (e.g. after tick interval change).
- `emacs-pets--stop-timer`: Stops the animation timer.

#### Minor Mode

- `emacs-pets-mode`: Minor mode to toggle the animated pet in the modeline.

## Conclusion

This document provides a comprehensive overview of the emacs-pets project structure and guidelines for future feature implementation. Use it as a reference for maintaining and extending the project.
