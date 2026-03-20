import React from "react";
export default function Topbar({ label }) {
  const parts = label.split(" / ");
  return (
    <header style={{ height: 52, background: "var(--surface)", borderBottom: "1px solid var(--border)", display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 28px", flexShrink: 0 }}>
      <span style={{ fontSize: 13, color: "var(--text2)" }}>
        {parts[0]}
        {parts[1] && <><span style={{ margin: "0 5px", color: "var(--text3)" }}>/</span><span style={{ color: "var(--text)", fontWeight: 500 }}>{parts[1]}</span></>}
      </span>
      <div style={{ display: "flex", gap: 8 }}>
        {["M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9 M13.73 21a2 2 0 0 1-3.46 0", "M12 20h9 M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"].map((d, i) => (
          <button key={i} style={{ width: 32, height: 32, borderRadius: 8, border: "1px solid var(--border)", background: "var(--surface)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
            <svg viewBox="0 0 24 24" fill="none" stroke="var(--text2)" strokeWidth="2" strokeLinecap="round" style={{ width: 14, height: 14 }}>
              {d.split(" M").map((seg, j) => <path key={j} d={j === 0 ? seg : "M" + seg} />)}
            </svg>
          </button>
        ))}
      </div>
    </header>
  );
}