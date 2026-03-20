import React, { useState, useEffect, useRef } from "react";
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
}