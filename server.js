const express = require("express");
const cors = require("cors");
const app = express();
const productRoutes = require("./routes/products-route");
const registerRoutes = require("./routes/register-route");
const loginRoutes = require("./routes/login-route");
const profileRoutes = require("./routes/profile-route");
const orderRoutes = require("./routes/orders-route");
const cartRoutes = require("./routes/cart-route");
const wishlistRoutes = require("./routes/wishlist-route");

// Enable CORS for development hosts. In production, set a specific origin.
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin like mobile apps or curl
      if (!origin) return callback(null, true);
      // Allow local dev origin; adjust as needed for your environment
      const allowed = [
        "http://localhost:49754",
        "http://localhost:8080",
        "http://localhost:4200",
      ];
      if (allowed.indexOf(origin) !== -1) return callback(null, true);
      // You can whitelist other origins or return an error
      return callback(null, false);
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: [
      "Content-Type",
      "Authorization",
      "X-Requested-With",
      "Accept",
    ],
  })
);
app.use(express.json());

// Explicitly respond to preflight OPTIONS requests
app.options("/*", (req, res) => {
  res.sendStatus(200);
});
require("dotenv").config();
const { connectDB, getConnectionState } = require("./config/db");

app.use("/api/products", productRoutes);
app.use("/api/register", registerRoutes);
app.use("/api/login", loginRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/wishlist", wishlistRoutes);

const PORT = process.env.PORT || 5000;

(async () => {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`Server listening on port ${PORT}`);
    });
  } catch (err) {
    console.error("Failed to start server due to DB connection error:", err);
    process.exit(1);
  }
})();

// Simple health endpoint to check server and DB state
app.get("/health", (req, res) => {
  const state = getConnectionState();
  const states = {
    0: "disconnected",
    1: "connected",
    2: "connecting",
    3: "disconnecting",
  };
  res.json({ ok: state === 1, mongoState: states[state] || state });
});
