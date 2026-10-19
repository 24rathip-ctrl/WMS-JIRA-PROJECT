/**
 * Inventory Management JavaScript (Vanilla JS - Zero external dependencies)
 * Handles SCRUM-10: Inward/Outward movements, validations, stock level badges.
 */

var inventoryItems = [];

document.addEventListener('DOMContentLoaded', function () {
    loadInventory();

    var stockForm = document.getElementById('stock-form');
    if (stockForm) {
        stockForm.addEventListener('submit', handleStockAdjustment);
    }

    var quickForm = document.getElementById('quick-adjust-form');
    if (quickForm) {
        quickForm.addEventListener('submit', handleQuickAdjustment);
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeQuickModal();
        }
    });
});

/**
 * Escapes unsafe characters for safe DOM insertion (XSS protection).
 */
function escapeHtml(str) {
    if (str === null || str === undefined) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

/**
 * Displays an accessible status message banner.
 */
function showBanner(message, type) {
    var banner = document.getElementById('status-banner');
    var textEl = document.getElementById('status-message');
    if (!banner || !textEl) return;

    banner.className = 'alert-banner alert-' + (type || 'info');
    textEl.textContent = message;
    banner.classList.remove('hidden');

    banner.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function dismissBanner() {
    var banner = document.getElementById('status-banner');
    if (banner) banner.classList.add('hidden');
}

/**
 * Loads inventory from GET /api/inventory.
 */
function loadInventory(selectProductIdAfter) {
    var tbody = document.getElementById('inventory-tbody');
    var emptyState = document.getElementById('empty-state');
    if (!tbody) return;

    fetch('api/inventory')
        .then(function (res) {
            if (!res.ok) throw new Error('Server returned status ' + res.status);
            return res.json();
        })
        .then(function (res) {
            if (res && res.success && Array.isArray(res.data)) {
                inventoryItems = res.data;
                renderInventoryTable(inventoryItems);
                populateProductDropdown(inventoryItems, selectProductIdAfter);
            } else {
                showBanner((res && res.message) || 'Failed to retrieve inventory.', 'error');
            }
        })
        .catch(function (err) {
            console.error('Error fetching inventory:', err);
            showBanner('Unable to connect to the backend server. Please verify Apache Tomcat is running.', 'error');
        });
}

/**
 * Populates the product select dropdown with existing products & current stock.
 */
function populateProductDropdown(items, selectedId) {
    var select = document.getElementById('productId');
    if (!select) return;

    var currentVal = selectedId || select.value;
    select.innerHTML = '<option value="">-- Choose Product --</option>';

    items.forEach(function (p) {
        var opt = document.createElement('option');
        opt.value = p.productId;
        opt.textContent = p.name + ' (' + p.productId + ') — Current Stock: ' + (p.quantity || 0);
        if (currentVal && p.productId === currentVal) {
            opt.selected = true;
        }
        select.appendChild(opt);
    });

    handleProductSelect();
}

/**
 * Updates the preview stock indicator when a user changes the product dropdown.
 */
function handleProductSelect() {
    var select = document.getElementById('productId');
    var preview = document.getElementById('preview-stock-value');
    if (!select || !preview) return;

    var val = select.value;
    if (!val) {
        preview.textContent = '—';
        return;
    }

    var item = inventoryItems.find(function (i) { return i.productId === val; });
    if (item) {
        preview.textContent = item.quantity + ' units (' + getStatusLabel(item.quantity) + ')';
    } else {
        preview.textContent = '—';
    }
}

function resetStockForm() {
    setTimeout(handleProductSelect, 50);
}

/**
 * Determines stock badge state.
 */
function getStatusLabel(qty) {
    if (qty <= 0) return 'Out of Stock';
    if (qty <= 10) return 'Low Stock';
    return 'In Stock';
}

function getStatusBadgeHtml(qty) {
    if (qty <= 0) {
        return '<span class="badge badge-out-of-stock">Out of Stock</span>';
    } else if (qty <= 10) {
        return '<span class="badge badge-low-stock">Low Stock (' + qty + ')</span>';
    } else {
        return '<span class="badge badge-in-stock">In Stock (' + qty + ')</span>';
    }
}

/**
 * Renders inventory table rows.
 */
function renderInventoryTable(items) {
    var tbody = document.getElementById('inventory-tbody');
    var emptyState = document.getElementById('empty-state');
    if (!tbody) return;

    tbody.innerHTML = '';

    if (!items || items.length === 0) {
        if (emptyState) emptyState.classList.remove('hidden');
        return;
    }

    if (emptyState) emptyState.classList.add('hidden');

    items.forEach(function (item) {
        var tr = document.createElement('tr');
        var priceFormatted = parseFloat(item.unitPrice).toFixed(2);
        var qty = parseInt(item.quantity, 10) || 0;

        tr.innerHTML =
            '<td class="mono"><strong>' + escapeHtml(item.productId) + '</strong></td>' +
            '<td>' + escapeHtml(item.name) + '</td>' +
            '<td>' + escapeHtml(item.category) + '</td>' +
            '<td class="numeric">$' + escapeHtml(priceFormatted) + '</td>' +
            '<td class="numeric"><strong>' + escapeHtml(qty) + '</strong></td>' +
            '<td>' + getStatusBadgeHtml(qty) + '</td>' +
            '<td style="text-align: center;">' +
                '<button type="button" class="btn btn-secondary btn-sm" onclick="openQuickModal(\'' + escapeHtml(item.productId) + '\')">Adjust Stock</button>' +
            '</td>';

        tbody.appendChild(tr);
    });
}

/**
 * Filters inventory by ID, name, or status.
 */
function filterInventory() {
    var searchInput = document.getElementById('inventory-search');
    if (!searchInput) return;

    var query = searchInput.value.trim().toLowerCase();
    if (!query) {
        renderInventoryTable(inventoryItems);
        return;
    }

    var filtered = inventoryItems.filter(function (item) {
        var id = (item.productId || '').toLowerCase();
        var name = (item.name || '').toLowerCase();
        var status = getStatusLabel(item.quantity).toLowerCase();
        return id.includes(query) || name.includes(query) || status.includes(query);
    });

    renderInventoryTable(filtered);
}

/**
 * Handles stock adjustment from the primary form.
 */
function handleStockAdjustment(e) {
    e.preventDefault();
    dismissBanner();

    var productId = (document.getElementById('productId').value || '').trim();
    var action = (document.getElementById('action').value || '').trim();
    var qtyStr = (document.getElementById('quantity').value || '').trim();

    // Client-side validations (SCRUM-10)
    if (!productId) {
        showBanner('Please select a product to adjust.', 'warning');
        document.getElementById('productId').focus();
        return;
    }
    if (!action || (action !== 'add' && action !== 'reduce')) {
        showBanner('Please select a valid movement type (Add or Reduce).', 'warning');
        return;
    }
    if (!qtyStr) {
        showBanner('Quantity is required.', 'warning');
        document.getElementById('quantity').focus();
        return;
    }

    // Validation: Non-numeric, zero, negative
    var quantity = Number(qtyStr);
    if (!Number.isInteger(quantity) || quantity <= 0) {
        showBanner('Quantity must be a positive whole integer greater than zero.', 'warning');
        document.getElementById('quantity').focus();
        return;
    }

    // Prevent client-side reductions greater than available stock
    var currentItem = inventoryItems.find(function (i) { return i.productId === productId; });
    if (action === 'reduce' && currentItem && quantity > currentItem.quantity) {
        showBanner('Cannot reduce by ' + quantity + ' units. Current stock is only ' + currentItem.quantity + '.', 'warning');
        document.getElementById('quantity').focus();
        return;
    }

    var submitBtn = document.getElementById('btn-submit-stock');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Processing...';

    executeStockApiCall(productId, action, quantity, function (success, message, updatedItem) {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Apply Stock Adjustment';

        if (success) {
            showBanner(message, 'success');
            document.getElementById('quantity').value = '';
            loadInventory(productId);
        } else {
            showBanner(message, 'error');
        }
    });
}

/**
 * Opens quick adjustment modal for a specific table row.
 */
function openQuickModal(productId) {
    var item = inventoryItems.find(function (i) { return i.productId === productId; });
    if (!item) return;

    document.getElementById('quick-productId').value = item.productId;
    document.getElementById('quick-product-name').textContent = item.name;
    document.getElementById('quick-product-id-label').textContent = item.productId;
    document.getElementById('quick-current-qty').textContent = item.quantity;
    document.getElementById('quick-quantity').value = '';

    var modal = document.getElementById('quick-adjust-modal');
    modal.classList.remove('hidden');
    document.getElementById('quick-quantity').focus();
}

function closeQuickModal() {
    var modal = document.getElementById('quick-adjust-modal');
    if (modal) modal.classList.add('hidden');
}

/**
 * Handles stock adjustment from quick modal.
 */
function handleQuickAdjustment(e) {
    e.preventDefault();
    dismissBanner();

    var productId = (document.getElementById('quick-productId').value || '').trim();
    var action = (document.getElementById('quick-action').value || '').trim();
    var qtyStr = (document.getElementById('quick-quantity').value || '').trim();

    var quantity = Number(qtyStr);
    if (!Number.isInteger(quantity) || quantity <= 0) {
        showBanner('Quantity must be a positive whole integer greater than zero.', 'warning');
        document.getElementById('quick-quantity').focus();
        return;
    }

    var currentItem = inventoryItems.find(function (i) { return i.productId === productId; });
    if (action === 'reduce' && currentItem && quantity > currentItem.quantity) {
        showBanner('Cannot reduce by ' + quantity + ' units. Current stock is only ' + currentItem.quantity + '.', 'warning');
        document.getElementById('quick-quantity').focus();
        return;
    }

    var saveBtn = document.getElementById('btn-quick-save');
    saveBtn.disabled = true;
    saveBtn.textContent = 'Executing...';

    executeStockApiCall(productId, action, quantity, function (success, message, updatedItem) {
        saveBtn.disabled = false;
        saveBtn.textContent = 'Execute Adjustment';

        if (success) {
            closeQuickModal();
            showBanner(message, 'success');
            loadInventory(productId);
        } else {
            showBanner(message, 'error');
        }
    });
}

/**
 * Common API invocation for stock adjustments.
 */
function executeStockApiCall(productId, action, quantity, callback) {
    var payload = {
        action: action,
        productId: productId,
        quantity: String(quantity)
    };

    fetch('api/inventory', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
    })
    .then(function (res) {
        return res.json().then(function (data) {
            return { status: res.status, ok: res.ok, data: data };
        });
    })
    .then(function (result) {
        if (result.ok && result.data.success) {
            callback(true, result.data.message, result.data.data);
        } else {
            callback(false, (result.data && result.data.message) || 'Operation failed.');
        }
    })
    .catch(function (err) {
        console.error('Stock adjustment error:', err);
        callback(false, 'Network or server communication failure.');
    });
}
