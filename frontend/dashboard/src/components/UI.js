import React, { useState } from "react";
import { CAT_BADGE } from "../utils/helpers";

const BADGE_CSS = { green: { background: "var(--green-bg)", color: "var(--green)" }, blue: { background: "var(--blue-bg)", color: "var(--blue)" }, amber: { background: "var(--amber-bg)", color: "var(--amber)" }, red: { background: "var(--red-bg)", color: "var(--red)" }, neutral: { background: "var(--surface2)", color: "var(--text2)" } };
export function Badge({ label, variant }) {
  const v = variant || CAT_BADGE[label] || "neutral";
  return <span style={{ display: "inline-flex", alignItems: "center", fontSize: 11, fontWeight: 500, padding: "2px 8px", borderRadius: 50, whiteSpace: "nowrap", ...BADGE_CSS[v] }}>{label}</span>;
}

const BTN_BASE = { primary: { background: "var(--accent-bg)", color: "var(--accent-fg)", borderColor: "var(--accent-bg)" }, secondary: { background: "var(--surface)", color: "var(--text)", borderColor: "var(--border)" }, ghost: { background: "transparent", color: "var(--text2)", borderColor: "transparent" }, danger: { background: "var(--red-bg)", color: "var(--red)", borderColor: "transparent" } };
const BTN_HOV = { primary: { background: "#2d2c28" }, secondary: { background: "var(--surface2)", borderColor: "var(--border2)" }, ghost: { background: "var(--surface2)", color: "var(--text)" }, danger: { background: "#fad9d9" } };
const PAD = { lg: "11px 20px", md: "8px 14px", sm: "5px 10px" };
const SZ = { lg: 14, md: 13, sm: 12 };

export function Button({ children, variant = "secondary", size = "md", onClick, disabled, style, icon }) {
  const [h, setH] = useState(false);
  const base = BTN_BASE[variant] || BTN_BASE.secondary;
  const hov = h ? (BTN_HOV[variant] || {}) : {};
  return (
    <button onClick={onClick} disabled={disabled} onMouseEnter={() => setH(true)} onMouseLeave={() => setH(false)}
      style={{ display: "inline-flex", alignItems: "center", gap: 7, padding: PAD[size], borderRadius: "var(--r)", fontSize: SZ[size], fontWeight: 500, border: "1px solid " + base.borderColor, cursor: disabled ? "not-allowed" : "pointer", opacity: disabled ? 0.5 : 1, transition: "all 0.15s ease", ...base, ...hov, ...style }}>
      {icon && <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ width: 14, height: 14, flexShrink: 0 }}><path d={icon} /></svg>}
      {children}
    </button>
  );
}

export function Card({ children, style, padding = "20px 22px" }) {
  return <div style={{ background: "var(--surface)", border: "1px solid var(--border)", borderRadius: "var(--r-lg)", padding, ...style }}>{children}</div>;
}

const IB = { width: "100%", padding: "9px 12px", border: "1px solid var(--border)", borderRadius: "var(--r)", fontSize: 13, color: "var(--text)", background: "var(--surface)", outline: "none", transition: "border-color 0.15s, box-shadow 0.15s", WebkitAppearance: "none" };
export function Input({ value, onChange, placeholder, type = "text", style, ...rest }) {
  const [f, setF] = useState(false);
  return <input type={type} value={value} onChange={onChange} placeholder={placeholder} onFocus={() => setF(true)} onBlur={() => setF(false)} style={{ ...IB, borderColor: f ? "var(--text2)" : "var(--border)", boxShadow: f ? "0 0 0 3px rgba(26,25,22,0.07)" : "none", ...style }} {...rest} />;
}
export function Select({ value, onChange, children, style }) {
  const [f, setF] = useState(false);
  return <select value={value} onChange={onChange} onFocus={() => setF(true)} onBlur={() => setF(false)} style={{ ...IB, cursor: "pointer", borderColor: f ? "var(--text2)" : "var(--border)", boxShadow: f ? "0 0 0 3px rgba(26,25,22,0.07)" : "none", ...style }}>{children}</select>;
}
export function Textarea({ value, onChange, placeholder, minHeight = 80 }) {
  const [f, setF] = useState(false);
  return <textarea value={value} onChange={onChange} placeholder={placeholder} onFocus={() => setF(true)} onBlur={() => setF(false)} style={{ ...IB, resize: "vertical", minHeight, lineHeight: 1.5, borderColor: f ? "var(--text2)" : "var(--border)", boxShadow: f ? "0 0 0 3px rgba(26,25,22,0.07)" : "none" }} />;
}
export function FormField({ label, hint, required, children }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
      <label style={{ fontSize: 12, fontWeight: 600, color: "var(--text)", display: "flex", alignItems: "center", gap: 4 }}>
        {label}
        {required && <span style={{ width: 5, height: 5, background: "#E24B4A", borderRadius: "50%", display: "inline-block", marginLeft: 2 }} />}
        {hint && <span style={{ fontWeight: 400, fontSize: 11, color: "var(--text3)" }}>-- {hint}</span>}
      </label>
      {children}
    </div>
  );
}
export function PageHeader({ title, subtitle, action }) {
  return (
    <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", marginBottom: 24 }}>
      <div>
        <h1 style={{ fontSize: 20, fontWeight: 600, letterSpacing: "-0.3px", color: "var(--text)", marginBottom: 3 }}>{title}</h1>
        {subtitle && <p style={{ fontSize: 13, color: "var(--text2)" }}>{subtitle}</p>}
      </div>
      {action}
    </div>
  );
}
export function SectionTitle({ children }) {
  return <div style={{ fontSize: 14, fontWeight: 600, color: "var(--text)" }}>{children}</div>;
}
export function StatCard({ label, value, delta }) {
  return (
    <div style={{ background: "var(--surface)", border: "1px solid var(--border)", borderRadius: "var(--r-lg)", padding: "18px 20px" }}>
      <div style={{ fontSize: 11, fontWeight: 600, letterSpacing: "0.5px", textTransform: "uppercase", color: "var(--text3)", marginBottom: 8 }}>{label}</div>
      <div style={{ fontSize: 26, fontWeight: 600, letterSpacing: "-0.5px", color: "var(--text)", lineHeight: 1 }}>{value}</div>
      {delta && <div style={{ fontSize: 11, color: "var(--green)", marginTop: 5, display: "flex", alignItems: "center", gap: 3 }}><svg viewBox="0 0 24 24" fill="none" stroke="var(--green)" strokeWidth="2.5" strokeLinecap="round" style={{ width: 11, height: 11 }}><polyline points="23 6 13.5 15.5 8.5 10.5 1 18" /><polyline points="17 6 23 6 23 12" /></svg>{delta}</div>}
    </div>
  );
}
export function IconBtn({ d, onClick, title, danger }) {
  const [h, setH] = useState(false);
  return (
    <button onClick={onClick} title={title} onMouseEnter={() => setH(true)} onMouseLeave={() => setH(false)}
      style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 28, height: 28, borderRadius: "var(--r)", background: h ? (danger ? "var(--red-bg)" : "var(--surface2)") : "transparent", border: "none", cursor: "pointer", transition: "all 0.15s", color: danger ? "var(--red)" : "var(--text2)" }}>
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ width: 14, height: 14 }}><path d={d} /></svg>
    </button>
  );
}