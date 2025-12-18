// API Configuration
const API_BASE_URL = 'http://localhost:5000';

// State
let currentTab = 'users';

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    initializeTabs();
    checkAPIStatus();
    loadAllData();

    // Refresh data every 30 seconds
    setInterval(loadAllData, 30000);
});

// Tab Management
function initializeTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const tabName = button.getAttribute('data-tab');
            switchTab(tabName);
        });
    });
}

function switchTab(tabName) {
    currentTab = tabName;

    // Update buttons
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

    // Update panels
    document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.classList.remove('active');
    });
    document.getElementById(tabName).classList.add('active');
}

// API Status Check
async function checkAPIStatus() {
    const statusIndicator = document.getElementById('apiStatus');
    const statusDot = statusIndicator.querySelector('.status-dot');
    const statusText = statusIndicator.querySelector('.status-text');

    try {
        const response = await fetch(`${API_BASE_URL}/health`);
        const data = await response.json();

        if (response.ok && data.status === 'healthy') {
            statusDot.classList.remove('error');
            statusText.textContent = 'API Connected';
        } else {
            throw new Error('API unhealthy');
        }
    } catch (error) {
        statusDot.classList.add('error');
        statusText.textContent = 'API Disconnected';
        console.error('API Status Check Failed:', error);
    }
}

// Load All Data
async function loadAllData() {
    await Promise.all([
        loadUsers(),
        loadProducts(),
        loadOrders()
    ]);
    updateStats();
}

// Users Management
async function loadUsers() {
    const tbody = document.getElementById('usersTableBody');

    try {
        const response = await fetch(`${API_BASE_URL}/api/users`);
        const data = await response.json();

        if (data.status === 'success' && data.data.length > 0) {
            tbody.innerHTML = data.data.map(user => `
                <tr>
                    <td>${user.id}</td>
                    <td><strong>${user.username}</strong></td>
                    <td>${user.email}</td>
                    <td>${formatDate(user.created_at)}</td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="4" class="loading">No users found</td></tr>';
        }
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="4" class="loading">Error loading users</td></tr>';
        console.error('Error loading users:', error);
    }
}

async function addUser(event) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);
    const userData = {
        username: formData.get('username'),
        email: formData.get('email')
    };

    try {
        const response = await fetch(`${API_BASE_URL}/api/users`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(userData)
        });

        const data = await response.json();

        if (response.ok && data.status === 'success') {
            showToast('User added successfully!', 'success');
            closeModal('addUserModal');
            form.reset();
            await loadUsers();
            updateStats();
        } else {
            showToast(data.message || 'Failed to add user', 'error');
        }
    } catch (error) {
        showToast('Error adding user', 'error');
        console.error('Error adding user:', error);
    }
}

// Products Management
async function loadProducts() {
    const tbody = document.getElementById('productsTableBody');

    try {
        const response = await fetch(`${API_BASE_URL}/api/products`);
        const data = await response.json();

        if (data.status === 'success' && data.data.length > 0) {
            tbody.innerHTML = data.data.map(product => `
                <tr>
                    <td>${product.id}</td>
                    <td><strong>${product.name}</strong></td>
                    <td>${product.description || 'N/A'}</td>
                    <td>$${parseFloat(product.price).toFixed(2)}</td>
                    <td>${product.stock_quantity}</td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="5" class="loading">No products found</td></tr>';
        }
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="5" class="loading">Error loading products</td></tr>';
        console.error('Error loading products:', error);
    }
}

async function addProduct(event) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);
    const productData = {
        name: formData.get('name'),
        description: formData.get('description'),
        price: parseFloat(formData.get('price')),
        stock_quantity: parseInt(formData.get('stock_quantity'))
    };

    try {
        const response = await fetch(`${API_BASE_URL}/api/products`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(productData)
        });

        const data = await response.json();

        if (response.ok && data.status === 'success') {
            showToast('Product added successfully!', 'success');
            closeModal('addProductModal');
            form.reset();
            await loadProducts();
            updateStats();
        } else {
            showToast(data.message || 'Failed to add product', 'error');
        }
    } catch (error) {
        showToast('Error adding product', 'error');
        console.error('Error adding product:', error);
    }
}

// Orders Management
async function loadOrders() {
    const tbody = document.getElementById('ordersTableBody');

    try {
        const response = await fetch(`${API_BASE_URL}/api/orders`);
        const data = await response.json();

        if (data.status === 'success' && data.data.length > 0) {
            tbody.innerHTML = data.data.map(order => `
                <tr>
                    <td>${order.id}</td>
                    <td>${order.user_id}</td>
                    <td>$${parseFloat(order.total_amount).toFixed(2)}</td>
                    <td><span class="status-badge status-${order.status}">${order.status}</span></td>
                    <td>${formatDate(order.created_at)}</td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="5" class="loading">No orders found</td></tr>';
        }
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="5" class="loading">Error loading orders</td></tr>';
        console.error('Error loading orders:', error);
    }
}

async function addOrder(event) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);
    const orderData = {
        user_id: parseInt(formData.get('user_id')),
        items: [
            {
                product_id: parseInt(formData.get('product_id')),
                quantity: parseInt(formData.get('quantity'))
            }
        ]
    };

    try {
        const response = await fetch(`${API_BASE_URL}/api/orders`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(orderData)
        });

        const data = await response.json();

        if (response.ok && data.status === 'success') {
            showToast('Order created successfully!', 'success');
            closeModal('addOrderModal');
            form.reset();
            await loadOrders();
            updateStats();
        } else {
            showToast(data.message || 'Failed to create order', 'error');
        }
    } catch (error) {
        showToast('Error creating order', 'error');
        console.error('Error creating order:', error);
    }
}

// Update Statistics
async function updateStats() {
    try {
        const [usersRes, productsRes, ordersRes] = await Promise.all([
            fetch(`${API_BASE_URL}/api/users`),
            fetch(`${API_BASE_URL}/api/products`),
            fetch(`${API_BASE_URL}/api/orders`)
        ]);

        const [usersData, productsData, ordersData] = await Promise.all([
            usersRes.json(),
            productsRes.json(),
            ordersRes.json()
        ]);

        document.getElementById('userCount').textContent = usersData.count || 0;
        document.getElementById('productCount').textContent = productsData.count || 0;
        document.getElementById('orderCount').textContent = ordersData.count || 0;
    } catch (error) {
        console.error('Error updating stats:', error);
    }
}

// Modal Management
function showAddUserModal() {
    showModal('addUserModal');
}

function showAddProductModal() {
    showModal('addProductModal');
}

function showAddOrderModal() {
    showModal('addOrderModal');
}

function showModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.classList.remove('active');
    document.body.style.overflow = 'auto';
}

// Close modal on outside click
document.addEventListener('click', (event) => {
    if (event.target.classList.contains('modal')) {
        event.target.classList.remove('active');
        document.body.style.overflow = 'auto';
    }
});

// Toast Notifications
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type} show`;

    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

// Utility Functions
function formatDate(dateString) {
    if (!dateString) return 'N/A';

    const date = new Date(dateString);
    const options = {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    };

    return date.toLocaleDateString('en-US', options);
}

// Error Handling
window.addEventListener('unhandledrejection', (event) => {
    console.error('Unhandled promise rejection:', event.reason);
    showToast('An unexpected error occurred', 'error');
});
