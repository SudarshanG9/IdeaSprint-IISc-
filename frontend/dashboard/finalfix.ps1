# finalfix.ps1
# Run from inside dashboard/ folder:
#   powershell -ExecutionPolicy Bypass -File finalfix.ps1

Write-Host "Final fix - deleting all src files and rewriting cleanly..." -ForegroundColor Cyan

# Helper - writes file with NO BOM, plain UTF8
function W($path, $text) {
    $fullPath = Join-Path (Get-Location) $path
    $dir = Split-Path $fullPath
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    [System.IO.File]::WriteAllBytes($fullPath, $bytes)
    Write-Host "  wrote $path"
}

# ── Nuke everything in src\ ───────────────────────────────────────
Write-Host "Deleting old src files..." -ForegroundColor Yellow
if (Test-Path "src") { Remove-Item -Recurse -Force "src" }
New-Item -ItemType Directory -Force -Path "src\context","src\hooks","src\utils","src\components","src\screens" | Out-Null
Write-Host "Folders recreated" -ForegroundColor Green

# ════════════════════════════════════════════════════════════════════
W "public\index.html" '<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet" />
    <title>AccessQR Dashboard</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>'

# ════════════════════════════════════════════════════════════════════
W "src\index.css" '*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
:root {
  --bg: #F7F6F3; --surface: #FFFFFF; --surface2: #F2F1EE;
  --border: #E4E2DC; --border2: #D0CEC6;
  --text: #1A1916; --text2: #6B6860; --text3: #9E9C97;
  --accent-bg: #1A1916; --accent-fg: #F7F6F3;
  --green: #2D6A4F; --green-bg: #EAF4EE;
  --blue: #1B4F8A; --blue-bg: #EBF2FB;
  --amber: #7A4F00; --amber-bg: #FDF3DC;
  --red: #8B1A1A; --red-bg: #FDECEC;
  --r: 10px; --r-lg: 14px; --sidebar: 220px;
  --font: ''DM Sans'', system-ui, sans-serif;
  --mono: ''DM Mono'', monospace;
}
html { font-family: var(--font); font-size: 14px; color: var(--text); background: var(--bg); line-height: 1.5; }
body { min-height: 100vh; }
#root { display: flex; min-height: 100vh; }
button { font-family: var(--font); cursor: pointer; border: none; background: none; }
input, select, textarea { font-family: var(--font); }
::-webkit-scrollbar { width: 5px; } ::-webkit-scrollbar-thumb { background: var(--border2); border-radius: 10px; }
@keyframes fadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
.fade-up { animation: fadeUp 0.22s ease both; }'

# ════════════════════════════════════════════════════════════════════
W "src\index.js" 'import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<React.StrictMode><App /></React.StrictMode>);'

# ════════════════════════════════════════════════════════════════════
W "src\App.css" '#root { display: flex; min-height: 100vh; background: var(--bg); }'

# ════════════════════════════════════════════════════════════════════
W "src\App.js" 'import React, { useState } from "react";
import "./App.css";
import { AppContext } from "./context/AppContext";
import { useProducts } from "./hooks/useProducts";
import { useToast } from "./hooks/useToast";
import Sidebar from "./components/Sidebar";
import Topbar from "./components/Topbar";
import Toast from "./components/Toast";
import DeleteModal from "./components/DeleteModal";
import Dashboard from "./screens/Dashboard";
import AddProduct from "./screens/AddProduct";
import ProductList from "./screens/ProductList";
import EditProduct from "./screens/EditProduct";
import OutputScreen from "./screens/OutputScreen";

const LABELS = {
  dashboard: "Overview / Dashboard",
  add: "Products / Add Product",
  products: "Products / All Products",
  edit: "Products / Edit Product",
  output: "Products / Output",
};

export default function App() {
  const [screen, setScreen] = useState("dashboard");
  const [editingId, setEditingId] = useState(null);
  const [outputProduct, setOutputProduct] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);
  const { products, addProduct, updateProduct, deleteProduct } = useProducts();
  const { toasts, showToast } = useToast();

  const navigate = (scr, extra = {}) => {
    setScreen(scr);
    if (scr === "edit" && extra.id) setEditingId(extra.id);
    if (scr === "output" && extra.product) setOutputProduct(extra.product);
  };

  const handleDeleteConfirm = () => {
    deleteProduct(deleteTarget.id);
    showToast("Product deleted");
    setDeleteTarget(null);
  };

  const ctx = { products, navigate, showToast, addProduct, updateProduct, deleteProduct, setDeleteTarget };

  return (
    <AppContext.Provider value={ctx}>
      <Sidebar currentScreen={screen} />
      <div style={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0, overflow: "hidden" }}>
        <Topbar label={LABELS[screen] || ""} />
        <main style={{ flex: 1, overflowY: "auto", padding: "28px 32px", background: "var(--bg)" }}>
          {screen === "dashboard" && <Dashboard />}
          {screen === "add" && <AddProduct />}
          {screen === "products" && <ProductList />}
          {screen === "edit" && <EditProduct id={editingId} />}
          {screen === "output" && <OutputScreen product={outputProduct} />}
        </main>
      </div>
      {toasts.map((t) => <Toast key={t.id} toast={t} />)}
      {deleteTarget && <DeleteModal name={deleteTarget.name} onCancel={() => setDeleteTarget(null)} onConfirm={handleDeleteConfirm} />}
    </AppContext.Provider>
  );
}'

