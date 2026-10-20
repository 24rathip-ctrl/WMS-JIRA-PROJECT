package com.wms.dao;

import com.wms.model.Product;
import com.wms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the products table.
 * All database queries use PreparedStatements to prevent SQL injection.
 */
public class ProductDAO {

    // ---------- Product Management (SCRUM-8, SCRUM-9) ----------

    /**
     * Checks whether a product with the given ID already exists.
     */
    public boolean productExists(String productId) throws SQLException {
        String sql = "SELECT 1 FROM products WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Inserts a new product. Returns true on success.
     * Caller should check productExists() first to give a clear duplicate error.
     */
    public boolean addProduct(Product product) throws SQLException {
        String sql = "INSERT INTO products (product_id, name, category, unit_price, quantity, description) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getProductId());
            ps.setString(2, product.getName());
            ps.setString(3, product.getCategory());
            ps.setBigDecimal(4, product.getUnitPrice());
            ps.setInt(5, product.getQuantity());
            ps.setString(6, product.getDescription());
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Returns all products ordered by creation date (newest first).
     */
    public List<Product> getAllProducts() throws SQLException {
        String sql = "SELECT * FROM products ORDER BY created_at DESC";
        List<Product> products = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                products.add(mapRow(rs));
            }
        }
        return products;
    }

    /**
     * Returns a single product by ID, or null if not found.
     */
    public Product getProductById(String productId) throws SQLException {
        String sql = "SELECT * FROM products WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Updates product details (name, category, price, description).
     * Does NOT update quantity — use updateStock() for inventory changes.
     */
    public boolean updateProduct(Product product) throws SQLException {
        String sql = "UPDATE products SET name = ?, category = ?, unit_price = ?, "
                   + "description = ? WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getCategory());
            ps.setBigDecimal(3, product.getUnitPrice());
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getProductId());
            return ps.executeUpdate() == 1;
        }
    }

    // ---------- Inventory Management (SCRUM-10) ----------

    /**
     * Returns all products with their current stock quantities.
     * Reuses getAllProducts() since quantity is stored in the products table.
     */
    public List<Product> getInventory() throws SQLException {
        return getAllProducts();
    }

    /**
     * Adds stock to a product. The amount must be a positive integer.
     * Returns the updated product, or null if the product was not found.
     */
    public Product addStock(String productId, int amount) throws SQLException {
        String sql = "UPDATE products SET quantity = quantity + ? WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, amount);
            ps.setString(2, productId);
            int rows = ps.executeUpdate();
            if (rows == 0) return null;
        }
        return getProductById(productId);
    }

    /**
     * Reduces stock from a product. The amount must be a positive integer.
     * Returns the updated product, or null if the product was not found.
     * Throws IllegalArgumentException if the reduction would make stock negative.
     */
    public Product reduceStock(String productId, int amount) throws SQLException {
        // Use a transaction to safely check-then-update
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Read current quantity with a row lock
            String selectSql = "SELECT quantity FROM products WHERE product_id = ? FOR UPDATE";
            int currentQty;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setString(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return null; // product not found
                    }
                    currentQty = rs.getInt("quantity");
                }
            }

            if (amount > currentQty) {
                conn.rollback();
                throw new IllegalArgumentException(
                    "Cannot reduce by " + amount + ". Current stock is only " + currentQty + ".");
            }

            // Perform the reduction
            String updateSql = "UPDATE products SET quantity = quantity - ? WHERE product_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, amount);
                ps.setString(2, productId);
                ps.executeUpdate();
            }

            conn.commit();
        } catch (SQLException | IllegalArgumentException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }

        return getProductById(productId);
    }

    /**
     * Maps a ResultSet row to a Product object.
     */
    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getString("product_id"));
        p.setName(rs.getString("name"));
        p.setCategory(rs.getString("category"));
        p.setUnitPrice(rs.getBigDecimal("unit_price"));
        p.setQuantity(rs.getInt("quantity"));
        p.setDescription(rs.getString("description"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        return p;
    }
}
