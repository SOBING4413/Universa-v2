import React from "react";
import { useTheme } from "@/hooks/useTheme";
import { Heart, Github, Globe, User, Hash, IdCard, Activity, Star, Code2, Sparkles } from "lucide-react";

const PLAYER_INFO = {
  username: "xN3onBlade",
  displayName: "NeonBlade",
  userId: 1234567890,
  status: "Online",
  accountAge: "3 years",
  membership: "Premium",
};

const CREDITS = [
  { role: "Lead Developer & Engineer", name: "Sobing4413", contribution: "Core GUI Framework & Features" },
];

export default function CreditsPanel() {
  const { currentTheme } = useTheme();

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
          CREDITS & PLAYER INFO
        </h2>
        <p className="text-sm mt-1" style={{ color: currentTheme.textSecondary }}>
          Your profile information and development credits
        </p>
      </div>

      {/* Player Info Card */}
      <div
        className="rounded-xl overflow-hidden"
        style={{
          border: `1px solid ${currentTheme.primary}30`,
          boxShadow: currentTheme.glow.replace("20px", "8px").replace("40px", "16px"),
        }}
      >
        {/* Banner */}
        <div
          className="h-24 relative"
          style={{
            background: `linear-gradient(135deg, ${currentTheme.primary}30, ${currentTheme.secondary}20, ${currentTheme.bg})`,
          }}
        >
          <div
            className="absolute inset-0"
            style={{
              backgroundImage: `url(https://mgx-backend-cdn.metadl.com/generate/images/1028319/2026-03-15/538f8a9c-de1a-4561-b84f-f84180ecfb31.png)`,
              backgroundSize: "cover",
              backgroundPosition: "center",
              opacity: 0.2,
            }}
          />
          {/* Scan line effect */}
          <div
            className="absolute inset-0 pointer-events-none"
            style={{
              background: `repeating-linear-gradient(0deg, transparent, transparent 2px, ${currentTheme.bg}10 2px, ${currentTheme.bg}10 4px)`,
            }}
          />
        </div>

        {/* Avatar & Info */}
        <div className="px-5 pb-5 -mt-8 relative">
          <div className="flex items-end gap-4">
            <div
              className="w-16 h-16 rounded-xl overflow-hidden border-4 shrink-0"
              style={{
                borderColor: currentTheme.surface,
                boxShadow: `0 0 16px ${currentTheme.primary}30`,
              }}
            >
              <img
                src="https://mgx-backend-cdn.metadl.com/generate/images/1028319/2026-03-15/758aaae5-12e4-42f0-90e9-a641e2d38d41.png"
                alt="Avatar"
                className="w-full h-full object-cover"
              />
            </div>
            <div className="pb-1">
              <div
                className="text-lg font-bold"
                style={{ fontFamily: "'Orbitron', sans-serif", color: currentTheme.text }}
              >
                {PLAYER_INFO.displayName}
              </div>
              <div className="text-xs" style={{ color: currentTheme.textSecondary }}>
                @{PLAYER_INFO.username}
              </div>
            </div>
          </div>

          {/* Info Grid */}
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3 mt-4">
            {[
              { icon: <User size={14} />, label: "Username", value: PLAYER_INFO.username },
              { icon: <IdCard size={14} />, label: "Display Name", value: PLAYER_INFO.displayName },
              { icon: <Hash size={14} />, label: "UserId", value: PLAYER_INFO.userId.toString() },
              { icon: <Activity size={14} />, label: "Status", value: PLAYER_INFO.status, color: "#00ff88" },
              { icon: <Star size={14} />, label: "Account Age", value: PLAYER_INFO.accountAge },
              { icon: <Sparkles size={14} />, label: "Membership", value: PLAYER_INFO.membership, color: "#ffaa00" },
            ].map((info, i) => (
              <div
                key={i}
                className="p-3 rounded-lg"
                style={{ background: currentTheme.surfaceHover, border: `1px solid ${currentTheme.border}` }}
              >
                <div className="flex items-center gap-1.5 mb-1">
                  <span style={{ color: currentTheme.primary }}>{info.icon}</span>
                  <span className="text-xs" style={{ color: currentTheme.textSecondary }}>
                    {info.label}
                  </span>
                </div>
                <div
                  className="text-sm font-bold truncate"
                  style={{
                    fontFamily: "'Rajdhani', sans-serif",
                    color: info.color || currentTheme.text,
                  }}
                >
                  {info.value}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Credits Section */}
      <div>
        <div className="flex items-center gap-2 mb-4">
          <Heart size={16} style={{ color: currentTheme.secondary }} />
          <h3
            className="text-lg font-bold tracking-wider"
            style={{ fontFamily: "'Orbitron', sans-serif", color: currentTheme.text }}
          >
            DEVELOPMENT TEAM
          </h3>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {CREDITS.map((credit, i) => (
            <div
              key={i}
              className="p-4 rounded-xl transition-all duration-300 hover:scale-[1.02] group"
              style={{
                background: currentTheme.surfaceHover,
                border: `1px solid ${currentTheme.border}`,
              }}
            >
              <div className="flex items-center gap-3">
                <div
                  className="w-10 h-10 rounded-lg flex items-center justify-center text-sm font-bold"
                  style={{
                    background: `linear-gradient(135deg, ${currentTheme.primary}20, ${currentTheme.secondary}20)`,
                    color: currentTheme.primary,
                    border: `1px solid ${currentTheme.primary}20`,
                  }}
                >
                  {credit.name.charAt(0)}
                </div>
                <div className="flex-1 min-w-0">
                  <div
                    className="text-sm font-bold"
                    style={{ fontFamily: "'Rajdhani', sans-serif", color: currentTheme.text }}
                  >
                    {credit.name}
                  </div>
                  <div className="text-xs" style={{ color: currentTheme.primary }}>
                    {credit.role}
                  </div>
                </div>
              </div>
              <div className="text-xs mt-2" style={{ color: currentTheme.textSecondary }}>
                {credit.contribution}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Version Info */}
      <div
        className="p-4 rounded-xl text-center"
        style={{
          background: `linear-gradient(135deg, ${currentTheme.primary}08, ${currentTheme.secondary}05)`,
          border: `1px solid ${currentTheme.border}`,
        }}
      >
        <div className="flex items-center justify-center gap-2 mb-2">
          <Code2 size={16} style={{ color: currentTheme.primary }} />
          <span
            className="text-sm font-bold tracking-wider"
            style={{ fontFamily: "'Orbitron', sans-serif", color: currentTheme.primary }}
          >
            UNIVERSAL v2 v2.5.0
          </span>
        </div>
        <div className="text-xs" style={{ color: currentTheme.textSecondary }}>
          Universal Roblox Script GUI • Built with ❤️
        </div>
        <div className="flex items-center justify-center gap-4 mt-3">
          <a href="#" className="transition-all duration-200 hover:scale-110" style={{ color: currentTheme.textSecondary }}>
            <Github size={16} />
          </a>
          <a href="#" className="transition-all duration-200 hover:scale-110" style={{ color: currentTheme.textSecondary }}>
            <Globe size={16} />
          </a>
        </div>
      </div>
    </div>
  );
}