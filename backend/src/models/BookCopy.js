const mongoose = require("mongoose");

const bookCopySchema = new mongoose.Schema(
  {
    book: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Book",
      required: true,
      index: true,
    },
    copyNumber: {
      type: Number,
      required: true,
    },
    status: {
      type: String,
      enum: ["available", "borrowed", "lost", "repair"],
      default: "available",
      index: true,
    },
  },
  { timestamps: true },
);

bookCopySchema.index({ book: 1, copyNumber: 1 }, { unique: true });

module.exports = mongoose.model("BookCopy", bookCopySchema);
