package com.wms.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * Utility helper for Servlets to handle JSON responses, security headers,
 * and request parameter parsing (supporting query string, form data, and JSON body).
 */
public class HttpUtil {

    /**
     * Sets standard JSON content type and security headers.
     */
    public static void setJsonHeaders(HttpServletResponse resp) {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("X-Content-Type-Options", "nosniff");
        resp.setHeader("X-Frame-Options", "DENY");
        resp.setHeader("X-XSS-Protection", "1; mode=block");
    }

    /**
     * Sends a complete JSON response with status code and immediate flush.
     */
    public static void sendJson(HttpServletResponse resp, int statusCode, String json) throws IOException {
        setJsonHeaders(resp);
        resp.setStatus(statusCode);
        PrintWriter out = resp.getWriter();
        out.print(json);
        out.flush();
    }

    public static void sendSuccess(HttpServletResponse resp, int statusCode, String message, String dataJson) throws IOException {
        sendJson(resp, statusCode, jsonSuccess(message, dataJson));
    }

    public static void sendError(HttpServletResponse resp, int statusCode, String message) throws IOException {
        sendJson(resp, statusCode, jsonError(message));
    }

    /**
     * Extracts parameters from standard request params, URL-encoded body, or JSON body.
     */
    public static Map<String, String> parseParameters(HttpServletRequest req) throws IOException {
        Map<String, String> params = new HashMap<>();

        // 1. Standard request parameters (query string and standard form POST)
        for (Map.Entry<String, String[]> entry : req.getParameterMap().entrySet()) {
            if (entry.getValue() != null && entry.getValue().length > 0) {
                params.put(entry.getKey(), entry.getValue()[0].trim());
            }
        }

        // 2. If body parameters were not parsed (e.g. PUT request or application/json body)
        String contentType = req.getContentType();
        StringBuilder bodyBuilder = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                bodyBuilder.append(line);
            }
        }
        String body = bodyBuilder.toString().trim();

        if (!body.isEmpty()) {
            if ((contentType != null && contentType.contains("application/json")) || (body.startsWith("{") && body.endsWith("}"))) {
                parseSimpleJson(body, params);
            } else if (body.contains("=")) {
                String[] pairs = body.split("&");
                for (String pair : pairs) {
                    int eq = pair.indexOf('=');
                    if (eq > 0) {
                        String key = URLDecoder.decode(pair.substring(0, eq), StandardCharsets.UTF_8).trim();
                        String val = (eq < pair.length() - 1)
                                ? URLDecoder.decode(pair.substring(eq + 1), StandardCharsets.UTF_8).trim()
                                : "";
                        params.put(key, val);
                    }
                }
            }
        }

        return params;
    }

    private static void parseSimpleJson(String json, Map<String, String> target) {
        String trimmed = json.trim();
        if (trimmed.startsWith("{")) trimmed = trimmed.substring(1);
        if (trimmed.endsWith("}")) trimmed = trimmed.substring(0, trimmed.length() - 1);

        String[] tokens = trimmed.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
        for (String token : tokens) {
            int colon = token.indexOf(':');
            if (colon > 0) {
                String key = cleanQuotes(token.substring(0, colon).trim());
                String val = cleanQuotes(token.substring(colon + 1).trim());
                if (!key.isEmpty()) {
                    target.put(key, val);
                }
            }
        }
    }

    private static String cleanQuotes(String s) {
        if (s == null) return "";
        String res = s.trim();
        if (res.startsWith("\"") && res.endsWith("\"") && res.length() >= 2) {
            res = res.substring(1, res.length() - 1);
        }
        return res;
    }

    public static String jsonError(String message) {
        return "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}";
    }

    public static String jsonSuccess(String message, String dataJson) {
        return "{\"success\":true,\"message\":\"" + escapeJson(message)
                + "\",\"data\":" + (dataJson == null || dataJson.isEmpty() ? "null" : dataJson) + "}";
    }

    public static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    public static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}
