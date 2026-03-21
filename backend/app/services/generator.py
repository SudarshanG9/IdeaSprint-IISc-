def generate_description(product):
    """
    Statically formats the product data into dual descriptions without utilizing external Generative AI models.
    """
    print(f"[INFO] Generating static offline descriptions for {product.name}...")
    
    primary = f"This is a {product.category} called {product.name}. It costs {product.price} rupees and expires on {product.expiry_date.strftime('%B %d, %Y') if hasattr(product.expiry_date, 'strftime') else product.expiry_date}."
    
    detailed = f"Here are the explicit product details available on the label: {product.description}"
    
    return primary, detailed
