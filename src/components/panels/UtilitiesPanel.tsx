import React, { useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import {
  Gauge,
  ArrowUpFromDot,
  Ghost,
  RotateCcw,
  RefreshCw,
  Copy,
  Shuffle,
  Check,
} from "lucide-react";

export default function UtilitiesPanel() {
  const { currentTheme } = useTheme();
  const [walkSpeed, setWalkSpeed] = useState(16);
  const [jumpPower, setJumpPower] = useState(50);
  const [noclip, setNoclip] = useState(false);
  const [copied, setCopied] = useState(false);
  const [actionMsg, setActionMsg] = useState("");

  const showMsg = (msg: string) => {
    setActionMsg(msg);
    setTimeout(() => setActionMsg(""), 2000);
  };

  const handleCopyJobId = () => {
    navigator.clipboard.writeText("a1b2c3d4-e5f6-7890-abcd-ef1234567890").catch(() => {});
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const renderSlider = (
    label: string,
    icon: React.ReactNode,
    value: number,
    min: number,
    max: number,
    onChange: (v: number) => void
  ) => {
    const percent = ((value - min) / (max - min)) * 100;
    return (
      <div
        className="p-4 rounded-xl"
        style={{ background: currentTheme.surfaceHover, border: `1px solid ${currentTheme.border}` }}
      >
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <span style={{ color: currentTheme.primary }}>{icon}</span>
            <span className="text-sm font-bold" style={{ fontFamily: "'Rajdhani', sans-serif", color: currentTheme.text }}>
              {label}
            </span>
          </div>
          <span
            className="text-sm font-mono px-2 py-0.5 rounded"
            style={{ background: `${currentTheme.primary}15`, color: currentTheme.primary, border: `1px solid ${currentTheme.primary}30` }}
          >
            {value}
          </span>
        </div>
        <div className="relative h-2 rounded-full overflow-hidden" style={{ background: currentTheme.border }}>
          <div
            className="absolute h-full rounded-full transition-all duration-150"
            style={{
              width: `${percent}%`,
              background: `linear-gradient(90deg, ${currentTheme.primary}, ${currentTheme.secondary})`,
              boxShadow: `0 0 10px ${currentTheme.primary}50`,
            }}
          />
        </div>
        <input
          type="range"
          min={min}
          max={max}
          value={value}
          onChange={(e) => onChange(Number(e.target.value))}
          className="w-full mt-1 opacity-0 cursor-pointer h-2 relative -top-2"
        />
        <div className="flex justify-between text-xs" style={{ color: currentTheme.textSecondary }}>
          <span>{min}</span>
          <span>{max}</span>
        </div>
      </div>
    );
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
          UTILITIES
        </h2>
        <p className="text-sm mt-1" style={{ color: currentTheme.textSecondary }}>
          Character controls and server utilities
        </p>
      </div>

      {/* Sliders */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {renderSlider("WALKSPEED", <Gauge size={16} />, walkSpeed, 0, 500, setWalkSpeed)}
        {renderSlider("JUMP POWER", <ArrowUpFromDot size={16} />, jumpPower, 0, 500, setJumpPower)}
      </div>

      {/* Noclip Toggle */}
      <div
        className="flex items-center justify-between p-4 rounded-xl transition-all duration-300"
        style={{
          background: noclip ? `${currentTheme.primary}08` : currentTheme.surfaceHover,
          border: `1px solid ${noclip ? currentTheme.primary + "40" : currentTheme.border}`,
          boxShadow: noclip ? currentTheme.glow.replace("20px", "10px") : "none",
        }}
      >
        <div className="flex items-center gap-3">
          <div
            className="w-10 h-10 rounded-lg flex items-center justify-center"
            style={{
              background: noclip ? `${currentTheme.primary}20` : currentTheme.border,
              color: noclip ? currentTheme.primary : currentTheme.textSecondary,
            }}
          >
            <Ghost size={18} />
          </div>
          <div>
            <div className="text-sm font-bold" style={{ fontFamily: "'Rajdhani', sans-serif", color: noclip ? currentTheme.primary : currentTheme.text }}>
              NOCLIP
            </div>
            <div className="text-xs" style={{ color: currentTheme.textSecondary }}>
              Walk through walls and objects
            </div>
          </div>
        </div>
        <button
          onClick={() => setNoclip(!noclip)}
          className="relative w-12 h-6 rounded-full transition-all duration-300"
          style={{
            background: noclip ? currentTheme.primary : currentTheme.border,
            boxShadow: noclip ? `0 0 12px ${currentTheme.primary}50` : "none",
          }}
        >
          <div
            className="absolute top-0.5 w-5 h-5 rounded-full transition-all duration-300"
            style={{ left: noclip ? 26 : 2, background: noclip ? currentTheme.bg : currentTheme.textSecondary }}
          />
        </button>
      </div>

      {/* Action Buttons */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { label: "Reset Character", icon: <RotateCcw size={16} />, msg: "Character reset!", color: "#ff3355" },
          { label: "Rejoin Server", icon: <RefreshCw size={16} />, msg: "Rejoining server...", color: "#ffaa00" },
          { label: "Copy JobId", icon: copied ? <Check size={16} /> : <Copy size={16} />, action: handleCopyJobId, color: currentTheme.primary },
          { label: "Server Hop", icon: <Shuffle size={16} />, msg: "Finding new server...", color: "#7b2dff" },
        ].map((btn, i) => (
          <button
            key={i}
            onClick={() => btn.action ? btn.action() : showMsg(btn.msg!)}
            className="flex flex-col items-center gap-2 p-4 rounded-xl transition-all duration-300 hover:scale-[1.03] active:scale-95"
            style={{
              background: currentTheme.surfaceHover,
              border: `1px solid ${currentTheme.border}`,
              color: btn.color,
            }}
          >
            {btn.icon}
            <span className="text-xs font-bold" style={{ fontFamily: "'Rajdhani', sans-serif" }}>
              {btn.label}
            </span>
          </button>
        ))}
      </div>

      {/* Action Message */}
      {actionMsg && (
        <div
          className="p-3 rounded-lg text-center text-sm font-bold animate-pulse"
          style={{
            background: `${currentTheme.primary}15`,
            border: `1px solid ${currentTheme.primary}40`,
            color: currentTheme.primary,
          }}
        >
          {actionMsg}
        </div>
      )}
    </div>
  );
}