import React, { useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import { Code2, ChevronDown, ChevronRight, FileCode, FolderOpen, AlertTriangle, CheckCircle } from "lucide-react";

interface ScriptItem {
  id: number;
  name: string;
  type: "LocalScript" | "Script" | "ModuleScript";
  location: string;
  status: "safe" | "suspicious" | "unknown";
  lines: number;
  details: string;
}

const MOCK_SCRIPTS: ScriptItem[] = [
  { id: 1, name: "PlayerController", type: "LocalScript", location: "StarterPlayerScripts", status: "safe", lines: 342, details: "Handles player movement, camera, and input bindings. No obfuscation detected." },
  { id: 2, name: "GameManager", type: "Script", location: "ServerScriptService", status: "safe", lines: 891, details: "Main game loop, round management, and scoring system. Server-side validated." },
  { id: 3, name: "AntiCheat_v3", type: "Script", location: "ServerScriptService", status: "suspicious", lines: 1205, details: "Anti-exploit detection system. Heavy obfuscation detected. Monitors player speed, teleport, and fly states." },
  { id: 4, name: "UIHandler", type: "LocalScript", location: "StarterGui", status: "safe", lines: 156, details: "Manages UI elements, notifications, and HUD updates." },
  { id: 5, name: "DataStore", type: "ModuleScript", location: "ServerStorage", status: "safe", lines: 478, details: "Player data persistence module. Uses DataStore2 wrapper for saving/loading." },
  { id: 6, name: "WeaponSystem", type: "ModuleScript", location: "ReplicatedStorage", status: "safe", lines: 623, details: "Weapon handling, damage calculation, and hitbox detection module." },
  { id: 7, name: "ObfuscatedLoader", type: "LocalScript", location: "StarterPlayerScripts", status: "suspicious", lines: 45, details: "Heavily obfuscated script. Loads external modules via HttpService. Potential security risk." },
  { id: 8, name: "ChatFilter", type: "Script", location: "ServerScriptService", status: "unknown", lines: 89, details: "Custom chat filtering system. Uses TextService for filtering." },
];

export default function ScriptAnalyzerPanel() {
  const { currentTheme } = useTheme();
  const [expandedId, setExpandedId] = useState<number | null>(null);
  const [filter, setFilter] = useState<string>("all");

  const filteredScripts = MOCK_SCRIPTS.filter((s) => {
    if (filter === "all") return true;
    return s.type === filter || s.status === filter;
  });

  const typeColor = (type: string) => {
    if (type === "LocalScript") return "#00f0ff";
    if (type === "Script") return "#ff00aa";
    return "#7b2dff";
  };

  const statusIcon = (status: string) => {
    if (status === "safe") return <CheckCircle size={14} style={{ color: "#00ff88" }} />;
    if (status === "suspicious") return <AlertTriangle size={14} style={{ color: "#ffaa00" }} />;
    return <Code2 size={14} style={{ color: currentTheme.textSecondary }} />;
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
          SCRIPT ANALYZER
        </h2>
        <p className="text-sm mt-1" style={{ color: currentTheme.textSecondary }}>
          Lua Checker — Inspect detected scripts in the game
        </p>
      </div>

      {/* Stats Bar */}
      <div className="grid grid-cols-4 gap-3">
        {[
          { label: "Total", value: MOCK_SCRIPTS.length, color: currentTheme.primary },
          { label: "Safe", value: MOCK_SCRIPTS.filter((s) => s.status === "safe").length, color: "#00ff88" },
          { label: "Suspicious", value: MOCK_SCRIPTS.filter((s) => s.status === "suspicious").length, color: "#ffaa00" },
          { label: "Unknown", value: MOCK_SCRIPTS.filter((s) => s.status === "unknown").length, color: currentTheme.textSecondary },
        ].map((stat, i) => (
          <div
            key={i}
            className="p-3 rounded-xl text-center"
            style={{ background: currentTheme.surfaceHover, border: `1px solid ${currentTheme.border}` }}
          >
            <div className="text-xl font-bold" style={{ fontFamily: "'Orbitron', sans-serif", color: stat.color }}>
              {stat.value}
            </div>
            <div className="text-xs mt-1" style={{ color: currentTheme.textSecondary }}>
              {stat.label}
            </div>
          </div>
        ))}
      </div>

      {/* Filter Tabs */}
      <div className="flex gap-2 flex-wrap">
        {["all", "LocalScript", "Script", "ModuleScript", "safe", "suspicious"].map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className="px-3 py-1.5 rounded-lg text-xs font-bold transition-all duration-200"
            style={{
              fontFamily: "'Rajdhani', sans-serif",
              background: filter === f ? `${currentTheme.primary}20` : currentTheme.surfaceHover,
              color: filter === f ? currentTheme.primary : currentTheme.textSecondary,
              border: `1px solid ${filter === f ? currentTheme.primary + "40" : currentTheme.border}`,
            }}
          >
            {f === "all" ? "All" : f}
          </button>
        ))}
      </div>

      {/* Script List */}
      <div
        className="rounded-xl overflow-hidden"
        style={{
          background: currentTheme.surface,
          border: `1px solid ${currentTheme.border}`,
        }}
      >
        {/* Terminal Header */}
        <div
          className="px-4 py-2 flex items-center gap-2"
          style={{ background: currentTheme.surfaceHover, borderBottom: `1px solid ${currentTheme.border}` }}
        >
          <div className="flex gap-1.5">
            <div className="w-3 h-3 rounded-full" style={{ background: "#ff3355" }} />
            <div className="w-3 h-3 rounded-full" style={{ background: "#ffaa00" }} />
            <div className="w-3 h-3 rounded-full" style={{ background: "#00ff88" }} />
          </div>
          <span className="text-xs ml-2" style={{ color: currentTheme.textSecondary, fontFamily: "'JetBrains Mono', monospace" }}>
            lua_analyzer.exe — {filteredScripts.length} scripts detected
          </span>
        </div>

        {/* Scripts */}
        <div className="max-h-[400px] overflow-y-auto">
          {filteredScripts.map((script) => (
            <div key={script.id}>
              <button
                onClick={() => setExpandedId(expandedId === script.id ? null : script.id)}
                className="w-full flex items-center gap-3 px-4 py-3 transition-all duration-200 text-left"
                style={{
                  borderBottom: `1px solid ${currentTheme.border}50`,
                  background: expandedId === script.id ? `${currentTheme.primary}08` : "transparent",
                }}
              >
                {expandedId === script.id ? (
                  <ChevronDown size={14} style={{ color: currentTheme.primary }} />
                ) : (
                  <ChevronRight size={14} style={{ color: currentTheme.textSecondary }} />
                )}
                <FileCode size={16} style={{ color: typeColor(script.type) }} />
                <div className="flex-1 min-w-0">
                  <span
                    className="text-sm font-bold"
                    style={{ fontFamily: "'JetBrains Mono', monospace", color: currentTheme.text }}
                  >
                    {script.name}
                  </span>
                </div>
                <span
                  className="text-xs px-2 py-0.5 rounded shrink-0"
                  style={{
                    background: `${typeColor(script.type)}15`,
                    color: typeColor(script.type),
                    border: `1px solid ${typeColor(script.type)}30`,
                  }}
                >
                  {script.type}
                </span>
                {statusIcon(script.status)}
              </button>

              {/* Expanded Details */}
              {expandedId === script.id && (
                <div
                  className="px-6 py-3 space-y-2"
                  style={{
                    background: `${currentTheme.primary}05`,
                    borderBottom: `1px solid ${currentTheme.border}`,
                    fontFamily: "'JetBrains Mono', monospace",
                  }}
                >
                  <div className="grid grid-cols-2 gap-2 text-xs">
                    <div>
                      <span style={{ color: currentTheme.textSecondary }}>Location: </span>
                      <span style={{ color: currentTheme.primary }}>
                        <FolderOpen size={12} className="inline mr-1" />
                        {script.location}
                      </span>
                    </div>
                    <div>
                      <span style={{ color: currentTheme.textSecondary }}>Lines: </span>
                      <span style={{ color: currentTheme.text }}>{script.lines}</span>
                    </div>
                    <div>
                      <span style={{ color: currentTheme.textSecondary }}>Status: </span>
                      <span
                        style={{
                          color:
                            script.status === "safe"
                              ? "#00ff88"
                              : script.status === "suspicious"
                              ? "#ffaa00"
                              : currentTheme.textSecondary,
                        }}
                      >
                        {script.status.toUpperCase()}
                      </span>
                    </div>
                  </div>
                  <div
                    className="text-xs p-2 rounded-lg mt-2"
                    style={{ background: currentTheme.bg, color: currentTheme.textSecondary }}
                  >
                    <span style={{ color: "#00ff88" }}>$</span> {script.details}
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}