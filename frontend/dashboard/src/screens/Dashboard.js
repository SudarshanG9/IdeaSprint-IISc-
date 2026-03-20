import React from "react";
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
}