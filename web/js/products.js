/**
 * Product Management JavaScript (Vanilla JS - Zero external dependencies)
 * Handles SCRUM-8 (Create & List) and SCRUM-9 (Update)
 */

var allProducts = [];

document.addEventListener('DOMContentLoaded', function () {
    loadProducts();

    var addForm = document.getElementById('add-product-form');
    if (addForm) {
        addForm.addEventListener('submit', handleAddProduct);
    }

    var editForm = document.getElementById('edit-product-form');
    if (editForm) {
        editForm.addEventListener('submit', handleUpdateProduct);
    }

    // Close modal on escape key
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeEditModal();
        }
    });
});

/**
 * Escapes unsafe characters for safe innerHTML insertion (XSS protection).
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

    // Scroll banner into view smoothly
    banner.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function dismissBanner() {
    var banner = document.getElementById('status-banner');
    if (banner) banner.classList.add('hidden');
}

/**
 * Fetches all products from the backend servlet (SCRUM-8).
 */
function loadProducts() {
    var tbody = document.getElementById('products-tbody');
    var emptyState = document.getElementById('empty-state');
    if (!tbody) return;

    fetch('api/products')
        .then(function (res) {
            if (!res.ok) throw new Error('Server returned status ' + res.status);
            return res.json();
        })
        .then(function (res) {
            if (res && res.success && Array.isArray(res.data)) {
                allProducts = res.data;
                renderProductTable(allProducts);
            } else {
                showBanner((res && res.message) || 'Failed to retrieve products.', 'error');
            }
        })
        .catch(function (err) {
            console.error('Error fetching products:', err);
            showBanner('Unable to connect to the backend server. Please verify Apache Tomcat is running.', 'error');
        });
}

/**
 * Renders products into the HTML table with XSS protection.
 */
function renderProductTable(products) {
    var tbody = document.getElementById('products-tbody');
    var emptyState = document.getElementById('empty-state');
    if (!tbody) return;

    tbody.innerHTML = '';

    if (!products || products.length === 0) {
        if (emptyState) emptyState.classList.remove('hidden');
        return;
    }

    if (emptyState) emptyState.classList.add('hidden');

    products.forEach(function (p) {
        var tr = document.createElement('tr');
        var priceFormatted = parseFloat(p.unitPrice).toFixed(2);
        var qty = parseInt(p.quantity, 10) || 0;

        tr.innerHTML =
            '<td class="mono"><strong>' + escapeHtml(p.productId) + '</strong></td>' +
            '<td>' + escapeHtml(p.name) + '</td>' +
            '<td>' + escapeHtml(p.category) + '</td>' +
            '<td class="numeric">₹' + escapeHtml(priceFormatted) + '</td>' +
            '<td class="numeric">' + escapeHtml(qty) + '</td>' +
            '<td>' + escapeHtml(p.description || '—') + '</td>' +
            '<td style="text-align: center;">' +
                '<button type="button" class="btn btn-secondary btn-sm" onclick="openEditModal(\'' + escapeHtml(p.productId) + '\')">Edit</button>' +
            '</td>';

        tbody.appendChild(tr);
    });
}

/**
 * Filters the product table based on live user input.
 */
function filterProducts() {
    var searchInput = document.getElementById('search-input');
    if (!searchInput) return;

    var query = searchInput.value.trim().toLowerCase();
    if (!query) {
        renderProductTable(allProducts);
        return;
    }

    var filtered = allProducts.filter(function (p) {
        var id = (p.productId || '').toLowerCase();
        var name = (p.name || '').toLowerCase();
        var cat = (p.category || '').toLowerCase();
        return id.includes(query) || name.includes(query) || cat.includes(query);
    });

    renderProductTable(filtered);
}

/**
 * Handles adding a new product (SCRUM-8).
 */
