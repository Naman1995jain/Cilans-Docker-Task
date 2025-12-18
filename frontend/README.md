# Frontend Documentation

## Overview

Modern, responsive web dashboard for managing the Flask API. Built with vanilla HTML, CSS, and JavaScript, containerized with Nginx.

## Features

### ✨ User Interface
- **Dark Theme**: Modern dark mode with gradient accents
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Real-time Updates**: Auto-refresh every 30 seconds
- **Smooth Animations**: Micro-interactions and transitions
- **Toast Notifications**: User feedback for all actions

### 📊 Dashboard Components
1. **Statistics Cards**: Real-time counts for users, products, and orders
2. **Tabbed Interface**: Switch between Users, Products, and Orders
3. **Data Tables**: Display all data with proper formatting
4. **Modal Forms**: Add new users, products, and orders
5. **API Status Indicator**: Shows connection status

### 🎨 Design Features
- **Gradient Accents**: Purple-blue gradient theme
- **Glassmorphism**: Modern glass-effect cards
- **Hover Effects**: Interactive elements with smooth transitions
- **Custom Scrollbar**: Styled scrollbar matching theme
- **Google Fonts**: Inter font family for clean typography

## Technology Stack

- **HTML5**: Semantic markup
- **CSS3**: Custom properties, Grid, Flexbox
- **JavaScript (ES6+)**: Fetch API, async/await
- **Nginx**: Static file server
- **Docker**: Containerization

## File Structure

```
frontend/
├── index.html          # Main HTML file
├── css/
│   └── styles.css      # All styles
├── js/
│   └── app.js          # Application logic
├── Dockerfile          # Container definition
└── nginx.conf          # Nginx configuration
```

## API Integration

### Base URL
```javascript
const API_BASE_URL = 'http://localhost:5000';
```

### Endpoints Used
- `GET /health` - API status check
- `GET /api/users` - Fetch all users
- `POST /api/users` - Create new user
- `GET /api/products` - Fetch all products
- `POST /api/products` - Create new product
- `GET /api/orders` - Fetch all orders
- `POST /api/orders` - Create new order

## Features in Detail

### 1. Statistics Dashboard
- Real-time count of users, products, and orders
- Animated cards with hover effects
- Color-coded icons for each category

### 2. Users Management
- View all users in a table
- Add new users via modal form
- Fields: Username, Email
- Real-time validation

### 3. Products Management
- View all products with pricing
- Add new products via modal form
- Fields: Name, Description, Price, Stock Quantity
- Currency formatting

### 4. Orders Management
- View all orders with status
- Create new orders via modal form
- Fields: User ID, Product ID, Quantity
- Automatic total calculation

### 5. Real-time Updates
- Auto-refresh every 30 seconds
- Manual refresh on data changes
- Optimistic UI updates

## Usage

### Accessing the Dashboard
```
http://localhost
```

### Adding a User
1. Click "Add User" button
2. Fill in username and email
3. Click "Add User" in modal
4. See toast notification
5. Table updates automatically

### Adding a Product
1. Click "Add Product" button
2. Fill in product details
3. Enter price and stock quantity
4. Click "Add Product"
5. Table updates automatically

### Creating an Order
1. Click "Create Order" button
2. Enter User ID (from Users tab)
3. Enter Product ID (from Products tab)
4. Enter quantity
5. Click "Create Order"
6. Order appears in Orders tab

## Customization

### Changing Colors
Edit CSS variables in `styles.css`:
```css
:root {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    /* ... more colors */
}
```

### Changing API URL
Edit `app.js`:
```javascript
const API_BASE_URL = 'http://your-api-url:5000';
```

### Changing Auto-refresh Interval
Edit `app.js`:
```javascript
// Change 30000 (30 seconds) to desired milliseconds
setInterval(loadAllData, 30000);
```

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Performance

- **Gzip Compression**: Enabled via Nginx
- **Asset Caching**: 1 year cache for static files
- **Minimal Dependencies**: No external libraries
- **Optimized Images**: SVG icons for scalability

## Security

- **CORS**: Configured in Flask backend
- **Security Headers**: X-Frame-Options, X-Content-Type-Options
- **Input Validation**: Client-side form validation
- **XSS Protection**: Enabled via headers

## Development

### Local Development (without Docker)
1. Use any HTTP server:
   ```bash
   # Python
   python -m http.server 8000
   
   # Node.js
   npx http-server
   ```

2. Access at `http://localhost:8000`

### Building Docker Image
```bash
cd frontend
docker build -t flask-frontend .
```

### Running Container
```bash
docker run -p 80:80 flask-frontend
```

## Troubleshooting

### API Connection Issues
- Check if Flask backend is running
- Verify API_BASE_URL in `app.js`
- Check browser console for CORS errors
- Ensure Flask-CORS is installed

### Styling Issues
- Clear browser cache
- Check browser console for CSS errors
- Verify all CSS files are loaded

### Data Not Loading
- Check API status indicator in header
- Open browser DevTools Network tab
- Verify API endpoints are responding
- Check for JavaScript errors in console

## Future Enhancements

- [ ] User authentication
- [ ] Edit/Delete functionality
- [ ] Advanced filtering and search
- [ ] Data export (CSV, PDF)
- [ ] Charts and graphs
- [ ] Pagination for large datasets
- [ ] Dark/Light theme toggle
- [ ] Keyboard shortcuts
- [ ] Offline support (PWA)

## License

MIT License

---

**Built with modern web technologies for a premium user experience**
