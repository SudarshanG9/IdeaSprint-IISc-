import { useState, useEffect } from "react";

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
}