function handleAddProduct(e) {
    e.preventDefault();
    dismissBanner();

    var form = document.getElementById('add-product-form');
    var productId = (document.getElementById('productId').value || '').trim();
    var name = (document.getElementById('name').value || '').trim();
    var category = (document.getElementById('category').value || '').trim();
    var unitPrice = (document.getElementById('unitPrice').value || '').trim();
    var description = (document.getElementById('description').value || '').trim();

    // Client-side validation (supplementary to server-side)
    if (!productId) {
        showBanner('Product ID is required.', 'warning');
        document.getElementById('productId').focus();
        return;
    }
    if (!name) {
        showBanner('Product name is required.', 'warning');
        document.getElementById('name').focus();
        return;
    }
    if (!category) {
        showBanner('Please select a category.', 'warning');
        document.getElementById('category').focus();
        return;
    }
    if (!unitPrice) {
        showBanner('Unit price is required.', 'warning');
        document.getElementById('unitPrice').focus();
        return;
    }

    var priceNum = parseFloat(unitPrice);
    if (isNaN(priceNum) || priceNum <= 0) {
        showBanner('Unit price must be a valid number greater than zero.', 'warning');
        document.getElementById('unitPrice').focus();
        return;
    }

    var submitBtn = document.getElementById('btn-submit-product');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Adding...';

    var payload = {
        productId: productId,
        name: name,
        category: category,
        unitPrice: unitPrice,
        description: description
    };

    fetch('api/products', {
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
        submitBtn.disabled = false;
        submitBtn.textContent = 'Add Product';

        if (result.ok && result.data.success) {
            showBanner(result.data.message || 'Product created successfully.', 'success');
            form.reset();
            loadProducts();
        } else {
            showBanner(result.data.message || 'Failed to add product.', 'error');
        }
    })
    .catch(function (err) {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Add Product';
        console.error('Add product error:', err);
        showBanner('Network or server error while adding product.', 'error');
    });
}

/**
 * Opens the Edit Modal and prefills current product details (SCRUM-9).
 */
function openEditModal(productId) {
    var product = allProducts.find(function (p) {
        return p.productId === productId;
    });

    if (!product) {
        showBanner('Product details not found in cache. Refreshing...', 'warning');
        loadProducts();
        return;
    }

    document.getElementById('edit-productId').value = product.productId;
    document.getElementById('edit-name').value = product.name;
    document.getElementById('edit-category').value = product.category;
    document.getElementById('edit-unitPrice').value = product.unitPrice;
    document.getElementById('edit-description').value = product.description || '';

    var modal = document.getElementById('edit-modal');
    modal.classList.remove('hidden');
    document.getElementById('edit-name').focus();
}

function closeEditModal() {
    var modal = document.getElementById('edit-modal');
    if (modal) modal.classList.add('hidden');
}

/**
 * Handles updating an existing product (SCRUM-9).
 */
function handleUpdateProduct(e) {
    e.preventDefault();
    dismissBanner();

    var productId = (document.getElementById('edit-productId').value || '').trim();
    var name = (document.getElementById('edit-name').value || '').trim();
    var category = (document.getElementById('edit-category').value || '').trim();
    var unitPrice = (document.getElementById('edit-unitPrice').value || '').trim();
    var description = (document.getElementById('edit-description').value || '').trim();

    // Client-side validation
    if (!productId) {
        showBanner('Product ID is missing.', 'error');
        return;
    }
    if (!name) {
        showBanner('Product name is required.', 'warning');
        document.getElementById('edit-name').focus();
        return;
    }
    if (!category) {
        showBanner('Please select a category.', 'warning');
        document.getElementById('edit-category').focus();
        return;
    }
    if (!unitPrice) {
        showBanner('Unit price is required.', 'warning');
        document.getElementById('edit-unitPrice').focus();
        return;
    }

    var priceNum = parseFloat(unitPrice);
    if (isNaN(priceNum) || priceNum <= 0) {
        showBanner('Unit price must be a valid number greater than zero.', 'warning');
        document.getElementById('edit-unitPrice').focus();
        return;
    }

    var saveBtn = document.getElementById('btn-save-edit');
    saveBtn.disabled = true;
    saveBtn.textContent = 'Saving...';

    var payload = {
        action: 'update',
        productId: productId,
        name: name,
        category: category,
        unitPrice: unitPrice,
        description: description
    };

    fetch('api/products', {
        method: 'PUT',
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
        saveBtn.disabled = false;
        saveBtn.textContent = 'Save Changes';

        if (result.ok && result.data.success) {
            closeEditModal();
            showBanner(result.data.message || 'Product updated successfully.', 'success');
            loadProducts();
        } else {
            showBanner(result.data.message || 'Failed to update product.', 'error');
        }
    })
    .catch(function (err) {
        saveBtn.disabled = false;
        saveBtn.textContent = 'Save Changes';
        console.error('Update product error:', err);
        showBanner('Network or server error while updating product.', 'error');
    });
}
