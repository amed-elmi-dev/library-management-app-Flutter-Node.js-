const Book = require("../models/Book");
const BookCopy = require("../models/BookCopy");
const Reservation = require("../models/Reservation");
const Borrow = require("../models/Borrow");

const createReservation = async (req, res) => {
  const { bookId } = req.body;

  if (!bookId) {
    return res.status(400).json({ message: "bookId is required" });
  }

  const book = await Book.findById(bookId);
  if (!book) {
    return res.status(404).json({ message: "Book not found" });
  }

  const existingBorrow = await Borrow.findOne({
    user: req.user._id,
    book: bookId,
    status: "active",
  });
  if (existingBorrow) {
    return res.status(409).json({ message: "You already borrowed this book" });
  }

  const existingReservation = await Reservation.findOne({
    user: req.user._id,
    book: bookId,
    status: "active",
  });
  if (existingReservation) {
    return res
      .status(409)
      .json({ message: "You already have an active reservation" });
  }

  const availableCopy = await BookCopy.findOne({
    book: bookId,
    status: "available",
  });

  if (availableCopy) {
    return res.status(400).json({
      message: "Book is available. Please borrow instead of reserving.",
    });
  }

  const reservation = await Reservation.create({
    user: req.user._id,
    book: bookId,
  });

  res.status(201).json({
    message: "Reservation created",
    reservation,
  });
};

const getMyReservations = async (req, res) => {
  const reservations = await Reservation.find({ user: req.user._id })
    .populate("book")
    .sort({ createdAt: -1 });

  res.status(200).json(reservations);
};

const getAllReservations = async (req, res) => {
  const reservations = await Reservation.find()
    .populate("book")
    .populate("user", "name email role")
    .sort({ createdAt: -1 });

  res.status(200).json(reservations);
};

const cancelReservation = async (req, res) => {
  const reservation = await Reservation.findById(req.params.id);
  if (!reservation) {
    return res.status(404).json({ message: "Reservation not found" });
  }

  const isOwner = reservation.user.toString() === req.user._id.toString();
  const isAdmin = req.user.role === "admin";
  if (!isOwner && !isAdmin) {
    return res.status(403).json({ message: "Not allowed to cancel" });
  }

  if (reservation.status !== "active") {
    return res.status(400).json({ message: "Reservation already closed" });
  }

  reservation.status = "canceled";
  await reservation.save();

  res.status(200).json({
    message: "Reservation canceled",
    reservation,
  });
};

module.exports = {
  createReservation,
  getMyReservations,
  getAllReservations,
  cancelReservation,
};
