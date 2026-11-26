
const {onCall, HttpsError} =
  require("firebase-functions/v2/https");

const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} =
  require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();

// Accept an invitation and join its gathering.
exports.acceptInvitation = onCall(
  {region: "us-central1"},
  async (request) => {
    // Verify authentication.
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be logged in."
      );
    }

    const userId = request.auth.uid;
    const invitationId = request.data.invitationId;

    if (typeof invitationId !== "string" ||
        invitationId.trim().length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "A valid invitation ID is required."
      );
    }

    const invitationRef =
      db.collection("invitations").doc(invitationId);

    await db.runTransaction(async (transaction) => {
      const invitationDoc =
        await transaction.get(invitationRef);

      if (!invitationDoc.exists) {
        throw new HttpsError(
          "not-found",
          "Invitation not found."
        );
      }

      const invitation = invitationDoc.data();

      // Only the recipient can accept the invitation.
      if (invitation.inviteeId !== userId) {
        throw new HttpsError(
          "permission-denied",
          "This invitation does not belong to you."
        );
      }

      if (invitation.status !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          "Invitation has already been answered."
        );
      }

      const gatheringRef =
        db.collection("gatherings").doc(invitation.gatheringId);

      const gatheringDoc =
        await transaction.get(gatheringRef);

      if (!gatheringDoc.exists) {
        throw new HttpsError(
          "not-found",
          "Gathering not found."
        );
      }

      // Update invitation status.
      transaction.update(invitationRef, {
        status: "accepted",
      });

      // Add the user without duplicating their UID.
      transaction.update(gatheringRef, {
        participantIds: FieldValue.arrayUnion(userId),
      });
    });

    return {
      success: true,
      message: "Invitation accepted successfully.",
    };
  }
);

