"""
API routes for the Flask application
"""
from flask import Blueprint, jsonify, request
from app import db
from app.models import User, Product, Order, OrderItem
from sqlalchemy import text

# Create blueprint
main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    """Root endpoint"""
    return jsonify({
        'message': 'Flask API is running',
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'db_check': '/db-check',
            'users': '/api/users',
            'products': '/api/products',
            'orders': '/api/orders'
        }
    })

@main_bp.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'flask-app',
        'database': 'connected'
    }), 200

@main_bp.route('/db-check')
def db_check():
    """Database connectivity check"""
    try:
        # Execute a simple query to check database connection
        result = db.session.execute(text('SELECT 1'))
        db.session.commit()
        
        # Get table counts
        user_count = User.query.count()
        product_count = Product.query.count()
        order_count = Order.query.count()
        
        return jsonify({
            'status': 'success',
            'message': 'Database connection successful',
            'statistics': {
                'users': user_count,
                'products': product_count,
                'orders': order_count
            }
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Database connection failed: {str(e)}'
        }), 500

# User endpoints
@main_bp.route('/api/users', methods=['GET'])
def get_users():
    """Get all users"""
    try:
        users = User.query.all()
        return jsonify({
            'status': 'success',
            'count': len(users),
            'data': [user.to_dict() for user in users]
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@main_bp.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Get a specific user"""
    try:
        user = User.query.get_or_404(user_id)
        return jsonify({
            'status': 'success',
            'data': user.to_dict()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 404

@main_bp.route('/api/users', methods=['POST'])
def create_user():
    """Create a new user"""
    try:
        data = request.get_json()
        
        if not data or 'username' not in data or 'email' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Username and email are required'
            }), 400
        
        user = User(
            username=data['username'],
            email=data['email']
        )
        
        db.session.add(user)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'User created successfully',
            'data': user.to_dict()
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# Product endpoints
@main_bp.route('/api/products', methods=['GET'])
def get_products():
    """Get all products"""
    try:
        products = Product.query.all()
        return jsonify({
            'status': 'success',
            'count': len(products),
            'data': [product.to_dict() for product in products]
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@main_bp.route('/api/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get a specific product"""
    try:
        product = Product.query.get_or_404(product_id)
        return jsonify({
            'status': 'success',
            'data': product.to_dict()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 404

@main_bp.route('/api/products', methods=['POST'])
def create_product():
    """Create a new product"""
    try:
        data = request.get_json()
        
        if not data or 'name' not in data or 'price' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Name and price are required'
            }), 400
        
        product = Product(
            name=data['name'],
            description=data.get('description', ''),
            price=data['price'],
            stock_quantity=data.get('stock_quantity', 0)
        )
        
        db.session.add(product)
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Product created successfully',
            'data': product.to_dict()
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# Order endpoints
@main_bp.route('/api/orders', methods=['GET'])
def get_orders():
    """Get all orders"""
    try:
        orders = Order.query.all()
        return jsonify({
            'status': 'success',
            'count': len(orders),
            'data': [order.to_dict() for order in orders]
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@main_bp.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    """Get a specific order"""
    try:
        order = Order.query.get_or_404(order_id)
        return jsonify({
            'status': 'success',
            'data': order.to_dict()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 404

@main_bp.route('/api/orders', methods=['POST'])
def create_order():
    """Create a new order"""
    try:
        data = request.get_json()
        
        if not data or 'user_id' not in data or 'items' not in data:
            return jsonify({
                'status': 'error',
                'message': 'User ID and items are required'
            }), 400
        
        # Calculate total amount
        total_amount = 0
        for item in data['items']:
            product = Product.query.get(item['product_id'])
            if product:
                total_amount += float(product.price) * item['quantity']
        
        # Create order
        order = Order(
            user_id=data['user_id'],
            total_amount=total_amount,
            status=data.get('status', 'pending')
        )
        
        db.session.add(order)
        db.session.flush()  # Get order ID
        
        # Create order items
        for item in data['items']:
            product = Product.query.get(item['product_id'])
            if product:
                order_item = OrderItem(
                    order_id=order.id,
                    product_id=item['product_id'],
                    quantity=item['quantity'],
                    price=product.price
                )
                db.session.add(order_item)
        
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Order created successfully',
            'data': order.to_dict()
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

# Error handlers
@main_bp.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({
        'status': 'error',
        'message': 'Resource not found'
    }), 404

@main_bp.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    db.session.rollback()
    return jsonify({
        'status': 'error',
        'message': 'Internal server error'
    }), 500
