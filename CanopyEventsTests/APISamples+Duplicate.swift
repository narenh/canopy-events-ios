/// `GET /events/{id}/duplicate-draft`: the spec's own example
/// (`DuplicateDraft`), in its envelope.
extension APISamples {
    static let duplicateDraft = #"""
    {"draft": {"title": "Drag Race night", "description": "Snacks provided.", "timeZone": "America/Los_Angeles",
      "locationName": "Ana's place", "locationAddress": "1 Market St, San Francisco",
      "latitude": null, "longitude": null, "applePlaceId": null,
      "details": [{"type": "dress_code", "label": null, "value": "Fierce"}],
      "guestListVisibility": "everyone", "guestsAllowed": 1, "capacity": null,
      "themeHue": 320, "themeGrayscale": false, "accentHue": null, "coverFrom": "4fQ9xKpL2mZa",
      "coverImageUrl": "https://events.canopysf.com/covers/Qm7Zc2pR9xTa.jpg?v=1759870000000",
      "coverImages": [{"width": 400, "height": 300, "url": "https://events.canopysf.com/covers/Qm7Zc2pR9xTa-400.jpg?v=1759870000000"},
                      {"width": 800, "height": 600, "url": "https://events.canopysf.com/covers/Qm7Zc2pR9xTa.jpg?v=1759870000000"}],
      "coverHue": 318, "coverGrayscale": false, "lists": [{"id": "Lw3Kp9QzX2aB", "name": "Drag Race"}]}}
    """#
}