# ════════════════════════════════════════════════════════════════════
W "src\context\AppContext.js" 'import { createContext, useContext } from "react";
export const AppContext = createContext(null);
export const useApp = () => useContext(AppContext);'

# ════════════════════════════════════════════════════════════════════
W "src\hooks\useProducts.js" 'import { useState, useEffect } from "react";

const SEED = [
  { id: "PRD001", name: "Maggi 2-Minute Noodles", cat: "Instant Food", price: "14.00", expiry: "2025-12-31", ingredients: "Wheat flour, Palm oil, Salt, Tastemaker", warnings: "Contains gluten. May contain traces of soy.", date: "Mar 18, 2026" },
  { id: "PRD002", name: "Paracetamol 500mg", cat: "Medicine", price: "22.00", expiry: "2026-06-15", ingredients: "Paracetamol 500mg, Microcrystalline cellulose", warnings: "Do not exceed 4 doses in 24 hours.", date: "Mar 17, 2026" },
  { id: "PRD003", name: "Tata Salt Iodised", cat: "Groceries", price: "28.00", expiry: "2026-03-10", ingredients: "Salt, Potassium iodate", warnings: "Store in a cool dry place.", date: "Mar 15, 2026" },
  { id: "PRD004", name: "Dove Body Lotion", cat: "Personal Care", price: "185.00", expiry: "2027-01-01", ingredients: "Water, Glycerin, Mineral Oil", warnings: "External use only.", date: "Mar 14, 2026" },
];

function load() {
  try { const r = localStorage.getItem("accessqr_products"); if (r) return JSON.parse(r); } catch {}
  return SEED;
}
function persist(p) { try { localStorage.setItem("accessqr_products", JSON.stringify(p)); } catch {} }
let idc = 100;

export function useProducts() {
  const [products, setProducts] = useState(load);
  useEffect(() => { persist(products); }, [products]);

  const addProduct = (data) => {
    idc++;
    const date = new Date().toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" });
    const p = { ...data, id: "PRD" + String(idc).padStart(3, "0"), date };
    setProducts((prev) => [p, ...prev]);
    return p;
  };

  const updateProduct = (id, data) => {
    const date = new Date().toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" });
    let updated;
    setProducts((prev) => prev.map((p) => { if (p.id !== id) return p; updated = { ...p, ...data, date }; return updated; }));
    return updated;
  };

  const deleteProduct = (id) => setProducts((prev) => prev.filter((p) => p.id !== id));
  return { products, addProduct, updateProduct, deleteProduct };
}'

# ════════════════════════════════════════════════════════════════════
W "src\hooks\useToast.js" 'import { useState, useCallback } from "react";
let tid = 0;
export function useToast() {
  const [toasts, setToasts] = useState([]);
  const showToast = useCallback((message, type = "success") => {
    const id = ++tid;
    setToasts((prev) => [...prev, { id, message, type }]);
    setTimeout(() => setToasts((prev) => prev.filter((t) => t.id !== id)), 3000);
  }, []);
  return { toasts, showToast };
}'

# ════════════════════════════════════════════════════════════════════
W "src\utils\helpers.js" 'export const CATEGORIES = ["Groceries","Instant Food","Medicine","Personal Care","Household","Dairy","Beverages"];
export const CAT_BADGE = { "Groceries":"blue","Instant Food":"green","Medicine":"amber","Personal Care":"neutral","Household":"neutral","Dairy":"blue","Beverages":"green" };

export function formatPrice(val) {
  const n = parseFloat(val);
  return isNaN(n) ? "--" : "\u20B9" + n.toFixed(2);
}

export function formatDate(dateStr) {
  if (!dateStr) return "--";
  try { return new Date(dateStr).toLocaleDateString("en-IN", { day: "numeric", month: "long", year: "numeric" }); }
  catch { return dateStr; }
}

export function generateDescription(p) {
  let d = p.name + ". Category: " + p.cat + ".";
  if (p.price) d += " Price: " + formatPrice(p.price) + ".";
  if (p.expiry) d += " Best before: " + formatDate(p.expiry) + ".";
  if (p.ingredients) d += " Ingredients: " + p.ingredients + ".";
  if (p.warnings) d += " Warning: " + p.warnings;
  return d;
}
export const API_BASE = process.env.REACT_APP_API_URL || "http://localhost:5000";'

