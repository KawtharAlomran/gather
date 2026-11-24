export async function searchGooglePlaces(
    query: string,
    apiKey: string,
    ) {
    const response = await fetch(
        "https://places.googleapis.com/v1/places:searchText",
        {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "X-Goog-Api-Key": apiKey,
            "X-Goog-FieldMask":
            "places.id,places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.googleMapsUri",
        },
        body: JSON.stringify({
            textQuery: query,
            languageCode: "en",
        }),
        },
    );

    if (!response.ok) {
        throw new Error(
        `Google Places error: ${response.status}`,
        );
    }

    return await response.json();
}