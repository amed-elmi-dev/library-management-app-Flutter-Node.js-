const express = require("express");
const {
  createReservation,
  getMyReservations,
  getAllReservations,
  cancelReservation,
} = require("../controllers/reservationController");
const { protect } = require("../middleware/authMiddleware");
const adminOnly = require("../middleware/adminMiddleware");

const router = express.Router();

router.post("/", protect, createReservation);
router.get("/me", protect, getMyReservations);
router.get("/", protect, adminOnly, getAllReservations);
router.delete("/:id", protect, cancelReservation);

module.exports = router;
