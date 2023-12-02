import json

component_template = {
    "product_name": "",
    "product_type": "Electronics",
    "brand": "TechBrand",
    "model_number": "",
    "image": "",
    "description": "",
    "digital_passport": {
        "data_categories": [],
        "data_carrier": "NFC",
        "benefits": []
    },
    "use_cases": [],
    "manufacturer": {
        "name": "Tech Manufacturer Co.",
        "location": "Country/Region",
        "contact": {
            "email": "info@techbrand.com",
            "phone": "+987654321"
        }
    },
    "sustainability_features": {},
    "additional_info": {
        "specs": {},
        "price": "$XXX.XX",
        "availability": "Pre-order"
    }
}

graphic_card = {
    "product_name": "Graphics Card XYZ",
    "model_number": "GCXYZ123",
    "image": "graphic_card_image_url",
    "description": "Description of the graphics card.",
    "digital_passport": {
        "data_categories": ["General", "Source"],
        "benefits": ["New Business Models"]
    },
    "use_cases": ["Enhanced Graphics Performance"],
    "sustainability_features": {
        "energy_efficiency": "Optimized power usage",
        "recyclability": "Easily recyclable"
    },
    "additional_info": {
        "specs": {
            "Memory": "8GB GDDR6",
            "Interface": "PCIe 4.0"
        }
    }
}

screen = {
    "product_name": "UltraWide Screen",
    "model_number": "UWS456",
    "image": "screen_image_url",
    "description": "Description of the ultrawide screen.",
    "digital_passport": {
        "data_categories": ["General", "Source"],
        "benefits": ["Enhanced Productivity"]
    },
    "use_cases": ["Immersive Viewing Experience"],
    "sustainability_features": {
        "energy_efficiency": "Energy-saving technology",
        "recyclability": "Recyclable materials"
    },
    "additional_info": {
        "specs": {
            "Size": "34 inches",
            "Resolution": "3440x1440"
        }
    }
}

# Generate JSON files for each component
with open("graphic_card.json", "w") as file:
    json.dump(graphic_card, file, indent=4)

with open("screen.json", "w") as file:
    json.dump(screen, file, indent=4)
