const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto"); // Node.js built-in crypto module for encryption

admin.initializeApp();

exports.sendVerificationCode = functions.https.onCall(async (data, context) => {
  try {
    const token = data.token;

    // 1. Generate Verification Code
    const verificationCode = Math.floor(1000 + Math.random() * 9000).toString();

    // 2. Encryption (Replace with your actual encryption logic)
    const algorithm = 'aes-256-cbc';
    const key = crypto.randomBytes(32);
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(algorithm, Buffer.from(key), iv);

    let encryptedCode = cipher.update(verificationCode);
    encryptedCode = Buffer.concat([encryptedCode, cipher.final()]);
    const encrypted = `${iv.toString('hex')}:${encryptedCode.toString('hex')}`;


    // 3. Send FCM Message
    await admin.messaging().send({
      token: token,
      notification: {
        title: "Verification Code",
        body: encrypted,  // Send the encrypted code
      },
    });
    //save to real time
    const codeRef = admin.database().ref('verificationCode');
    codeRef.child('code').set(encrypted); // Use a child node to store the code
    codeRef.child('timestamp').set(Date.now());

    // Log success
    console.log("Verification code sent successfully:", verificationCode);
    return { success: true };
  } catch (error) {
    // Log and return error
    console.error("Error sending verification code:", error);
    return { success: false, error: error.message };
  }
});






//const admin = require("firebase-admin");
//const crypto = require("crypto");
//const functions = require("firebase-functions");
//
//admin.initializeApp();
//const firestore = admin.firestore();
//
//// Secure encryption key – Store in environment variables
//const encryptionKey = functions.config().security.encryption_key;
//const key = Buffer.from(encryptionKey, "utf-8");
//
///**
// * Sends a verification code via Firebase Cloud Messaging.
// *
// * @param {Object} data - The data object containing the token.
// * @param {Object} context - The context in which the function is called.
// * @return {Object} - A success message or an error.
// */
//exports.sendVerificationCode = functions.https.onCall(async (data, context) => {
//  try {
//    // Validate the input
//    if (!data.token) {
//      throw new functions.https.HttpsError(
//        "invalid-argument",
//        "The function must be called with a token."
//      );
//    }
//
//    // Fetch verification code from Firestore
//    const snapshot = await firestore
//      .collection("verification-code")
//      .doc("vr-code")
//      .get();
//
//    if (!snapshot.exists) {
//      throw new Error("Verification code document not found");
//    }
//
//    const verificationCode = snapshot.get("verification-code");
//
//    // Encrypt verification code
//    const encryptedCode = encryptCode(verificationCode, key);
//
//    // Send notification with encrypted code
//    const message = {
//      token: data.token,
//      notification: {
//        title: "Verification Code",
//        body: encryptedCode,
//      },
//      priority: "high",
//    };
//
//    const response = await admin.messaging().send(message);
//    console.log("Successfully sent message:", response);
//
//    return {
//      success: true,
//      message: "Verification code sent successfully",
//    };
//  } catch (error) {
//    console.error("Error sending verification code:", error);
//    throw new functions.https.HttpsError(
//      "internal",
//      "Error sending verification code",
//      { details: error.message } // Added a more specific error message
//    );
//  }
//});
//
///**
// * Encrypts a verification code using AES-256-CBC.
// *
// * @param {string} code - The verification code to encrypt.
// * @param {Buffer} key - The encryption key.
// * @return {string} - The encrypted code.
// */
//function encryptCode(code, key) {
//  const algorithm = "aes-256-cbc";
//  const iv = crypto.randomBytes(16);
//
//  const cipher = crypto.createCipheriv(algorithm, key, iv);
//  let encrypted = cipher.update(Buffer.from(code, "utf-8"), "utf8", "hex");
//  encrypted += cipher.final("hex");
//  return ${iv.toString("hex")}:${encrypted};
//}