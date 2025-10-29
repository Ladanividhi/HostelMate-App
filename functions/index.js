const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.approveGatepass = functions.https.onRequest(async (req, res) => {
  const gatepassId = req.query.gatepassId;
  if (!gatepassId) return res.status(400).send("❌ Missing gatepassId");

  await db.collection("Gatepass").doc(gatepassId).update({ parentApproval: "Approved" });
  return res.send("✅ Gatepass Approved!");
});

exports.declineGatepass = functions.https.onRequest(async (req, res) => {
  const gatepassId = req.query.gatepassId;
  if (!gatepassId) return res.status(400).send("❌ Missing gatepassId");

  await db.collection("Gatepass").doc(gatepassId).update({ parentApproval: "Declined" });
  return res.send("❌ Gatepass Declined!");
});
