import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { searchGooglePlaces } from "./google_places_service";

const googlePlacesKey = defineSecret(
    "GOOGLE_PLACES_API_KEY",
);

export const searchPlaces = onCall(
    { secrets: [googlePlacesKey] },
    async (request) => {
        const query = request.data?.query;

        if (typeof query !== "string" || query.trim().length === 0) {
        throw new HttpsError(
            "invalid-argument",
            "A search query is required.",
        );
        }

        try {
        return await searchGooglePlaces(
            query,
            googlePlacesKey.value(),
        );
        } catch (error) {
        console.error(error);

        throw new HttpsError(
            "internal",
            "Could not search for places.",
        );
        }
    },
);