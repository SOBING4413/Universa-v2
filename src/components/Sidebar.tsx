import React, { useState } from "react";
import { useTheme, themes } from "@/hooks/useTheme";
import {
  Zap,
  Server,
  Wrench,
  Code2,
  Heart,
  Palette,
  ChevronLeft,
  ChevronRight,
  X,
  Settings,
} from "lucide-react";

interface SidebarProps {
  activePanel: string;
  onPanelChange: (panel: string) => void;
}

const navItems = [
  { id: "features", label: "Features", icon: Zap },
  { id: "server", label: "Server Info", icon: Server },
  { id: "utilities", label: "Utilities", icon: Wrench },
  { id: "analyzer", label: "Script Analyzer", icon: Code2 },
  { id: "credits", label: "Credits", icon: Heart },
];

export default function Sidebar({ activePanel, onPanelChange }: SidebarProps) {
  const { currentTheme, setTheme } = useTheme();
  const [collapsed, setCollapsed] = useState(false);
  const [showThemes, setShowThemes] = useState(false);

  return (
    <>
      <aside
        className="relative flex flex-col h-full transition-all duration-300 ease-out"
        style={{
          width: collapsed ? 64 : 220,
          background: currentTheme.surface,
          borderRight: `1px solid ${currentTheme.border}`,
        }}
      >
        {/* Logo Area */}
        <div
          className="flex items-center gap-3 px-4 py-4 border-b"
          style={{ borderColor: currentTheme.border }}
        >
          <div
            className="w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold shrink-0"
            style={{
              background: `linear-gradient(135deg, ${currentTheme.primary}, ${currentTheme.secondary})`,
              color: currentTheme.bg,
              boxShadow: currentTheme.glow,
            }}
          >
            NX
          </div>
          {!collapsed && (
            <span
              className="font-bold text-sm tracking-wider truncate"
              style={{
                fontFamily: "'Orbitron', sans-serif",
                color: currentTheme.primary,
                textShadow: `0 0 10px ${currentTheme.primary}40`,
              }}
            >
              UNIVERSAL v2
            </span>
          )}
        </div>

        {/* Navigation */}
        <nav className="flex-1 py-3 px-2 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const isActive = activePanel === item.id;
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                onClick={() => onPanelChange(item.id)}
                className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200 group relative overflow-hidden"
                style={{
                  background: isActive
                    ? `${currentTheme.primary}15`
                    : "transparent",
                  color: isActive
                    ? currentTheme.primary
                    : currentTheme.textSecondary,
                  borderLeft: isActive
                    ? `3px solid ${currentTheme.primary}`
                    : "3px solid transparent",
                }}
              >
                {isActive && (
                  <div
                    className="absolute inset-0 opacity-10"
                    style={{
                      background: `linear-gradient(90deg, ${currentTheme.primary}, transparent)`,
                    }}
                  />
                )}
                <Icon size={18} className="shrink-0 relative z-10" />
                {!collapsed && (
                  <span
                    className="text-sm font-medium truncate relative z-10"
                    style={{ fontFamily: "'Rajdhani', sans-serif" }}
                  >
                    {item.label}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Bottom Actions */}
        <div
          className="px-2 py-3 space-y-1 border-t"
          style={{ borderColor: currentTheme.border }}
        >
          <button
            onClick={() => setShowThemes(true)}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200"
            style={{ color: currentTheme.textSecondary }}
          >
            <Palette size={18} className="shrink-0" />
            {!collapsed && (
              <span
                className="text-sm font-medium"
                style={{ fontFamily: "'Rajdhani', sans-serif" }}
              >
                Themes
              </span>
            )}
          </button>
          <button
            onClick={() => onPanelChange("settings")}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200"
            style={{
              color:
                activePanel === "settings"
                  ? currentTheme.primary
                  : currentTheme.textSecondary,
              background:
                activePanel === "settings"
                  ? `${currentTheme.primary}15`
                  : "transparent",
            }}
          >
            <Settings size={18} className="shrink-0" />
            {!collapsed && (
              <span
                className="text-sm font-medium"
                style={{ fontFamily: "'Rajdhani', sans-serif" }}
              >
                Settings
              </span>
            )}
          </button>
        </div>

        {/* Collapse Toggle */}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="absolute -right-3 top-1/2 -translate-y-1/2 w-6 h-6 rounded-full flex items-center justify-center z-20 transition-all duration-200"
          style={{
            background: currentTheme.surface,
            border: `1px solid ${currentTheme.border}`,
            color: currentTheme.textSecondary,
          }}
        >
          {collapsed ? <ChevronRight size={12} /> : <ChevronLeft size={12} />}
        </button>
      </aside>

      {/* Theme Modal */}
      {showThemes && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center"
          style={{ background: "rgba(0,0,0,0.7)", backdropFilter: "blur(8px)" }}
        >
          <div
            className="rounded-xl p-6 w-[400px] max-w-[90vw] relative"
            style={{
              background: currentTheme.surface,
              border: `1px solid ${currentTheme.border}`,
              boxShadow: currentTheme.glow,
            }}
          >
            <button
              onClick={() => setShowThemes(false)}
              className="absolute top-4 right-4"
              style={{ color: currentTheme.textSecondary }}
            >
              <X size={18} />
            </button>
            <h3
              className="text-lg font-bold mb-4"
              style={{
                fontFamily: "'Orbitron', sans-serif",
                color: currentTheme.primary,
              }}
            >
              SELECT THEME
            </h3>
            <div className="space-y-2">
              {themes.map((theme) => (
                <button
                  key={theme.name}
                  onClick={() => {
                    setTheme(theme);
                    setShowThemes(false);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200"
                  style={{
                    background:
                      currentTheme.name === theme.name
                        ? `${theme.primary}20`
                        : theme.surfaceHover,
                    border:
                      currentTheme.name === theme.name
                        ? `1px solid ${theme.primary}50`
                        : `1px solid transparent`,
                  }}
                >
                  <div className="flex gap-1.5">
                    <div
                      className="w-4 h-4 rounded-full"
                      style={{
                        background: theme.primary,
                        boxShadow: `0 0 8px ${theme.primary}80`,
                      }}
                    />
                    <div
                      className="w-4 h-4 rounded-full"
                      style={{
                        background: theme.secondary,
                        boxShadow: `0 0 8px ${theme.secondary}80`,
                      }}
                    />
                  </div>
                  <span
                    className="text-sm font-medium"
                    style={{
                      fontFamily: "'Rajdhani', sans-serif",
                      color: theme.text,
                    }}
                  >
                    {theme.name}
                  </span>
                  {currentTheme.name === theme.name && (
                    <span
                      className="ml-auto text-xs px-2 py-0.5 rounded"
                      style={{
                        background: `${theme.primary}30`,
                        color: theme.primary,
                      }}
                    >
                      Active
                    </span>
                  )}
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </>
  );
}