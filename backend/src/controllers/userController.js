const User = require("../models/User");

const getProfile = async (req, res) => {
  res.status(200).json({
    message: "User profile fetched successfully",
    user: req.user,
  });
};

const updateProfile = async (req, res) => {
  try {
    const { name, email } = req.body;

    if (!name || !email) {
      return res.status(400).json({ message: "Name and email are required" });
    }

    const emailExists = await User.findOne({
      email,
      _id: { $ne: req.user._id },
    });
    if (emailExists) {
      return res.status(400).json({ message: "Email already in use" });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.name = name;
    user.email = email;
    await user.save();

    const updatedUser = await User.findById(req.user._id).select("-password");

    return res.status(200).json({
      message: "Profile updated successfully",
      user: updatedUser,
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getUsers = async (req, res) => {
  try {
    const users = await User.find().select("-password");
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getProfile, updateProfile, getUsers };
