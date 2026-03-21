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

  const addProduct = async (data) => {
    let descriptionSegments = [];
    if (data.ingredients) descriptionSegments.push(`Ingredients: ${data.ingredients}`);
    if (data.warnings) descriptionSegments.push(`Warnings: ${data.warnings}`);
    const description = descriptionSegments.length > 0 ? descriptionSegments.join(". ") : "No extra description provided.";

    const payload = {
      name: data.name,
      category: data.cat,
      price: parseFloat(data.price) || 0,
      expiry_date: data.expiry ? new Date(data.expiry).toISOString() : new Date().toISOString(),
      description: description,
      language: "en",
      company_url: data.company_url || null
    };

    try {
      const response = await fetch("http://127.0.0.1:8000/product", {
        method: "POST",
        headers: { 
          "Content-Type": "application/json"
        },
        body: JSON.stringify(payload)
      });
      if (!response.ok) throw new Error("Failed to create product on backend.");
      
      const result = await response.json();
      const date = new Date().toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" });
      
      const p = {
        ...data,
        id: result.product_id,
        qr_url: result.qr_url,
        scan_url: result.scan_url,
        date
      };
      setProducts((prev) => [p, ...prev]);
      return p;
    } catch (e) {
      console.error(e);
      throw e;
    }
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