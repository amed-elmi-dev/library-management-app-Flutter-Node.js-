const express = require("express");
const authRoutes = require("./routes/authRoutes");
const protect = require("./middleware/authMiddleware");

const app = express();

app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);

// Test route
app.get("/", (req, res) => {
  res.send("Online Library API is running...");
});

// Protected route example
app.get("/api/test/protected", protect, (req, res) => {
  res.json({
    message: "You accessed a protected route!",
    user: req.user,
  });
});

module.exports = app;
