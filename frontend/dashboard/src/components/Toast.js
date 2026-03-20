import React, { useEffect, useState } from "react";
export default function Toast({ toast }) {
  const [vis, setVis] = useState(false);
  useEffect(() => { const t = setTimeout(() => setVis(true), 10); return () => clearTimeout(t); }, []);
  return (
    <div style={{ position: "fixed", bottom: 20, right: 20, zIndex: 9999, background: "var(--text)", color: "var(--accent-fg)", padding: "10px 16px", borderRadius: "var(--r)", fontSize: 13, display: "flex", alignItems: "center", gap: 8, minWidth: 220, opacity: vis ? 1 : 0, transform: vis ? "translateY(0)" : "translateY(8px)", transition: "all 0.2s ease" }}>
      <svg viewBox="0 0 24 24" fill="none" stroke="var(--accent-fg)" strokeWidth="2.5" strokeLinecap="round" style={{ width: 14, height: 14, flexShrink: 0 }}>
        {toast.type === "error" ? <><circle cx="12" cy="12" r="10" /><line x1="12" y1="8" x2="12" y2="12" /><line x1="12" y1="16" x2="12.01" y2="16" /></> : <polyline points="20 6 9 17 4 12" />}
      </svg>
      {toast.message}
    </div>
  );
}