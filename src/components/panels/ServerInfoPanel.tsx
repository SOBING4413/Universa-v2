import React, { useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import {
  Server,
  Wifi,
  Crown,
  ShieldCheck,
  Users,
  Search,
  MapPin,
  Flag,
  Play,
  UserCircle,
} from "lucide-react";

const MOCK_PLAYERS = [
  { id: 1, name: "xN3onBlade", displayName: "NeonBlade", level: 87, status: "playing" },
  { id: 2, name: "CyberWolf_99", displayName: "CyberWolf", level: 142, status: "playing" },
  { id: 3, name: "PixelQueen", displayName: "PixelQ", level: 56, status: "idle" },
  { id: 4, name: "DarkMatter_X", displayName: "DarkMatter", level: 203, status: "playing" },
  { id: 5, name: "GlitchHunter", displayName: "Glitch", level: 34, status: "playing" },
  { id: 6, name: "NovaStrike77", displayName: "Nova", level: 91, status: "idle" },
  { id: 7, name: "ShadowByte", displayName: "Shadow", level: 178, status: "playing" },
  { id: 8, name: "ZeroDay_Dev", displayName: "ZeroDay", level: 65, status: "away" },
  { id: 9, name: "PhantomRush", displayName: "Phantom", level: 120, status: "playing" },
  { id: 10, name: "ByteStorm_X", displayName: "ByteStorm", level: 45, status: "playing" },
];

const SERVER_INFO = {
  name: "Cyber Arena v4.2",
  ping: 48,
  owner: "xN3onBlade",
  totalAdmin: 3,
  activePlayers: 10,
  maxPlayers: 30,
  jobId: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
};

export default function ServerInfoPanel() {
  const { currentTheme } = useTheme();
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedPlayer, setSelectedPlayer] = useState<string | null>(null);
  const [teleportMsg, setTeleportMsg] = useState("");

  const filteredPlayers = MOCK_PLAYERS.filter(
    (p) =>
      p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.displayName.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const showTeleportMsg = (msg: string) => {
    setTeleportMsg(msg);
    setTimeout(() => setTeleportMsg(""), 2000);
  };

  const statusColor = (status: string) => {
    if (status === "playing") return "#00ff88";
    if (status === "idle") return "#ffaa00";
    return "#ff3355";
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
          SERVER INFO
        </h2>
        <p className="text-sm mt-1" style={{ color: currentTheme.textSecondary }}>
          Server details, player list & teleport controls
        </p>
      </div>

      {/* Server Stats Grid */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
        {[
          { icon: <Server size={16} />, label: "Server", value: SERVER_INFO.name },
          {
            icon: <Wifi size={16} />,
            label: "Ping",
            value: `${SERVER_INFO.ping}ms`,
            color: SERVER_INFO.ping < 60 ? "#00ff88" : "#ffaa00",
          },
          { icon: <Crown size={16} />, label: "Owner", value: SERVER_INFO.owner },
          { icon: <ShieldCheck size={16} />, label: "Admins", value: SERVER_INFO.totalAdmin.toString() },
          {
            icon: <Users size={16} />,
            label: "Players",
            value: `${SERVER_INFO.activePlayers}/${SERVER_INFO.maxPlayers}`,
          },
        ].map((stat, i) => (
          <div
            key={i}
            className="p-3 rounded-xl text-center"
            style={{
              background: currentTheme.surfaceHover,
              border: `1px solid ${currentTheme.border}`,
            }}
          >
            <div className="flex justify-center mb-2" style={{ color: stat.color || currentTheme.primary }}>
              {stat.icon}
            </div>
            <div className="text-xs mb-1" style={{ color: currentTheme.textSecondary }}>
              {stat.label}
            </div>
            <div
              className="text-sm font-bold truncate"
              style={{
                fontFamily: "'Rajdhani', sans-serif",
                color: stat.color || currentTheme.text,
              }}
            >
              {stat.value}
            </div>
          </div>
        ))}
      </div>

      {/* Teleport Actions */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        {[
          { label: "Teleport to Spawn", icon: <MapPin size={14} />, msg: "Teleporting to Spawn..." },
          { label: "Teleport to CP", icon: <Flag size={14} />, msg: "Teleporting to Checkpoint..." },
          { label: "Auto Submit", icon: <Play size={14} />, msg: "Auto Submit activated..." },
        ].map((action, i) => (
          <button
            key={i}
            onClick={() => showTeleportMsg(action.msg)}
            className="flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-sm font-bold transition-all duration-300 hover:scale-[1.02] active:scale-95"
            style={{
              fontFamily: "'Rajdhani', sans-serif",
              background: `linear-gradient(135deg, ${currentTheme.primary}20, ${currentTheme.secondary}10)`,
              border: `1px solid ${currentTheme.primary}30`,
              color: currentTheme.primary,
            }}
          >
            {action.icon}
            {action.label}
          </button>
        ))}
      </div>

      {/* Teleport Message */}
      {teleportMsg && (
        <div
          className="p-3 rounded-lg text-center text-sm font-bold animate-pulse"
          style={{
            background: `${currentTheme.primary}15`,
            border: `1px solid ${currentTheme.primary}40`,
            color: currentTheme.primary,
            boxShadow: currentTheme.glow,
          }}
        >
          {teleportMsg}
        </div>
      )}

      {/* Player List */}
      <div
        className="rounded-xl overflow-hidden"
        style={{
          border: `1px solid ${currentTheme.border}`,
          background: currentTheme.surfaceHover,
        }}
      >
        {/* Search */}
        <div className="p-3 flex items-center gap-2" style={{ borderBottom: `1px solid ${currentTheme.border}` }}>
          <Search size={16} style={{ color: currentTheme.textSecondary }} />
          <input
            type="text"
            placeholder="Search players..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1 bg-transparent text-sm outline-none placeholder-opacity-50"
            style={{
              color: currentTheme.text,
              fontFamily: "'Rajdhani', sans-serif",
            }}
          />
          <span className="text-xs px-2 py-0.5 rounded" style={{ background: `${currentTheme.primary}15`, color: currentTheme.primary }}>
            {filteredPlayers.length}
          </span>
        </div>

        {/* Player Rows */}
        <div className="max-h-[280px] overflow-y-auto">
          {filteredPlayers.map((player) => (
            <div
              key={player.id}
              className="flex items-center justify-between px-4 py-2.5 transition-all duration-200 cursor-pointer"
              style={{
                borderBottom: `1px solid ${currentTheme.border}50`,
                background: selectedPlayer === player.name ? `${currentTheme.primary}10` : "transparent",
              }}
              onClick={() => setSelectedPlayer(player.name === selectedPlayer ? null : player.name)}
            >
              <div className="flex items-center gap-3">
                <div className="relative">
                  <UserCircle size={28} style={{ color: currentTheme.textSecondary }} />
                  <div
                    className="absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 rounded-full border-2"
                    style={{
                      background: statusColor(player.status),
                      borderColor: currentTheme.surfaceHover,
                      boxShadow: `0 0 6px ${statusColor(player.status)}80`,
                    }}
                  />
                </div>
                <div>
                  <div className="text-sm font-bold" style={{ color: currentTheme.text, fontFamily: "'Rajdhani', sans-serif" }}>
                    {player.displayName}
                  </div>
                  <div className="text-xs" style={{ color: currentTheme.textSecondary }}>
                    @{player.name} • Lv.{player.level}
                  </div>
                </div>
              </div>
              {selectedPlayer === player.name && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    showTeleportMsg(`Teleporting to ${player.displayName}...`);
                  }}
                  className="px-3 py-1 rounded-lg text-xs font-bold transition-all duration-200 hover:scale-105"
                  style={{
                    background: `${currentTheme.primary}20`,
                    color: currentTheme.primary,
                    border: `1px solid ${currentTheme.primary}40`,
                  }}
                >
                  TELEPORT
                </button>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}