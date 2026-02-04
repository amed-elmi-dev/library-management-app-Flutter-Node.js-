const mongoose = require("mongoose");

const borrowSchema = new mongoose.Schema(
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
    copy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "BookCopy",
      required: true,
      index: true,
    },
    borrowedAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
    dueAt: {
      type: Date,
      required: true,
      index: true,
    },
    returnedAt: {
      type: Date,
      default: null,
    },
    status: {
      type: String,
      enum: ["active", "returned"],
      default: "active",
      index: true,
    },
  },
  { timestamps: true },
);

borrowSchema.index({ user: 1, status: 1 });
borrowSchema.index({ book: 1, status: 1 });

module.exports = mongoose.model("Borrow", borrowSchema);
