import React, { useState } from "react";
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
}