# UNIVERSAL - Roblox Script GUI

## Design Guidelines

### Design References
- Modern Roblox executor GUIs (Synapse X, Fluxus, Krnl)
- Cyberpunk/Neon aesthetic with glassmorphism
- Dark mode gaming UI with smooth animations

### Color Palette (Default Neon Theme)
- Background: #0a0a0f (Deep Dark)
- Surface: #12121a (Dark Surface)
- Card: #1a1a2e (Card Background)
- Primary Accent: #00d4ff (Cyan Neon)
- Secondary Accent: #7c3aed (Purple)
- Success: #22c55e (Green)
- Warning: #f59e0b (Amber)
- Danger: #ef4444 (Red)
- Text Primary: #ffffff
- Text Secondary: #94a3b8
- Border: rgba(0, 212, 255, 0.2)

### Theme Options
- **Neon Cyan** (default): #00d4ff
- **Red Dragon**: #ef4444
- **Ocean Blue**: #3b82f6
- **Purple Galaxy**: #a855f7
- **Green Matrix**: #22c55e
- **Gold Rush**: #f59e0b

### Typography
- Font: Inter / JetBrains Mono (for values)
- Headings: font-weight 700
- Body: font-weight 400
- Values/Numbers: JetBrains Mono

### Key Component Styles
- Cards: Glassmorphism with backdrop-blur, subtle border glow
- Toggles: Smooth animated switches with glow effect
- Sliders: Custom styled with thumb glow, smooth dragging
- Buttons: Gradient backgrounds with hover glow
- Sidebar: Semi-transparent with icon + text navigation
- Transitions: 300ms ease-in-out for all interactions

### Images to Generate
1. **universal-logo-neon.png** - Futuristic "U" logo emblem with neon cyan glow, dark background, gaming style (Style: minimalist, 3d)
2. **bg-cyberpunk-grid.jpg** - Dark cyberpunk grid background with subtle neon lines and particles (Style: minimalist)
3. **banner-universal-hero.jpg** - Dark futuristic banner with neon accents, abstract geometric shapes (Style: 3d)
4. **icon-roblox-character.png** - Stylized Roblox character silhouette with neon outline (Style: minimalist)

---

## Development Tasks

### Files to Create (max 8):
1. **src/pages/Index.tsx** - Main GUI layout (landscape), sidebar nav, content panels
2. **src/components/Sidebar.tsx** - Navigation sidebar with icons and labels
3. **src/components/MainPanel.tsx** - Content area that switches between feature tabs
4. **src/components/features/MovementPanel.tsx** - Fly, Walk Speed, Infinite Jump, Noclip
5. **src/components/features/TeleportPanel.tsx** - Teleport to Player (with player list/search), Teleport to CP
6. **src/components/features/ExtrasPanel.tsx** - ESP, God Mode, Anti-AFK, Fullbright, Speed Presets
7. **src/components/features/SettingsPanel.tsx** - Theme switcher, Opacity control, GUI settings
8. **src/lib/gui-store.ts** - Zustand store for all GUI state management

### Features:
- [x] Fly toggle + speed slider (smooth)
- [x] Walk Speed slider (0-500) + manual input
- [x] Infinite Jump toggle
- [x] Auto Summit toggle
- [x] Teleport to Player (player list, search, alphabetical)
- [x] Teleport to Checkpoint
- [x] Theme switcher (6 themes)
- [x] Opacity control slider
- [x] ESP/Highlight toggle
- [x] Noclip toggle
- [x] God Mode toggle
- [x] Anti-AFK toggle
- [x] Fullbright toggle
- [x] Speed Boost presets
- [x] Mini console log
- [x] Landscape layout
- [x] Smooth animations