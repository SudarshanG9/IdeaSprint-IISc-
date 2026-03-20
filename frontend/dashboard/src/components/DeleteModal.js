import React, { useEffect } from "react";
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
}