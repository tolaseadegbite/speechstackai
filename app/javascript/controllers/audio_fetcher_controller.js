import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async fetch(event) {
    const buttonElement = event.currentTarget;
    const playIconDiv = buttonElement.querySelector("[data-play-icon-url]");

    // Find the audio-player controller first.
    const audioPlayer = this.application.getControllerForElementAndIdentifier(document.body, "audio-player");
    if (!audioPlayer) {
      console.error("The global audio-player controller was not found.");
      return;
    }

    // --- THE FIX IS HERE ---
    // Check if the URL has already been fetched and set.
    const hasAlreadyBeenFetched = playIconDiv.dataset.playIconUrl

    if (hasAlreadyBeenFetched) {
      // If the URL exists, don't fetch again. Just tell the player to toggle.
      audioPlayer.togglePlay();
    } else {
      // If the URL has NOT been fetched, then run the fetch logic.
      const params = event.params;
      const response = await fetch(params.url);
      const data = await response.json();
      const presignedUrl = data.url;

      if (presignedUrl) {
        // Set the URL on the icon div so we know it's fetched for next time.
        playIconDiv.dataset.playIconUrl = presignedUrl;

        // Command the player to play with all the necessary data.
        audioPlayer.play({
          params: { ...params, url: presignedUrl }
        });
      } else {
        console.error("Failed to fetch presigned URL:", data.error);
      }
    }
  }
}