const mongoose = require("mongoose");

const reservationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    book: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Book",
      required: true,
      index: true,
    },
    status: {
      type: String,
      enum: ["active", "fulfilled", "canceled", "expired"],
      default: "active",
      index: true,
    },
  },
  { timestamps: true },
);

reservationSchema.index({ book: 1, status: 1, createdAt: 1 });
reservationSchema.index({ user: 1, status: 1 });

module.exports = mongoose.model("Reservation", reservationSchema);
