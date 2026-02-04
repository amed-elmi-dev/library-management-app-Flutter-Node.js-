const mongoose = require("mongoose");
const Book = require("../models/Book");
const BookCopy = require("../models/BookCopy");
const Borrow = require("../models/Borrow");
const Reservation = require("../models/Reservation");

const DEFAULT_BORROW_DAYS = Number(process.env.BORROW_DAYS || 14);
const DEFAULT_BORROW_LIMIT = Number(process.env.BORROW_LIMIT || 3);
const USE_TRANSACTIONS = String(process.env.USE_TRANSACTIONS || "true") !== "false";

const TRANSACTION_NOT_SUPPORTED =
  "Transaction numbers are only allowed on a replica set member or mongos";

const runWithOptionalTransaction = async (work) => {
  if (!USE_TRANSACTIONS) {
    return work(null);
  }

  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const result = await work(session);
    await session.commitTransaction();
    return result;
  } catch (error) {
    await session.abortTransaction();

    if (error?.message?.includes(TRANSACTION_NOT_SUPPORTED)) {
      return work(null);
    }

    throw error;
  } finally {
    session.endSession();
  }
};

const borrowBook = async (req, res) => {
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
  }).sort({ copyNumber: 1 });

  if (!availableCopy) {
    const reservation = await Reservation.create({
      user: req.user._id,
      book: bookId,
    });
    return res.status(202).json({
      message: "No copies available. Reservation created.",
      reservation,
    });
  }

  const activeBorrowCount = await Borrow.countDocuments({
    user: req.user._id,
    status: "active",
  });
  if (activeBorrowCount >= DEFAULT_BORROW_LIMIT) {
    return res.status(409).json({
      message: `Borrowing limit reached (max ${DEFAULT_BORROW_LIMIT})`,
    });
  }

  try {
    const dueAt = new Date(
      Date.now() + DEFAULT_BORROW_DAYS * 24 * 60 * 60 * 1000,
    );

    const borrow = await runWithOptionalTransaction(async (session) => {
      const createOptions = session ? { session } : undefined;
      const updateOptions = session ? { session } : undefined;

      const created = await Borrow.create(
        [
          {
            user: req.user._id,
            book: bookId,
            copy: availableCopy._id,
            dueAt,
          },
        ],
        createOptions,
      );

      await BookCopy.updateOne(
        { _id: availableCopy._id },
        { $set: { status: "borrowed" } },
        updateOptions,
      );

      await Book.updateOne(
        { _id: bookId },
        { $inc: { availableCopies: -1 } },
        updateOptions,
      );

      return created[0];
    });

    return res.status(201).json({
      message: "Book borrowed successfully",
      borrow,
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const returnBorrow = async (req, res) => {
  const borrow = await Borrow.findById(req.params.id);
  if (!borrow) {
    return res.status(404).json({ message: "Borrow not found" });
  }

  const isOwner = borrow.user.toString() === req.user._id.toString();
  const isAdmin = req.user.role === "admin";
  if (!isOwner && !isAdmin) {
    return res.status(403).json({ message: "Not allowed to return this borrow" });
  }

  if (borrow.status !== "active") {
    return res.status(400).json({ message: "Borrow already returned" });
  }

  try {
    const result = await runWithOptionalTransaction(async (session) => {
      const updateOptions = session ? { session } : undefined;

      await Borrow.updateOne(
        { _id: borrow._id },
        { $set: { status: "returned", returnedAt: new Date() } },
        updateOptions,
      );

      const reservationQuery = Reservation.find({
        book: borrow.book,
        status: "active",
      }).sort({ createdAt: 1 });
      if (session) {
        reservationQuery.session(session);
      }

      const reservations = await reservationQuery;

      let nextReservation = null;
      for (const reservation of reservations) {
        const countQuery = Borrow.countDocuments({
          user: reservation.user,
          status: "active",
        });
        if (session) {
          countQuery.session(session);
        }

        const reservationBorrowCount = await countQuery;
        if (reservationBorrowCount < DEFAULT_BORROW_LIMIT) {
          nextReservation = reservation;
          break;
        }
      }

      if (nextReservation) {
        const dueAt = new Date(
          Date.now() + DEFAULT_BORROW_DAYS * 24 * 60 * 60 * 1000,
        );

        const createOptions = session ? { session } : undefined;
        await Borrow.create(
          [
            {
              user: nextReservation.user,
              book: borrow.book,
              copy: borrow.copy,
              dueAt,
            },
          ],
          createOptions,
        );

        await Reservation.updateOne(
          { _id: nextReservation._id },
          { $set: { status: "fulfilled" } },
          updateOptions,
        );

        await BookCopy.updateOne(
          { _id: borrow.copy },
          { $set: { status: "borrowed" } },
          updateOptions,
        );

        return { reassigned: true };
      }

      await BookCopy.updateOne(
        { _id: borrow.copy },
        { $set: { status: "available" } },
        updateOptions,
      );

      await Book.updateOne(
        { _id: borrow.book },
        { $inc: { availableCopies: 1 } },
        updateOptions,
      );

      return { reassigned: false };
    });

    if (result.reassigned) {
      return res.status(200).json({
        message: "Borrow returned and reassigned to next reservation",
      });
    }

    return res.status(200).json({ message: "Borrow returned successfully" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getMyBorrows = async (req, res) => {
  const borrows = await Borrow.find({ user: req.user._id })
    .populate("book")
    .populate("copy")
    .sort({ createdAt: -1 });

  res.status(200).json(borrows);
};

const getAllBorrows = async (req, res) => {
  const borrows = await Borrow.find()
    .populate("book")
    .populate("copy")
    .populate("user", "name email role")
    .sort({ createdAt: -1 });

  res.status(200).json(borrows);
};

const getOverdueBorrows = async (req, res) => {
  const now = new Date();
  const borrows = await Borrow.find({
    status: "active",
    dueAt: { $lt: now },
  })
    .populate("book")
    .populate("copy")
    .populate("user", "name email role")
    .sort({ dueAt: 1 });

  res.status(200).json(borrows);
};

module.exports = {
  borrowBook,
  returnBorrow,
  getMyBorrows,
  getAllBorrows,
  getOverdueBorrows,
};
