# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VS Code Pets is a VS Code extension (TypeScript) that places animated virtual pets in the VS code editor.
The source lives in `context/vscode-pets/`. The goal of this project is to create an Emacs package equivalent of the
vscode-pets extension. Having 100% feature parity is not a goal since the 2 editors have many differences.
The Emacs Pet should appear in the modeline. It should take the form of pixel art that changes pixels and
position to simulate movement. It should move around the modeline by itself. It should be performant and
not block execution of the rest of the editor. Use the VS Code Pets source code as inspiration.

## Architecture of VS Code Pets

The extension has two execution contexts that communicate via message passing:

**Extension Host (Node.js)** - `src/extension/extension.ts`
- VS Code API integration, command registration, configuration management
- Pet state persistence via VS Code memento API
- Creates and manages webview panels/views
- Webview HTML generation with nonce-based CSP security

**Webview (Browser)** - `src/panel/`
- Canvas-based rendering with `requestAnimationFrame` loop
- `main.ts` - Webview initialization, event loop, pet spawning/removal
- `basepettype.ts` - Abstract base class for all pets (position, sprites, state machine, animation)
- `states.ts` - State machine with 16+ states (sitIdle, walkRight, climbWall, chase, etc.)
- `pets.ts` - Pet factory (`createPet`), `PetCollection` manager, `availableColors()`
- `pets/` - 24 individual pet type implementations (cat.ts, dog.ts, etc.)
- `ball.ts` - Ball physics (velocity, gravity, bouncing, chase mechanics)
- `effects/` - Visual particle effects (snow, leaves, stars)

**Shared** - `src/common/`
- `types.ts` - Core enums: `PetColor`, `PetType`, `PetSize`, `PetSpeed`, `States`, `Theme`
- `names.ts` - Random name generation per pet type
- `localize.ts` - Localization utilities (23 languages via `package.nls.*.json`)
