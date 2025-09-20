const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure your email transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "hhkotak.22@gmail.com",
    pass: "abc123" // NOT normal Gmail password
  }
});

// Trigger: when new Gatepass doc is created
exports.sendGatepassEmail = functions.firestore
  .document("Gatepass/{gatepassId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    const mailOptions = {
      from: "HostelMate <hhkotak.22@gmail.com>",
      to: data.GuardianEmail, // make sure GuardianEmail is saved in Firestore
      subject: "Gatepass Request from HostelMate",
      text: `
Dear Parent/Guardian,

Your ward has generated a gatepass.

Reason: ${data.reason}
Going: ${data.goingDate.toDate()}
Return: ${data.returnDate.toDate()}

Please approve/reject this request via the app.

Regards,
HostelMate Admin
`
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log("✅ Gatepass email sent!");
    } catch (error) {
      console.error("❌ Error sending email:", error);
    }
  });
