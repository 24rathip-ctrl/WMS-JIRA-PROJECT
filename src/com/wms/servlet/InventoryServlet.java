package com.wms.servlet;

import com.wms.dao.ProductDAO;
import com.wms.model.Product;
import com.wms.util.HttpUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Handles Inventory Management operations (SCRUM-10).
 *
 * Endpoints:
 *   GET  /api/inventory                    — view current stock for all products
 *   POST /api/inventory                    — add or reduce stock (action=add or action=reduce)
 */
public class InventoryServlet extends HttpServlet {

    private final ProductDAO dao = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Product> inventory = dao.getInventory();
            StringBuilder arr = new StringBuilder("[");
            for (int i = 0; i < inventory.size(); i++) {
                if (i > 0) arr.append(",");
                arr.append(inventory.get(i).toJson());
            }
            arr.append("]");
            HttpUtil.sendSuccess(resp, HttpServletResponse.SC_OK, "Found " + inventory.size() + " product(s) in inventory.", arr.toString());
        } catch (SQLException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while retrieving inventory.");
            log("InventoryServlet GET error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Map<String, String> params = HttpUtil.parseParameters(req);
        String action    = params.getOrDefault("action", "");
        String productId = params.getOrDefault("productId", "");
        String qtyStr    = params.getOrDefault("quantity", "");

        if (action.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Action is required. Use 'add' or 'reduce'.");
            return;
        }
        if (!"add".equalsIgnoreCase(action) && !"reduce".equalsIgnoreCase(action)) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Invalid action '" + action + "'. Valid actions are 'add' and 'reduce'.");
            return;
        }
        if (productId.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Product ID is required.");
            return;
        }
        if (qtyStr.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Quantity is required.");
            return;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(qtyStr);
        } catch (NumberFormatException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Quantity must be a valid whole number.");
            return;
        }

        if (quantity <= 0) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Quantity must be greater than zero.");
            return;
        }

        try {
            Product updated;
            if ("add".equalsIgnoreCase(action)) {
                updated = dao.addStock(productId, quantity);
                if (updated == null) {
                    HttpUtil.sendError(resp, HttpServletResponse.SC_NOT_FOUND, "Product '" + productId + "' not found.");
                    return;
                }
                HttpUtil.sendSuccess(resp, HttpServletResponse.SC_OK,
                        "Successfully added " + quantity + " unit(s) to '" + updated.getName() + "'. New stock: " + updated.getQuantity() + ".",
                        updated.toJson());
            } else {
                updated = dao.reduceStock(productId, quantity);
                if (updated == null) {
                    HttpUtil.sendError(resp, HttpServletResponse.SC_NOT_FOUND, "Product '" + productId + "' not found.");
                    return;
                }
                HttpUtil.sendSuccess(resp, HttpServletResponse.SC_OK,
                        "Successfully reduced " + quantity + " unit(s) from '" + updated.getName() + "'. New stock: " + updated.getQuantity() + ".",
                        updated.toJson());
            }
        } catch (IllegalArgumentException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (SQLException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while updating stock.");
            log("InventoryServlet POST error", e);
        }
    }
}
