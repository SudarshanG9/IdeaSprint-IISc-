import React from "react";
import { Card, FormField, Input, Select, Textarea, Button, Badge } from "./UI";
import { CATEGORIES } from "../utils/helpers";

export default function ProductForm({ values, onChange, onSubmit, onCancel, submitLabel, badge }) {
  const set = (field) => (e) => onChange({ ...values, [field]: e.target.value });
  return (
    <Card>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 20 }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: "var(--text)" }}>Product information</div>
        {badge && <Badge label={badge} variant={badge === "Editing" ? "amber" : "green"} />}
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 18 }}>
        <FormField label="Product name" required><Input value={values.name || ""} onChange={set("name")} placeholder="e.g. Maggi 2-Minute Noodles" /></FormField>
        <FormField label="Category" required>
          <Select value={values.cat || ""} onChange={set("cat")}>
            <option value="">Select category...</option>
            {CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
          </Select>
        </FormField>
        <FormField label="Price (Rs.)"><Input type="number" value={values.price || ""} onChange={set("price")} placeholder="0.00" min="0" step="0.01" /></FormField>
        <FormField label="Expiry date"><Input type="date" value={values.expiry || ""} onChange={set("expiry")} /></FormField>
        <div style={{ gridColumn: "1 / -1" }}><FormField label="Ingredients" hint="optional"><Textarea value={values.ingredients || ""} onChange={set("ingredients")} placeholder="List ingredients separated by commas..." /></FormField></div>
        <div style={{ gridColumn: "1 / -1" }}><FormField label="Warnings" hint="optional"><Textarea value={values.warnings || ""} onChange={set("warnings")} placeholder="e.g. Contains gluten, keep away from children..." /></FormField></div>
      </div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", paddingTop: 20, marginTop: 4, borderTop: "1px solid var(--border)" }}>
        <Button variant="ghost" onClick={onCancel}>Cancel</Button>
        <Button variant="primary" size="lg" onClick={onSubmit} icon="M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3z">{submitLabel || "Generate QR & description"}</Button>
      </div>
    </Card>
  );
}