export const CATEGORIES = ["Groceries","Instant Food","Medicine","Personal Care","Household","Dairy","Beverages"];
export const CAT_BADGE = { "Groceries":"blue","Instant Food":"green","Medicine":"amber","Personal Care":"neutral","Household":"neutral","Dairy":"blue","Beverages":"green" };

export function formatPrice(val) {
  const n = parseFloat(val);
  return isNaN(n) ? "--" : "\u20B9" + n.toFixed(2);
}

export function formatDate(dateStr) {
  if (!dateStr) return "--";
  try { return new Date(dateStr).toLocaleDateString("en-IN", { day: "numeric", month: "long", year: "numeric" }); }
  catch { return dateStr; }
}

export function generateDescription(p) {
  let d = p.name + ". Category: " + p.cat + ".";
  if (p.price) d += " Price: " + formatPrice(p.price) + ".";
  if (p.expiry) d += " Best before: " + formatDate(p.expiry) + ".";
  if (p.ingredients) d += " Ingredients: " + p.ingredients + ".";
  if (p.warnings) d += " Warning: " + p.warnings;
  return d;
}
export const API_BASE = process.env.REACT_APP_API_URL || "http://localhost:5000";