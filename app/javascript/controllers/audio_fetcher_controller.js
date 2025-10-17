import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async fetch(event) {
    const buttonElement = event.currentTarget;
    const playIconDiv = buttonElement.querySelector("[data-play-icon-url]");
    const params = event.params;

    const audioPlayer = this.application.getControllerForElementAndIdentifier(document.body, "audio-player");
    if (!audioPlayer) {
      console.error("The global audio-player controller was not found.");
      return;
    }

    const presignedUrl = playIconDiv.dataset.playIconUrl;

    if (presignedUrl) {
      // URL already exists. Call the main play function with the item's specific data.
      // The audio_player controller will correctly determine if it should toggle or switch tracks.
      audioPlayer.play({
        params: { ...params, url: presignedUrl }
      });
    } else {
      // URL has not been fetched yet. Fetch it now.
      try {
        const response = await fetch(params.url);
        const data = await response.json();
        const newPresignedUrl = data.url;

        if (newPresignedUrl) {
          // Cache the fetched URL on the element for future clicks.
          playIconDiv.dataset.playIconUrl = newPresignedUrl;

          // Command the player to play the new clip.
          audioPlayer.play({
            params: { ...params, url: newPresignedUrl }
          });
        } else {
          console.error("Failed to fetch presigned URL:", data.error);
        }
      } catch (error) {
        console.error("Error fetching audio URL:", error);
      }
    }
  }
}