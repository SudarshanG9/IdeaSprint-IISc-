import os
import json
import google.generativeai as genai

# Use gemini-1.5-flash for fast, structured payload generation
genai.configure(api_key="AIzaSyD0BD8Pi88H0iRSBfEX0pEFPkeUrQL7NqQ")
model = genai.GenerativeModel("gemini-1.5-flash")

def generate_description(product):
    prompt = f"""
    You are an AI assistant for an Accessibility smartphone app designed for visually impaired and blind users.
    I have a product with the following details:
    Name: {product.name}
    Category: {product.category}
    Price: ₹{product.price}
    Expiry Date: {product.expiry_date}
    Raw Details: {product.description}
    
    Please provide TWO descriptive paragraphs tailored strictly for a blind person to listen to:
    1. 'primary_info': A highly accessible, jargon-free, friendly, and brief summary explaining what the product is, its price, and expiry date. Keep it extremely simple. Do not include deep ingredient details here.
    2. 'detailed_info': A deeper, descriptive paragraph explaining the ingredients, warnings, and what the product is made of, intended for users who request more information.

    Output ONLY valid JSON in the exact format, without markdown wrapping:
    {{
        "primary_info": "...",
        "detailed_info": "..."
    }}
    """
    try:
        response = model.generate_content(prompt)
        # Clean any accidental markdown codeblock formatting 
        clean_text = response.text.replace('```json', '').replace('```', '').strip()
        data = json.loads(clean_text)
        return data.get("primary_info"), data.get("detailed_info")
    except Exception as e:
        print(f"Gemini generation failed: {e}")
        # Secure Fallback to traditional static generation if LLM is down
        primary = f"This is a {product.category} called {product.name}. It costs {product.price} rupees and expires on {product.expiry_date}."
        detailed = f"Here are the explicit details retrieved for this item: {product.description}"
        return primary, detailed
