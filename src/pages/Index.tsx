import React, { useState, useEffect } from "react";
import { useTheme } from "@/hooks/useTheme";
import Sidebar from "@/components/Sidebar";
import FeaturesPanel from "@/components/panels/FeaturesPanel";
import ServerInfoPanel from "@/components/panels/ServerInfoPanel";
import UtilitiesPanel from "@/components/panels/UtilitiesPanel";
import ScriptAnalyzerPanel from "@/components/panels/ScriptAnalyzerPanel";
import CreditsPanel from "@/components/panels/CreditsPanel";
import SettingsPanel from "@/components/panels/SettingsPanel";

const panels: Record<string, React.FC> = {
  features: FeaturesPanel,
  server: ServerInfoPanel,
  utilities: UtilitiesPanel,
  analyzer: ScriptAnalyzerPanel,
  credits: CreditsPanel,
  settings: SettingsPanel,
};

export default function Index() {
  const { currentTheme } = useTheme();
  const [activePanel, setActivePanel] = useState("features");
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const ActiveComponent = panels[activePanel] || FeaturesPanel;

  return (
    <div
      className="h-screen w-screen flex overflow-hidden relative"
      style={{
        background: currentTheme.bg,
        fontFamily: "'Rajdhani', sans-serif",
        color: currentTheme.text,
      }}
    >
      {/* Background Effects */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {/* Circuit BG */}
        <div
          className="absolute inset-0 opacity-[0.03]"
          style={{
            backgroundImage: `url(https://mgx-backend-cdn.metadl.com/generate/images/1028319/2026-03-15/ebf269a6-30f6-4a32-b671-6825f86025d4.png)`,
            backgroundSize: "cover",
            backgroundPosition: "center",
          }}
        />
        {/* Grid overlay */}
        <div
          className="absolute inset-0 opacity-[0.04]"
          style={{
            backgroundImage: `linear-gradient(${currentTheme.primary}20 1px, transparent 1px), linear-gradient(90deg, ${currentTheme.primary}20 1px, transparent 1px)`,
            backgroundSize: "60px 60px",
          }}
        />
        {/* Scan line */}
        <div
          className="absolute inset-0 opacity-[0.02]"
          style={{
            background: `repeating-linear-gradient(0deg, transparent, transparent 2px, ${currentTheme.primary}10 2px, ${currentTheme.primary}10 4px)`,
          }}
        />
        {/* Glow orbs */}
        <div
          className="absolute w-[600px] h-[600px] rounded-full blur-[200px] opacity-[0.06]"
          style={{
            background: currentTheme.primary,
            top: "-200px",
            right: "-200px",
          }}
        />
        <div
          className="absolute w-[400px] h-[400px] rounded-full blur-[150px] opacity-[0.04]"
          style={{
            background: currentTheme.secondary,
            bottom: "-100px",
            left: "20%",
          }}
        />
      </div>

      {/* Sidebar */}
      <Sidebar activePanel={activePanel} onPanelChange={setActivePanel} />

      {/* Main Content */}
      <main className="flex-1 flex flex-col min-w-0 relative z-10">
        {/* Top Bar */}
        <header
          className="flex items-center justify-between px-6 py-3 shrink-0"
          style={{
            background: `${currentTheme.surface}cc`,
            borderBottom: `1px solid ${currentTheme.border}`,
            backdropFilter: "blur(12px)",
          }}
        >
          <div className="flex items-center gap-3">
            <img
              src="https://mgx-backend-cdn.metadl.com/generate/images/1028319/2026-03-15/d7b9f008-2f82-4c4c-beb1-c86a3b29b3f8.png"
              alt="UNIVERSAL v2"
              className="h-7 object-contain"
            />
            <div
              className="h-4 w-px"
              style={{ background: currentTheme.border }}
            />
            <span
              className="text-xs tracking-widest uppercase"
              style={{ color: currentTheme.textSecondary }}
            >
              {activePanel}
            </span>
          </div>

          <div className="flex items-center gap-4">
            {/* Status indicator */}
            <div className="flex items-center gap-2">
              <div
                className="w-2 h-2 rounded-full animate-pulse"
                style={{ background: "#00ff88", boxShadow: "0 0 8px #00ff8880" }}
              />
              <span className="text-xs" style={{ color: currentTheme.textSecondary }}>
                Connected
              </span>
            </div>
            {/* FPS counter mock */}
            <span
              className="text-xs font-mono px-2 py-1 rounded"
              style={{
                background: `${currentTheme.primary}10`,
                color: currentTheme.primary,
                border: `1px solid ${currentTheme.primary}20`,
              }}
            >
              60 FPS
            </span>
            {/* Ping */}
            <span
              className="text-xs font-mono px-2 py-1 rounded"
              style={{
                background: "#00ff8810",
                color: "#00ff88",
                border: "1px solid #00ff8820",
              }}
            >
              48ms
            </span>
          </div>
        </header>

        {/* Content Area */}
        <div className="flex-1 overflow-y-auto p-6">
          <div
            className={`max-w-5xl mx-auto transition-all duration-500 ${
              mounted ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
            }`}
          >
            <ActiveComponent />
          </div>
        </div>

        {/* Bottom Bar */}
        <footer
          className="flex items-center justify-between px-6 py-2 shrink-0"
          style={{
            background: `${currentTheme.surface}cc`,
            borderTop: `1px solid ${currentTheme.border}`,
            backdropFilter: "blur(12px)",
          }}
        >
          <span className="text-xs" style={{ color: currentTheme.textSecondary }}>
            UNIVERSAL v2 v2.5.0 • Universal Script
          </span>
          <div className="flex items-center gap-3">
            <span className="text-xs" style={{ color: currentTheme.textSecondary }}>
              Theme: {currentTheme.name}
            </span>
            <div
              className="w-3 h-3 rounded-full"
              style={{
                background: currentTheme.primary,
                boxShadow: `0 0 8px ${currentTheme.primary}60`,
              }}
            />
          </div>
        </footer>
      </main>
    </div>
  );
}