# ════════════════════════════════════════════════════════════════════
W "src\components\Sidebar.css" '.sidebar { width: var(--sidebar); flex-shrink: 0; background: var(--surface); border-right: 1px solid var(--border); display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; overflow: hidden; }
.sidebar-brand { padding: 20px 18px 16px; border-bottom: 1px solid var(--border); }
.brand-mark { display: flex; align-items: center; gap: 9px; }
.brand-icon { width: 28px; height: 28px; background: var(--accent-bg); border-radius: 7px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.brand-name { font-size: 14px; font-weight: 600; letter-spacing: -0.2px; color: var(--text); }
.brand-tag { font-size: 10px; color: var(--text3); margin-top: 1px; }
.sidebar-nav { flex: 1; padding: 10px; overflow-y: auto; }
.nav-section { font-size: 10px; font-weight: 600; letter-spacing: 0.8px; text-transform: uppercase; color: var(--text3); padding: 10px 8px 4px; }
.nav-item { display: flex; align-items: center; gap: 10px; padding: 8px 10px; border-radius: var(--r); font-size: 13px; font-weight: 500; color: var(--text2); transition: all 0.15s; width: 100%; text-align: left; background: none; border: none; cursor: pointer; }
.nav-item:hover { background: var(--surface2); color: var(--text); }
.nav-item.active { background: var(--accent-bg); color: var(--accent-fg); }
.nav-badge { margin-left: auto; font-size: 10px; font-weight: 600; background: var(--surface2); color: var(--text2); padding: 1px 6px; border-radius: 50px; }
.nav-item.active .nav-badge { background: rgba(255,255,255,0.15); color: rgba(255,255,255,0.8); }
.sidebar-footer { padding: 12px 10px; border-top: 1px solid var(--border); }
.user-pill { display: flex; align-items: center; gap: 9px; padding: 8px 10px; border-radius: var(--r); cursor: pointer; transition: background 0.15s; }
.user-pill:hover { background: var(--surface2); }
.avatar { width: 28px; height: 28px; border-radius: 50%; background: var(--accent-bg); color: var(--accent-fg); display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; flex-shrink: 0; }
.user-name { font-size: 12px; font-weight: 600; color: var(--text); }
.user-role { font-size: 10px; color: var(--text3); }'

# ════════════════════════════════════════════════════════════════════
W "src\components\Sidebar.js" 'import React from "react";
import { useApp } from "../context/AppContext";
import "./Sidebar.css";

const NAV = [
  { id: "dashboard", label: "Dashboard", d: "M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h7v7h-7z" },
  { id: "add", label: "Add Product", d: "M12 5v14M5 12h14" },
  { id: "products", label: "Products", d: "M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z", showBadge: true },
];

export default function Sidebar({ currentScreen }) {
  const { navigate, products } = useApp();
  const isActive = (id) => currentScreen === id || (currentScreen === "output" && id === "products");
  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <div className="brand-mark">
          <div className="brand-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="#F7F6F3" strokeWidth="2" strokeLinecap="round" style={{ width: 14, height: 14 }}>
              <rect x="3" y="3" width="7" height="7" rx="1" /><rect x="14" y="3" width="7" height="7" rx="1" />
              <rect x="3" y="14" width="7" height="7" rx="1" /><path d="M14 14h1v1M16 16h1M18 14v1M14 18h2M17 18h1v1" />
            </svg>
          </div>
          <div><div className="brand-name">AccessQR</div><div className="brand-tag">B2B Platform</div></div>
        </div>
      </div>
      <nav className="sidebar-nav">
        <div className="nav-section">Main</div>
        {NAV.map((item) => (
          <button key={item.id} className={"nav-item" + (isActive(item.id) ? " active" : "")} onClick={() => navigate(item.id)}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ width: 15, height: 15, flexShrink: 0 }}>
              <path d={item.d} />
            </svg>
            {item.label}
            {item.showBadge && <span className="nav-badge">{products.length}</span>}
          </button>
        ))}
      </nav>
      <div className="sidebar-footer">
        <div className="user-pill">
          <div className="avatar">NS</div>
          <div><div className="user-name">Nandini Shah</div><div className="user-role">Admin</div></div>
        </div>
      </div>
    </aside>
  );
}'

# ════════════════════════════════════════════════════════════════════
W "src\components\Topbar.js" 'import React from "react";
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
}'

# ════════════════════════════════════════════════════════════════════
W "src\components\Toast.js" 'import React, { useEffect, useState } from "react";
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
}'

