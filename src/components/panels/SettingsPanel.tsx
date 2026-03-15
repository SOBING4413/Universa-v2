import React, { useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import { Settings, Bell, Shield, Monitor, Zap, ToggleLeft, ToggleRight } from "lucide-react";

interface SettingToggle {
  id: string;
  label: string;
  description: string;
  icon: React.ReactNode;
  defaultValue: boolean;
}

const SETTINGS: SettingToggle[] = [
  { id: "notifications", label: "Notifications", description: "Show in-game notifications", icon: <Bell size={16} />, defaultValue: true },
  { id: "autoExecute", label: "Auto Execute", description: "Automatically run scripts on join", icon: <Zap size={16} />, defaultValue: false },
  { id: "antiDetect", label: "Anti-Detection", description: "Enable anti-cheat bypass measures", icon: <Shield size={16} />, defaultValue: true },
  { id: "streamMode", label: "Streamer Mode", description: "Hide sensitive info for streaming", icon: <Monitor size={16} />, defaultValue: false },
  { id: "smoothAnim", label: "Smooth Animations", description: "Enable smooth GUI transitions", icon: <ToggleLeft size={16} />, defaultValue: true },
  { id: "topMost", label: "Always On Top", description: "Keep GUI above other elements", icon: <Monitor size={16} />, defaultValue: true },
];

export default function SettingsPanel() {
  const { currentTheme } = useTheme();
  const [toggles, setToggles] = useState<Record<string, boolean>>(
    Object.fromEntries(SETTINGS.map((s) => [s.id, s.defaultValue]))
  );

  const handleToggle = (id: string) => {
    setToggles((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  return (
    <div className="space-y-5">
      {/* Header */}
      <div>
        <h2
          className="text-2xl font-bold tracking-wider"
          style={{
            fontFamily: "'Orbitron', sans-serif",
            color: currentTheme.primary,
            textShadow: `0 0 20px ${currentTheme.primary}40`,
          }}
        >
          SETTINGS
        </h2>
        <p className="text-sm mt-1" style={{ color: currentTheme.textSecondary }}>
          Configure GUI behavior and preferences
        </p>
      </div>

      {/* Settings List */}
      <div className="space-y-3">
        {SETTINGS.map((setting) => {
          const enabled = toggles[setting.id];
          return (
            <div
              key={setting.id}
              className="flex items-center justify-between p-4 rounded-xl transition-all duration-300"
              style={{
                background: currentTheme.surfaceHover,
                border: `1px solid ${enabled ? currentTheme.primary + "30" : currentTheme.border}`,
              }}
            >
              <div className="flex items-center gap-3">
                <div
                  className="w-10 h-10 rounded-lg flex items-center justify-center"
                  style={{
                    background: enabled ? `${currentTheme.primary}15` : currentTheme.border,
                    color: enabled ? currentTheme.primary : currentTheme.textSecondary,
                  }}
                >
                  {setting.icon}
                </div>
                <div>
                  <div
                    className="text-sm font-bold"
                    style={{ fontFamily: "'Rajdhani', sans-serif", color: currentTheme.text }}
                  >
                    {setting.label}
                  </div>
                  <div className="text-xs" style={{ color: currentTheme.textSecondary }}>
                    {setting.description}
                  </div>
                </div>
              </div>
              <button
                onClick={() => handleToggle(setting.id)}
                className="transition-all duration-300"
                style={{ color: enabled ? currentTheme.primary : currentTheme.textSecondary }}
              >
                {enabled ? <ToggleRight size={32} /> : <ToggleLeft size={32} />}
              </button>
            </div>
          );
        })}
      </div>

      {/* Keybind Section */}
      <div>
        <h3
          className="text-sm font-bold mb-3 tracking-wider"
          style={{ fontFamily: "'Orbitron', sans-serif", color: currentTheme.text }}
        >
          KEYBINDS
        </h3>
        <div className="space-y-2">
          {[
            { action: "Toggle GUI", key: "Right Shift" },
            { action: "Toggle Fly", key: "F" },
            { action: "Toggle Noclip", key: "N" },
            { action: "Speed Boost", key: "Ctrl + Shift" },
          ].map((kb, i) => (
            <div
              key={i}
              className="flex items-center justify-between px-4 py-3 rounded-lg"
              style={{ background: currentTheme.surfaceHover, border: `1px solid ${currentTheme.border}` }}
            >
              <span className="text-sm" style={{ fontFamily: "'Rajdhani', sans-serif", color: currentTheme.text }}>
                {kb.action}
              </span>
              <span
                className="text-xs px-3 py-1 rounded-lg font-mono"
                style={{
                  background: `${currentTheme.primary}10`,
                  color: currentTheme.primary,
                  border: `1px solid ${currentTheme.primary}30`,
                }}
              >
                {kb.key}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Reset */}
      <button
        className="w-full py-3 rounded-xl text-sm font-bold transition-all duration-300 hover:scale-[1.01] active:scale-95"
        style={{
          fontFamily: "'Rajdhani', sans-serif",
          background: "#ff335515",
          border: "1px solid #ff335540",
          color: "#ff3355",
        }}
      >
        RESET ALL SETTINGS
      </button>
    </div>
  );
}