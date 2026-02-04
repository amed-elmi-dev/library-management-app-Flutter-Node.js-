const express = require("express");
const {
  borrowBook,
  returnBorrow,
  getMyBorrows,
  getAllBorrows,
  getOverdueBorrows,
} = require("../controllers/borrowController");
const { protect } = require("../middleware/authMiddleware");
const adminOnly = require("../middleware/adminMiddleware");

const router = express.Router();

router.post("/borrow", protect, borrowBook);
router.post("/:id/return", protect, returnBorrow);
router.get("/me", protect, getMyBorrows);

router.get("/", protect, adminOnly, getAllBorrows);
router.get("/overdue", protect, adminOnly, getOverdueBorrows);

module.exports = router;
