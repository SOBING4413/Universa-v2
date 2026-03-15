import { create } from "zustand";

export interface ThemeColors {
  name: string;
  primary: string;
  secondary: string;
  accent: string;
  glow: string;
  glowSecondary: string;
  bg: string;
  surface: string;
  surfaceHover: string;
  border: string;
  text: string;
  textSecondary: string;
}

export const themes: ThemeColors[] = [
  {
    name: "Cyberpunk Neon",
    primary: "#00f0ff",
    secondary: "#ff00aa",
    accent: "#7b2dff",
    glow: "0 0 20px rgba(0,240,255,0.5), 0 0 40px rgba(0,240,255,0.2)",
    glowSecondary: "0 0 20px rgba(255,0,170,0.5), 0 0 40px rgba(255,0,170,0.2)",
    bg: "#0a0a0f",
    surface: "#111118",
    surfaceHover: "#1a1a25",
    border: "#1e1e30",
    text: "#e0e0ff",
    textSecondary: "#8888aa",
  },
  {
    name: "Matrix Green",
    primary: "#00ff41",
    secondary: "#00cc33",
    accent: "#33ff77",
    glow: "0 0 20px rgba(0,255,65,0.5), 0 0 40px rgba(0,255,65,0.2)",
    glowSecondary: "0 0 20px rgba(0,204,51,0.5), 0 0 40px rgba(0,204,51,0.2)",
    bg: "#0a0f0a",
    surface: "#0d150d",
    surfaceHover: "#142014",
    border: "#1a2e1a",
    text: "#c0ffc0",
    textSecondary: "#66aa66",
  },
  {
    name: "Synthwave Purple",
    primary: "#b347ea",
    secondary: "#ff6b35",
    accent: "#ff2975",
    glow: "0 0 20px rgba(179,71,234,0.5), 0 0 40px rgba(179,71,234,0.2)",
    glowSecondary: "0 0 20px rgba(255,107,53,0.5), 0 0 40px rgba(255,107,53,0.2)",
    bg: "#0f0a14",
    surface: "#15101c",
    surfaceHover: "#201828",
    border: "#2a1e3a",
    text: "#e0d0ff",
    textSecondary: "#9977bb",
  },
  {
    name: "Ice Blue",
    primary: "#4dc9f6",
    secondary: "#a0e4ff",
    accent: "#0099cc",
    glow: "0 0 20px rgba(77,201,246,0.5), 0 0 40px rgba(77,201,246,0.2)",
    glowSecondary: "0 0 20px rgba(160,228,255,0.5), 0 0 40px rgba(160,228,255,0.2)",
    bg: "#080c10",
    surface: "#0c1218",
    surfaceHover: "#141e28",
    border: "#1a2a3a",
    text: "#d0e8ff",
    textSecondary: "#7799bb",
  },
  {
    name: "Blood Red",
    primary: "#ff3355",
    secondary: "#ff0044",
    accent: "#cc0033",
    glow: "0 0 20px rgba(255,51,85,0.5), 0 0 40px rgba(255,51,85,0.2)",
    glowSecondary: "0 0 20px rgba(255,0,68,0.5), 0 0 40px rgba(255,0,68,0.2)",
    bg: "#0f0a0a",
    surface: "#180d0d",
    surfaceHover: "#251515",
    border: "#3a1a1a",
    text: "#ffd0d0",
    textSecondary: "#aa6666",
  },
];

interface ThemeState {
  currentTheme: ThemeColors;
  setTheme: (theme: ThemeColors) => void;
}

export const useTheme = create<ThemeState>((set) => ({
  currentTheme: themes[0],
  setTheme: (theme) => set({ currentTheme: theme }),
}));