import React, { useState } from "react";
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
}