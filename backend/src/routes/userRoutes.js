const express = require("express");
const {
  getProfile,
  updateProfile,
  getUsers,
} = require("../controllers/userController");
const { protect } = require("../middleware/authMiddleware");
const adminOnly = require("../middleware/adminMiddleware");

const router = express.Router();

router.get("/me", protect, getProfile);
router.put("/me", protect, updateProfile);
router.get("/", protect, adminOnly, getUsers);

module.exports = router;
