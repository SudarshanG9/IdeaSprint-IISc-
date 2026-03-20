import React, { useState } from "react";
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
}