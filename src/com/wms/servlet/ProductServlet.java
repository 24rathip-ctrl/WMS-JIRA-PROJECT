package com.wms.servlet;

import com.wms.dao.ProductDAO;
import com.wms.model.Product;
import com.wms.util.HttpUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Handles Product Management operations (SCRUM-8 and SCRUM-9).
 *
 * Endpoints:
 *   GET    /api/products               — list all products or get one with ?id=XYZ
 *   POST   /api/products               — create new product (or update if action=update)
 *   PUT    /api/products               — update existing product
 */
public class ProductServlet extends HttpServlet {

    private final ProductDAO dao = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String id = req.getParameter("id");
            if (id != null && !id.trim().isEmpty()) {
                Product p = dao.getProductById(id.trim());
                if (p == null) {
                    HttpUtil.sendError(resp, HttpServletResponse.SC_NOT_FOUND, "Product '" + id.trim() + "' not found.");
                } else {
                    HttpUtil.sendSuccess(resp, HttpServletResponse.SC_OK, "Product found.", p.toJson());
                }
            } else {
                List<Product> products = dao.getAllProducts();
                StringBuilder arr = new StringBuilder("[");
                for (int i = 0; i < products.size(); i++) {
                    if (i > 0) arr.append(",");
                    arr.append(products.get(i).toJson());
                }
                arr.append("]");
                HttpUtil.sendSuccess(resp, HttpServletResponse.SC_OK, "Found " + products.size() + " product(s).", arr.toString());
            }
        } catch (SQLException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while retrieving products.");
            log("ProductServlet GET error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Map<String, String> params = HttpUtil.parseParameters(req);
        String action = params.getOrDefault("action", "create");

        if ("update".equalsIgnoreCase(action)) {
            handleUpdate(params, resp);
            return;
        }

        String productId   = params.getOrDefault("productId", "");
        String name        = params.getOrDefault("name", "");
        String category    = params.getOrDefault("category", "");
        String priceStr    = params.getOrDefault("unitPrice", "");
        String description = params.getOrDefault("description", "");

        if (productId.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Product ID is required.");
            return;
        }
        if (name.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Product name is required.");
            return;
        }
        if (category.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Category is required.");
            return;
        }
        if (priceStr.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Unit price is required.");
            return;
        }

        BigDecimal unitPrice;
        try {
            unitPrice = new BigDecimal(priceStr);
            if (unitPrice.compareTo(BigDecimal.ZERO) <= 0) {
                HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Unit price must be greater than zero.");
                return;
            }
        } catch (NumberFormatException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Unit price must be a valid number.");
            return;
        }

        try {
            if (dao.productExists(productId)) {
                HttpUtil.sendError(resp, HttpServletResponse.SC_CONFLICT, "A product with ID '" + productId + "' already exists.");
                return;
            }

            Product product = new Product(productId, name, category, unitPrice, 0, description);
            dao.addProduct(product);

            Product created = dao.getProductById(productId);
            HttpUtil.sendSuccess(resp, HttpServletResponse.SC_CREATED, "Product '" + name + "' created successfully.", created.toJson());
        } catch (SQLException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while creating product.");
            log("ProductServlet POST error", e);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Map<String, String> params = HttpUtil.parseParameters(req);
        handleUpdate(params, resp);
    }

    private void handleUpdate(Map<String, String> params, HttpServletResponse resp) throws IOException {
        String productId   = params.getOrDefault("productId", "");
        String name        = params.getOrDefault("name", "");
        String category    = params.getOrDefault("category", "");
        String priceStr    = params.getOrDefault("unitPrice", "");
        String description = params.getOrDefault("description", "");

        if (productId.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Product ID is required for update.");
            return;
        }
        if (name.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Product name is required.");
            return;
        }
        if (category.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Category is required.");
            return;
        }
        if (priceStr.isEmpty()) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Unit price is required.");
            return;
        }

        BigDecimal unitPrice;
        try {
            unitPrice = new BigDecimal(priceStr);
            if (unitPrice.compareTo(BigDecimal.ZERO) <= 0) {
                HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Unit price must be greater than zero.");
                return;
            }
        } catch (NumberFormatException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_BAD_REQUEST, "Unit price must be a valid number.");
            return;
        }

        try {
            if (!dao.productExists(productId)) {
                HttpUtil.sendError(resp, HttpServletResponse.SC_NOT_FOUND, "Product '" + productId + "' not found.");
                return;
            }

            Product product = new Product();
            product.setProductId(productId);
            product.setName(name);
            product.setCategory(category);
            product.setUnitPrice(unitPrice);
            product.setDescription(description);

            dao.updateProduct(product);

            Product updated = dao.getProductById(productId);
            HttpUtil.sendSuccess(resp, HttpServletResponse.SC_OK, "Product '" + name + "' updated successfully.", updated.toJson());
        } catch (SQLException e) {
            HttpUtil.sendError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while updating product.");
            log("ProductServlet handleUpdate error", e);
        }
    }
}
