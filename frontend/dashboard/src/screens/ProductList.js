import React, { useState } from "react";
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
}