# ════════════════════════════════════════════════════════════════════
W "src\components\DeleteModal.js" 'import React, { useEffect } from "react";
import { Button } from "./UI";
export default function DeleteModal({ name, onCancel, onConfirm }) {
  useEffect(() => {
    const h = (e) => { if (e.key === "Escape") onCancel(); };
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, [onCancel]);
  return (
    <div onClick={(e) => { if (e.target === e.currentTarget) onCancel(); }} style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.35)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000 }}>
      <div className="fade-up" style={{ background: "var(--surface)", border: "1px solid var(--border)", borderRadius: "var(--r-lg)", padding: 24, width: 340 }}>
        <div style={{ fontSize: 15, fontWeight: 600, marginBottom: 8, color: "var(--text)" }}>Delete product?</div>
        <p style={{ fontSize: 13, color: "var(--text2)", marginBottom: 20, lineHeight: 1.6 }}>
          This will permanently remove <strong style={{ color: "var(--text)" }}>{name}</strong> and its QR code. This cannot be undone.
        </p>
        <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
          <Button variant="secondary" onClick={onCancel}>Cancel</Button>
          <Button variant="danger" onClick={onConfirm}>Delete product</Button>
        </div>
      </div>
    </div>
  );
}'

# ════════════════════════════════════════════════════════════════════
W "src\components\UI.js" 'import React, { useState } from "react";
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
}'

# ════════════════════════════════════════════════════════════════════
W "src\components\ProductForm.js" 'import React from "react";
import { Card, FormField, Input, Select, Textarea, Button, Badge } from "./UI";
import { CATEGORIES } from "../utils/helpers";

export default function ProductForm({ values, onChange, onSubmit, onCancel, submitLabel, badge }) {
  const set = (field) => (e) => onChange({ ...values, [field]: e.target.value });
  return (
    <Card>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 20 }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: "var(--text)" }}>Product information</div>
        {badge && <Badge label={badge} variant={badge === "Editing" ? "amber" : "green"} />}
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 18 }}>
        <FormField label="Product name" required><Input value={values.name || ""} onChange={set("name")} placeholder="e.g. Maggi 2-Minute Noodles" /></FormField>
        <FormField label="Category" required>
          <Select value={values.cat || ""} onChange={set("cat")}>
            <option value="">Select category...</option>
            {CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
          </Select>
        </FormField>
        <FormField label="Price (Rs.)"><Input type="number" value={values.price || ""} onChange={set("price")} placeholder="0.00" min="0" step="0.01" /></FormField>
        <FormField label="Expiry date"><Input type="date" value={values.expiry || ""} onChange={set("expiry")} /></FormField>
        <div style={{ gridColumn: "1 / -1" }}><FormField label="Ingredients" hint="optional"><Textarea value={values.ingredients || ""} onChange={set("ingredients")} placeholder="List ingredients separated by commas..." /></FormField></div>
        <div style={{ gridColumn: "1 / -1" }}><FormField label="Warnings" hint="optional"><Textarea value={values.warnings || ""} onChange={set("warnings")} placeholder="e.g. Contains gluten, keep away from children..." /></FormField></div>
      </div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", paddingTop: 20, marginTop: 4, borderTop: "1px solid var(--border)" }}>
        <Button variant="ghost" onClick={onCancel}>Cancel</Button>
        <Button variant="primary" size="lg" onClick={onSubmit} icon="M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3z">{submitLabel || "Generate QR & description"}</Button>
      </div>
    </Card>
  );
}'

# ════════════════════════════════════════════════════════════════════
W "src\screens\Dashboard.js" 'import React from "react";
import { useApp } from "../context/AppContext";
import { StatCard, Card, SectionTitle, Badge, Button, PageHeader } from "../components/UI";
import { CAT_BADGE } from "../utils/helpers";

