import React, { useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import { Plane, ArrowUpFromDot, Gauge, Shield, Eye, Ghost } from "lucide-react";

interface ToggleProps {
  label: string;
  icon: React.ReactNode;
  enabled: boolean;
  onToggle: () => void;
  description: string;
}

function CyberToggle({ label, icon, enabled, onToggle, description }: ToggleProps) {
  const { currentTheme } = useTheme();

  return (
    <div
      className="flex items-center justify-between p-4 rounded-xl transition-all duration-300"
      style={{
        background: enabled ? `${currentTheme.primary}08` : currentTheme.surfaceHover,
        border: `1px solid ${enabled ? currentTheme.primary + "40" : currentTheme.border}`,
        boxShadow: enabled ? currentTheme.glow.replace("20px", "10px").replace("40px", "20px") : "none",
      }}
    >
      <div className="flex items-center gap-3">
        <div
          className="w-10 h-10 rounded-lg flex items-center justify-center transition-all duration-300"
          style={{
            background: enabled ? `${currentTheme.primary}20` : `${currentTheme.border}`,
            color: enabled ? currentTheme.primary : currentTheme.textSecondary,
            boxShadow: enabled ? `0 0 12px ${currentTheme.primary}30` : "none",
          }}
        >
          {icon}
        </div>
        <div>
          <div
            className="text-sm font-bold"
            style={{
              fontFamily: "'Rajdhani', sans-serif",
              color: enabled ? currentTheme.primary : currentTheme.text,
            }}
          >
            {label}
          </div>
          <div
            className="text-xs"
            style={{ color: currentTheme.textSecondary }}
          >
            {description}
          </div>
        </div>
      </div>
      <button
        onClick={onToggle}
        className="relative w-12 h-6 rounded-full transition-all duration-300"
        style={{
          background: enabled ? currentTheme.primary : currentTheme.border,
          boxShadow: enabled ? `0 0 12px ${currentTheme.primary}50` : "none",
        }}
      >
        <div
          className="absolute top-0.5 w-5 h-5 rounded-full transition-all duration-300"
          style={{
            left: enabled ? 26 : 2,
            background: enabled ? currentTheme.bg : currentTheme.textSecondary,
          }}
        />
      </button>
    </div>
  );
}

interface SliderProps {
  label: string;
  icon: React.ReactNode;
  value: number;
  min: number;
  max: number;
  onChange: (v: number) => void;
  unit?: string;
}

function CyberSlider({ label, icon, value, min, max, onChange, unit = "" }: SliderProps) {
  const { currentTheme } = useTheme();
  const percent = ((value - min) / (max - min)) * 100;

  return (
    <div
      className="p-4 rounded-xl"
      style={{
        background: currentTheme.surfaceHover,
        border: `1px solid ${currentTheme.border}`,
      }}
    >
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <span style={{ color: currentTheme.primary }}>{icon}</span>
          <span
            className="text-sm font-bold"
            style={{
              fontFamily: "'Rajdhani', sans-serif",
              color: currentTheme.text,
            }}
          >
            {label}
          </span>
        </div>
        <span
          className="text-sm font-mono px-2 py-0.5 rounded"
          style={{
            background: `${currentTheme.primary}15`,
            color: currentTheme.primary,
            border: `1px solid ${currentTheme.primary}30`,
          }}
        >
          {value}
          {unit}
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
}

export default function FeaturesPanel() {
  const { currentTheme } = useTheme();
  const [fly, setFly] = useState(false);
  const [infiniteJump, setInfiniteJump] = useState(false);
  const [godMode, setGodMode] = useState(false);
  const [esp, setEsp] = useState(false);
  const [invisible, setInvisible] = useState(false);
  const [speed, setSpeed] = useState(16);

  return (
    <div className="space-y-6">
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
          FEATURES
        </h2>
        <p className="text-sm mt-1" style={{ color: currentTheme.textSecondary }}>
          Toggle game modifications and adjust parameters
        </p>
      </div>

      {/* Toggles Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <CyberToggle
          label="FLY"
          icon={<Plane size={18} />}
          enabled={fly}
          onToggle={() => setFly(!fly)}
          description="Fly freely in the game world"
        />
        <CyberToggle
          label="INFINITE JUMP"
          icon={<ArrowUpFromDot size={18} />}
          enabled={infiniteJump}
          onToggle={() => setInfiniteJump(!infiniteJump)}
          description="Jump unlimited times in air"
        />
        <CyberToggle
          label="GOD MODE"
          icon={<Shield size={18} />}
          enabled={godMode}
          onToggle={() => setGodMode(!godMode)}
          description="Become invincible to damage"
        />
        <CyberToggle
          label="ESP / WALLHACK"
          icon={<Eye size={18} />}
          enabled={esp}
          onToggle={() => setEsp(!esp)}
          description="See players through walls"
        />
        <CyberToggle
          label="INVISIBLE"
          icon={<Ghost size={18} />}
          enabled={invisible}
          onToggle={() => setInvisible(!invisible)}
          description="Become invisible to others"
        />
      </div>

      {/* Speed Slider */}
      <CyberSlider
        label="PLAYER SPEED"
        icon={<Gauge size={16} />}
        value={speed}
        min={1}
        max={500}
        onChange={setSpeed}
      />

      {/* Status Bar */}
      <div
        className="p-3 rounded-lg flex items-center gap-3"
        style={{
          background: `${currentTheme.primary}08`,
          border: `1px solid ${currentTheme.primary}20`,
        }}
      >
        <div
          className="w-2 h-2 rounded-full animate-pulse"
          style={{ background: "#00ff88", boxShadow: "0 0 8px #00ff8880" }}
        />
        <span className="text-xs" style={{ color: currentTheme.textSecondary }}>
          {[fly && "Fly", infiniteJump && "Inf. Jump", godMode && "God Mode", esp && "ESP", invisible && "Invisible"]
            .filter(Boolean)
            .join(" • ") || "No features active"}
        </span>
      </div>
    </div>
  );
}