import React from "react";
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
}