export default function Dashboard() {
  const { products, navigate } = useApp();
  return (
    <div className="fade-up">
      <PageHeader title="Good morning, Nandini" subtitle="Here is your accessibility product overview" />
      <div style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: 12, marginBottom: 24 }}>
        <StatCard label="Total Products" value={products.length} delta="+2 this week" />
        <StatCard label="QR Codes Generated" value={products.length} delta="+5 this month" />
        <StatCard label="Audio Descriptions" value={products.length} delta="100% generated" />
      </div>
      <div style={{ display: "flex", gap: 14, alignItems: "flex-start" }}>
        <Card style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
            <SectionTitle>Recent products</SectionTitle>
            <button onClick={() => navigate("products")} style={{ fontSize: 12, color: "var(--text2)", cursor: "pointer", border: "none", background: "none", textDecoration: "underline", textUnderlineOffset: 2 }}>View all</button>
          </div>
          {products.length === 0
            ? <div style={{ textAlign: "center", padding: "32px 0", color: "var(--text3)", fontSize: 13 }}>No products yet -- add one to get started</div>
            : products.slice(0, 5).map((p, i) => (
              <div key={p.id} style={{ display: "flex", alignItems: "center", gap: 12, padding: "10px 0", borderBottom: i < Math.min(products.length, 5) - 1 ? "1px solid var(--border)" : "none" }}>
                <div style={{ width: 32, height: 32, borderRadius: 8, background: "var(--surface2)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                  <svg viewBox="0 0 24 24" fill="none" stroke="var(--text2)" strokeWidth="2" strokeLinecap="round" style={{ width: 14, height: 14 }}><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" /></svg>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 500, color: "var(--text)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{p.name}</div>
                  <div style={{ fontSize: 11, color: "var(--text3)", marginTop: 1 }}>{p.date}</div>
                </div>
                <Badge label={p.cat} variant={CAT_BADGE[p.cat]} />
              </div>
            ))
          }
        </Card>
        <div style={{ width: 230, flexShrink: 0, display: "flex", flexDirection: "column", gap: 12 }}>
          <Card padding="16px 18px">
            <SectionTitle>Quick actions</SectionTitle>
            <div style={{ marginTop: 12, display: "flex", flexDirection: "column", gap: 8 }}>
              <Button variant="primary" onClick={() => navigate("add")} style={{ justifyContent: "center", width: "100%" }} icon="M12 5v14M5 12h14">Add new product</Button>
              <Button variant="secondary" onClick={() => navigate("products")} style={{ justifyContent: "center", width: "100%" }} icon="M8 6h13M8 12h13M8 18h13">View all products</Button>
            </div>
          </Card>
          <Card padding="16px 18px">
            <SectionTitle>Last activity</SectionTitle>
            <div style={{ marginTop: 12 }}>
              {[{ color: "var(--green)", text: "QR generated for", bold: products[0]?.name || "--", time: "2 hours ago" }, { color: "var(--blue)", text: "Product edited:", bold: products[1]?.name || "--", time: "Yesterday" }, { color: "var(--amber)", text: "Product added:", bold: products[2]?.name || "--", time: "2 days ago" }].map((item, i, arr) => (
                <div key={i} style={{ display: "flex", gap: 8, padding: "5px 0", borderBottom: i < arr.length - 1 ? "1px solid var(--border)" : "none" }}>
                  <div style={{ width: 5, height: 5, background: item.color, borderRadius: "50%", marginTop: 6, flexShrink: 0 }} />
                  <div style={{ fontSize: 12, color: "var(--text2)", lineHeight: 1.5 }}>{item.text} <strong style={{ color: "var(--text)" }}>{item.bold}</strong><div style={{ fontSize: 11, color: "var(--text3)" }}>{item.time}</div></div>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}'

# ════════════════════════════════════════════════════════════════════
W "src\screens\AddProduct.js" 'import React, { useState } from "react";
import { useApp } from "../context/AppContext";
import { PageHeader } from "../components/UI";
import ProductForm from "../components/ProductForm";
const EMPTY = { name: "", cat: "", price: "", expiry: "", ingredients: "", warnings: "" };
export default function AddProduct() {
  const { addProduct, navigate, showToast } = useApp();
  const [values, setValues] = useState(EMPTY);
  const handleSubmit = () => {
    if (!values.name.trim()) { showToast("Please enter a product name", "error"); return; }
    if (!values.cat) { showToast("Please select a category", "error"); return; }
    const product = addProduct(values);
    navigate("output", { product });
    showToast("QR and description generated!");
  };
  return (
    <div className="fade-up">
      <PageHeader title="Add new product" subtitle="Fill in product details to generate an accessible QR description" />
      <ProductForm values={values} onChange={setValues} onSubmit={handleSubmit} onCancel={() => navigate("dashboard")} submitLabel="Generate QR & description" />
    </div>
  );
}'

# ════════════════════════════════════════════════════════════════════
W "src\screens\EditProduct.js" 'import React, { useState } from "react";
import { useApp } from "../context/AppContext";
import { PageHeader } from "../components/UI";
import ProductForm from "../components/ProductForm";
export default function EditProduct({ id }) {
  const { products, updateProduct, navigate, showToast } = useApp();
  const existing = products.find((p) => p.id === id);
  const [values, setValues] = useState(existing || {});
  if (!existing) return <div className="fade-up" style={{ textAlign: "center", paddingTop: 60, color: "var(--text3)" }}>Product not found. <button onClick={() => navigate("products")} style={{ color: "var(--blue)", border: "none", background: "none", cursor: "pointer", fontSize: 14 }}>Go back</button></div>;
  const handleSave = () => {
    if (!values.name?.trim()) { showToast("Product name required", "error"); return; }
    if (!values.cat) { showToast("Category required", "error"); return; }
    const updated = updateProduct(id, values);
    navigate("output", { product: updated });
    showToast("Product updated and QR regenerated");
  };
  return (
    <div className="fade-up">
      <PageHeader title="Edit product" subtitle="Changes will regenerate the audio description and QR code" />
      <ProductForm values={values} onChange={setValues} onSubmit={handleSave} onCancel={() => navigate("products")} submitLabel="Save & regenerate" badge="Editing" />
    </div>
  );
}'

# ════════════════════════════════════════════════════════════════════
W "src\screens\ProductList.js" 'import React, { useState } from "react";
import { useApp } from "../context/AppContext";
import { PageHeader, Badge, Button, IconBtn, Input, Select } from "../components/UI";
import { CAT_BADGE, CATEGORIES, formatPrice } from "../utils/helpers";

export default function ProductList() {
  const { products, navigate, setDeleteTarget } = useApp();
  const [search, setSearch] = useState("");
  const [catFilter, setCat] = useState("");
  const filtered = products.filter((p) => {
    const q = search.toLowerCase();
    return (!q || p.name.toLowerCase().includes(q) || p.id.toLowerCase().includes(q) || p.cat.toLowerCase().includes(q)) && (!catFilter || p.cat === catFilter);
  });
  return (
    <div className="fade-up">
      <PageHeader title="Products" subtitle={products.length + " product" + (products.length !== 1 ? "s" : "") + " total"} action={<Button variant="primary" onClick={() => navigate("add")} icon="M12 5v14M5 12h14">Add product</Button>} />
      <div style={{ display: "flex", gap: 8, marginBottom: 14 }}>
        <div style={{ position: "relative", flex: "0 0 260px" }}>
          <svg viewBox="0 0 24 24" fill="none" stroke="var(--text3)" strokeWidth="2" strokeLinecap="round" style={{ width: 14, height: 14, position: "absolute", left: 10, top: "50%", transform: "translateY(-50%)", pointerEvents: "none" }}><circle cx="11" cy="11" r="8" /><line x1="21" y1="21" x2="16.65" y2="16.65" /></svg>
          <Input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search products..." style={{ paddingLeft: 32 }} />
        </div>
        <Select value={catFilter} onChange={(e) => setCat(e.target.value)} style={{ width: 170 }}>
          <option value="">All categories</option>
          {CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
        </Select>
        {(search || catFilter) && <Button variant="ghost" onClick={() => { setSearch(""); setCat(""); }}>Clear</Button>}
      </div>
      <div style={{ borderRadius: "var(--r-lg)", border: "1px solid var(--border)", overflow: "hidden" }}>
        <table style={{ width: "100%", borderCollapse: "collapse", background: "var(--surface)", tableLayout: "fixed" }}>
          <colgroup><col style={{ width: "32%" }} /><col style={{ width: "16%" }} /><col style={{ width: "14%" }} /><col style={{ width: "18%" }} /><col style={{ width: "20%" }} /></colgroup>
          <thead><tr style={{ background: "var(--surface2)", borderBottom: "1px solid var(--border)" }}>{["Product","Category","Price","Last updated","Actions"].map((h) => <th key={h} style={{ padding: "10px 16px", fontSize: 11, fontWeight: 600, letterSpacing: "0.5px", textTransform: "uppercase", color: "var(--text3)", textAlign: "left" }}>{h}</th>)}</tr></thead>
          <tbody>
            {filtered.length === 0
              ? <tr><td colSpan={5}><div style={{ textAlign: "center", padding: "48px 20px" }}><div style={{ fontSize: 13, fontWeight: 500, color: "var(--text2)", marginBottom: 4 }}>{search || catFilter ? "No products match your search" : "No products yet"}</div><div style={{ fontSize: 12, color: "var(--text3)" }}>{search || catFilter ? "Try a different search term" : "Add your first product to get started"}</div></div></td></tr>
              : filtered.map((p, i) => <ProductRow key={p.id} product={p} isLast={i === filtered.length - 1} onView={() => navigate("output", { product: p })} onEdit={() => navigate("edit", { id: p.id })} onDelete={() => setDeleteTarget({ id: p.id, name: p.name })} />)}
          </tbody>
        </table>
      </div>
      {filtered.length > 0 && <div style={{ marginTop: 12, fontSize: 12, color: "var(--text3)" }}>Showing {filtered.length} of {products.length} product{products.length !== 1 ? "s" : ""}</div>}
    </div>
  );
}

function ProductRow({ product: p, isLast, onView, onEdit, onDelete }) {
  const [hov, setHov] = useState(false);
  return (
    <tr onMouseEnter={() => setHov(true)} onMouseLeave={() => setHov(false)} style={{ borderBottom: isLast ? "none" : "1px solid var(--border)", background: hov ? "var(--surface2)" : "var(--surface)", transition: "background 0.1s" }}>
      <td style={{ padding: "12px 16px" }}><div style={{ fontSize: 13, fontWeight: 500, color: "var(--text)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{p.name}</div><div style={{ fontSize: 11, color: "var(--text3)", marginTop: 2, fontFamily: "var(--mono)" }}>{p.id}</div></td>
      <td style={{ padding: "12px 16px" }}><Badge label={p.cat} variant={CAT_BADGE[p.cat]} /></td>
      <td style={{ padding: "12px 16px", fontSize: 13, color: "var(--text)" }}>{formatPrice(p.price)}</td>
      <td style={{ padding: "12px 16px", fontSize: 12, color: "var(--text2)" }}>{p.date}</td>
      <td style={{ padding: "12px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 2 }}>
          <IconBtn d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z" onClick={onView} title="View" />
          <IconBtn d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7 M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" onClick={onEdit} title="Edit" />
          <IconBtn d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4 M7 10l5 5 5-5 M12 15V3" onClick={() => alert("Downloading QR for " + p.name)} title="Download QR" />
          <IconBtn d="M3 6h18 M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6 M10 11v6 M14 11v6 M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2" onClick={onDelete} title="Delete" danger />
        </div>
      </td>
    </tr>
  );
}'

# ════════════════════════════════════════════════════════════════════
W "src\screens\OutputScreen.js" 'import React, { useState, useEffect, useRef } from "react";
import { useApp } from "../context/AppContext";
import { PageHeader, Card, Badge, Button, SectionTitle } from "../components/UI";
import { CAT_BADGE, generateDescription, formatPrice, formatDate } from "../utils/helpers";

function QRDisplay({ productId }) {
  const fixed = new Set(["0,0","0,1","0,2","0,3","0,4","0,5","0,6","1,0","1,6","2,0","2,2","2,3","2,4","2,6","3,0","3,2","3,3","3,4","3,6","4,0","4,2","4,3","4,4","4,6","5,0","5,6","6,0","6,1","6,2","6,3","6,4","6,5","6,6"]);
  let seed = 0;
  for (let i = 0; i < productId.length; i++) seed = (seed * 31 + productId.charCodeAt(i)) & 0xffffffff;
  const rand = () => { seed = (seed * 1664525 + 1013904223) & 0xffffffff; return (seed >>> 0) / 0xffffffff; };
  const cells = [];
  for (let r = 0; r < 7; r++) for (let c = 0; c < 7; c++) cells.push(<div key={r + "-" + c} style={{ borderRadius: 1, background: (fixed.has(r + "," + c) || rand() > 0.45) ? "#F7F6F3" : "transparent" }} />);
  return <div style={{ width: 150, height: 150, background: "#1A1916", borderRadius: 10, display: "grid", gridTemplateColumns: "repeat(7,1fr)", gap: 2, padding: 12 }}>{cells}</div>;
}

function AudioPlayer({ description }) {
  const [playing, setPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const iRef = useRef(null);
  const heights = [30,55,40,70,85,60,45,75,50,65,80,55,70,40,60,75,45,65,80,50,35,60];
  const handlePlay = () => {
    if (playing) { clearInterval(iRef.current); window.speechSynthesis?.cancel(); setPlaying(false); }
    else {
      setPlaying(true); setProgress(0);
      if ("speechSynthesis" in window) { window.speechSynthesis.cancel(); const u = new SpeechSynthesisUtterance(description); u.rate = 0.9; u.onend = () => { setPlaying(false); setProgress(0); }; window.speechSynthesis.speak(u); }
      let p = 0; iRef.current = setInterval(() => { p++; setProgress(p); if (p >= heights.length) { clearInterval(iRef.current); setPlaying(false); setProgress(0); } }, 150);
    }
  };
  useEffect(() => () => { clearInterval(iRef.current); window.speechSynthesis?.cancel(); }, []);
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 12, background: "var(--surface2)", borderRadius: "var(--r)", padding: "10px 14px", marginTop: 14 }}>
      <button onClick={handlePlay} style={{ width: 34, height: 34, borderRadius: "50%", background: "var(--accent-bg)", border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", flexShrink: 0 }}>
        <svg viewBox="0 0 24 24" fill="var(--accent-fg)" style={{ width: 13, height: 13, marginLeft: playing ? 0 : 2 }}>
          {playing ? <><rect x="6" y="4" width="4" height="16" rx="1" /><rect x="14" y="4" width="4" height="16" rx="1" /></> : <polygon points="5 3 19 12 5 21 5 3" />}
        </svg>
      </button>
      <div style={{ flex: 1, display: "flex", alignItems: "center", gap: 2, height: 30 }}>
        {heights.map((h, i) => <div key={i} style={{ flex: 1, borderRadius: 2, background: i <= progress && playing ? "var(--accent-bg)" : "var(--border2)", height: h + "%", transition: "background 0.15s" }} />)}
      </div>
      <span style={{ fontSize: 11, color: "var(--text3)", fontFamily: "var(--mono)", flexShrink: 0 }}>{playing ? "..." : "0:00"}</span>
    </div>
  );
}

export default function OutputScreen({ product }) {
  const { navigate } = useApp();
  if (!product) return <div className="fade-up" style={{ textAlign: "center", paddingTop: 60, color: "var(--text3)" }}>No product. <button onClick={() => navigate("products")} style={{ color: "var(--blue)", border: "none", background: "none", cursor: "pointer" }}>Go back</button></div>;
  const description = generateDescription(product);
  return (
    <div className="fade-up">
      <PageHeader title="Output generated" subtitle="QR code and accessible description are ready" />
      <div style={{ background: "var(--green-bg)", border: "1px solid #b7dfc9", borderRadius: "var(--r-lg)", padding: "12px 16px", display: "flex", alignItems: "center", gap: 10, marginBottom: 22 }}>
        <svg viewBox="0 0 24 24" fill="none" stroke="var(--green)" strokeWidth="2.5" strokeLinecap="round" style={{ width: 16, height: 16, flexShrink: 0 }}><polyline points="20 6 9 17 4 12" /></svg>
        <span style={{ fontSize: 13, color: "var(--green)", fontWeight: 500 }}>Product saved -- QR code and audio description generated successfully</span>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "200px 1fr", gap: 20, alignItems: "start" }}>
        <div style={{ background: "var(--surface)", border: "1px solid var(--border)", borderRadius: "var(--r-lg)", padding: "20px 16px", display: "flex", flexDirection: "column", alignItems: "center", gap: 14 }}>
          <QRDisplay productId={product.id} />
          <div style={{ textAlign: "center" }}><div style={{ fontSize: 11, fontFamily: "var(--mono)", color: "var(--text3)", marginBottom: 2 }}>{product.id}</div><div style={{ fontSize: 11, color: "var(--text3)" }}>Scan with AccessQR app</div></div>
          <Button variant="primary" onClick={() => alert("QR for " + product.name + " would download here.")} style={{ width: "100%", justifyContent: "center" }} icon="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4 M7 10l5 5 5-5 M12 15V3">Download QR</Button>
          <Button variant="secondary" onClick={() => navigate("edit", { id: product.id })} style={{ width: "100%", justifyContent: "center" }} icon="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7 M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z">Edit product</Button>
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <Card padding="0">
            <div style={{ padding: "13px 18px", borderBottom: "1px solid var(--border)", display: "flex", alignItems: "center", justifyContent: "space-between" }}><SectionTitle>Generated description</SectionTitle><Badge label="Auto-generated" variant="green" /></div>
            <div style={{ padding: "16px 18px" }}>
              <div style={{ fontSize: 11, fontWeight: 600, letterSpacing: "0.5px", textTransform: "uppercase", color: "var(--text3)", marginBottom: 8 }}>Accessible audio text</div>
              <p style={{ fontSize: 14, color: "var(--text)", lineHeight: 1.7 }}>{description}</p>
              <AudioPlayer description={description} />
            </div>
          </Card>
          <Card>
            <SectionTitle>Product summary</SectionTitle>
            <table style={{ width: "100%", fontSize: 13, borderCollapse: "collapse", marginTop: 12 }}>
              <tbody>{[{ label: "Name", value: product.name }, { label: "Category", value: <Badge label={product.cat} variant={CAT_BADGE[product.cat]} /> }, { label: "Price", value: formatPrice(product.price) }, { label: "Expiry", value: formatDate(product.expiry) }, { label: "Ingredients", value: product.ingredients || "--" }, { label: "Warnings", value: product.warnings || "--" }].map(({ label, value }) => (
                <tr key={label}><td style={{ padding: "5px 0", color: "var(--text2)", width: 110, verticalAlign: "top" }}>{label}</td><td style={{ padding: "5px 0", color: "var(--text)", lineHeight: 1.5 }}>{value}</td></tr>
              ))}</tbody>
            </table>
          </Card>
          <div style={{ display: "flex", gap: 8 }}>
            <Button variant="secondary" onClick={() => navigate("products")} icon="M8 6h13M8 12h13M8 18h13">View all products</Button>
            <Button variant="primary" onClick={() => navigate("add")} icon="M12 5v14M5 12h14">Add another product</Button>
          </div>
        </div>
      </div>
    </div>
  );
}'

# ════════════════════════════════════════════════════════════════════
W ".env" 'REACT_APP_API_URL=http://localhost:5000'

Write-Host ""
Write-Host "Done! Run: npm start" -ForegroundColor Cyan