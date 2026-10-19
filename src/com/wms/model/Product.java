package com.wms.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Represents a product stored in the warehouse.
 * Maps directly to the 'products' table in the database.
 */
public class Product {

    private String productId;
    private String name;
    private String category;
    private BigDecimal unitPrice;
    private int quantity;
    private String description;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Default constructor
    public Product() {}

    // Constructor for creating a new product
    public Product(String productId, String name, String category,
                   BigDecimal unitPrice, int quantity, String description) {
        this.productId = productId;
        this.name = name;
        this.category = category;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.description = description;
    }

    // --- Getters and Setters ---

    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    /**
     * Returns this product as a JSON string.
     * Manually built to avoid external JSON library dependency.
     */
    public String toJson() {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"productId\":\"").append(escapeJson(productId)).append("\",");
        sb.append("\"name\":\"").append(escapeJson(name)).append("\",");
        sb.append("\"category\":\"").append(escapeJson(category)).append("\",");
        sb.append("\"unitPrice\":").append(unitPrice).append(",");
        sb.append("\"quantity\":").append(quantity).append(",");
        sb.append("\"description\":\"").append(escapeJson(description != null ? description : "")).append("\"");
        if (createdAt != null) {
            sb.append(",\"createdAt\":\"").append(createdAt.toString()).append("\"");
        }
        if (updatedAt != null) {
            sb.append(",\"updatedAt\":\"").append(updatedAt.toString()).append("\"");
        }
        sb.append("}");
        return sb.toString();
    }

    /**
     * Escapes special characters for safe JSON embedding.
     */
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                     .replace("\"", "\\\"")
                     .replace("\n", "\\n")
                     .replace("\r", "\\r")
                     .replace("\t", "\\t");
    }
}
