const Book = require("../models/Book");
const BookCopy = require("../models/BookCopy");

// ADMIN: Add book
const createBook = async (req, res) => {
  try {
    const totalCopies = Math.max(1, Number(req.body.totalCopies || 1));
    const book = await Book.create({
      ...req.body,
      totalCopies,
      availableCopies: totalCopies,
    });

    const copies = Array.from({ length: totalCopies }, (_, index) => ({
      book: book._id,
      copyNumber: index + 1,
      status: "available",
    }));
    await BookCopy.insertMany(copies);

    res.status(201).json(book);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// USER: Get all books
const getBooks = async (req, res) => {
  const books = await Book.find();
  res.status(200).json(books);
};

// USER: Get single book
const getBookById = async (req, res) => {
  const book = await Book.findById(req.params.id);

  if (!book) {
    return res.status(404).json({ message: "Book not found" });
  }

  res.status(200).json(book);
};

// ADMIN: Update book
const updateBook = async (req, res) => {
  const book = await Book.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
  });

  if (!book) {
    return res.status(404).json({ message: "Book not found" });
  }

  res.status(200).json(book);
};

// ADMIN: Delete book
const deleteBook = async (req, res) => {
  const book = await Book.findByIdAndDelete(req.params.id);

  if (!book) {
    return res.status(404).json({ message: "Book not found" });
  }

  res.status(200).json({ message: "Book deleted successfully" });
};

module.exports = {
  createBook,
  getBooks,
  getBookById,
  updateBook,
  deleteBook,
};
