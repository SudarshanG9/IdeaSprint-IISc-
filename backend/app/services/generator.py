def generate_description(product):
    return (
        f"This is a {product.category} called {product.name}. "
        f"It costs {product.price} rupees and expires on {product.expiry}."
    )
