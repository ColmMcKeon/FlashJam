# FlashJam

A modern macOS music and video player — a recreation of the original Flash MP3 player, built with Electron.

## Tech Stack

- **Framework:** Electron
- **Language:** JavaScript/HTML/CSS
- **Audio:** Web Audio API + Howler.js (or native)
- **Build:** electron-packager
- **Platform:** macOS (Apple Silicon)

## Features

- **Drag & drop** — Add music and video files by dragging into the player
- **Audio visualizer** — Real-time visualization of audio playback
- **ID3 tag support** — Automatic detection and display of track metadata
- **Playlist management** — Organize and navigate your media collection
- **Multiple format support** — Play MP3, WAV, M4A, and video files
- **Browse controls** — Navigate tracks and playlists with intuitive controls
- **Native macOS integration** — Built with Electron for seamless macOS experience

## Installation

Download the latest `FlashJam.zip` from [Releases](https://github.com/ColmMcKeon/FlashJam/releases) or build from source.

## Development

```bash
npm install
npm start
npm run build  # Create production bundle
