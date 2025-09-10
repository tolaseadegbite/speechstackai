import { Controller } from "@hotwired/stimulus"

// --- Singleton Audio Instance ---
// This single audio object persists across the entire user session.
let audio;
if (!window.playerAudio) {
  window.playerAudio = new Audio();
}
audio = window.playerAudio;

// --- Global Event Handlers ---
// These are attached ONCE to the audio object. They find the active
// controller on the page and tell it to update its UI.
const handleTimeUpdate = () => {
  const controller = document.body.audioPlayerController;
  if (controller) controller.updateProgressUI();
};

const handleLoadedMetadata = () => {
  const controller = document.body.audioPlayerController;
  if (controller) controller.updateDurationUI();
};

const handlePlayPause = () => {
  const controller = document.body.audioPlayerController;
  if (controller) controller.updatePlayPauseIcons();
};

const handleEnded = () => {
    const controller = document.body.audioPlayerController;
    if (controller) {
        audio.currentTime = 0; // Reset to beginning
        controller.updatePlayPauseIcons();
        controller.updateProgressUI();
    }
}

export default class extends Controller {
  static targets = [
    // Targets for UI elements that need to be updated.
    // Note the plural names, as we have desktop and mobile versions.
    "playPauseIcons",
    "progressBars",
    "progressContainers",
    "currentTimes",
    "durations",
    "clipTitles",
    "clipAuthors",
    "downloadLinks",
    "gradientSwatch"
  ]

  connect() {
    this.audio = audio;
    // Set this instance as the globally active controller.
    document.body.audioPlayerController = this;
    this.audio.preload = "metadata";

    // Attach the global listeners only if they haven't been attached before.
    if (!this.audio.dataset.listenersAttached) {
      this.audio.addEventListener("timeupdate", handleTimeUpdate);
      this.audio.addEventListener("loadedmetadata", handleLoadedMetadata);
      this.audio.addEventListener("play", handlePlayPause);
      this.audio.addEventListener("pause", handlePlayPause);
      this.audio.addEventListener("ended", handleEnded);
      this.audio.dataset.listenersAttached = 'true';
    }

    // On page load, sync the UI with the player's current state.
    this.updateAllUI();
  }

  disconnect() {
    // When navigating away, remove the global reference if it points to this instance.
    if (document.body.audioPlayerController === this) {
      document.body.audioPlayerController = null;
    }
  }

  // --- ACTIONS (Called from HTML) ---

  /**
   * Called from the list of audio clips to start a new track.
   */
  play(event) {
    const { url, title, author, filename, gradientStart, gradientEnd } = event.params;
    const isSameClip = this.audio.src === url;

    if (isSameClip) {
      this.togglePlay();
    } else {
      this.audio.src = url;
      this.currentClipData = { url, title, author, filename, gradientStart, gradientEnd };
      this.updateMetadataUI();
      this.updateGradientUI(); // Call the new method
      this.audio.play().catch(e => console.error("Audio playback failed:", e));
    }

    // --- THIS IS THE FINAL, WORKING LOGIC ---
    // Find the player-visibility controller instance on the page...
    const playerElement = document.querySelector('[data-controller="player-visibility"]');
    if (playerElement) {
      const playerVisibilityController = this.application.getControllerForElementAndIdentifier(
        playerElement,
        "player-visibility"
      );
      // ...and command it to run its `show` method.
      if (playerVisibilityController) {
        playerVisibilityController.show();
      }
    }
  }

  playSample(event) {
    // Prevent the click from bubbling up to the label and selecting the radio button.
    event.preventDefault();
    event.stopPropagation();

    const { url, gradientStart, gradientEnd } = event.params;
    const isSameClip = this.audio.src === url;

    if (isSameClip && this.audio.src) {
      this.audio.paused ? this.audio.play() : this.audio.pause();
    } else {
      this.audio.src = url;
      this.currentClipData = { ...this.currentClipData, gradientStart, gradientEnd };
      this.updateGradientUI(); // Call the new method
      this.audio.play().catch(e => console.error("Audio playback failed:", e));
    }
  }

  /**
   * Called by the main play/pause buttons in the player UI.
   */
  togglePlay() {
    if (!this.audio.src) return;
    this.audio.paused ? this.audio.play() : this.audio.pause();
  }

  rewind() {
    if (!this.audio.src) return;
    this.audio.currentTime = Math.max(0, this.audio.currentTime - 10);
  }

  fastForward() {
    if (!this.audio.src) return;
    this.audio.currentTime += 10;
  }

  seek(event) {
    if (!this.audio.src || isNaN(this.audio.duration)) return;
    const container = event.currentTarget;
    // Use offsetX for simplicity, getBoundingClientRect is more robust for complex layouts
    const clickPosition = event.offsetX / container.clientWidth;
    this.audio.currentTime = clickPosition * this.audio.duration;
  }

  updateGradientUI() {
    if (this.hasGradientSwatchTarget && this.currentClipData.gradientStart && this.currentClipData.gradientEnd) {
      this.gradientSwatchTarget.style.setProperty('--gradient-start', this.currentClipData.gradientStart);
      this.gradientSwatchTarget.style.setProperty('--gradient-end', this.currentClipData.gradientEnd);
    }
  }


  // --- UI UPDATE METHODS ---

  updateAllUI() {
    if (this.audio.src) {
        this.currentClipData = {
            url: this.audio.src,
            title: this.clipTitlesTargets[0]?.textContent || "Audio Clip",
            author: this.clipAuthorsTargets[0]?.textContent || "Unknown",
            filename: this.downloadLinksTargets[0]?.download || "audio.mp3"
        }
        this.updateMetadataUI();
        this.updateProgressUI();
        this.updateDurationUI();
        this.updatePlayPauseIcons();
        this.updateGradientUI();
    }
  }

  updateMetadataUI() {
    this.clipTitlesTargets.forEach(target => target.textContent = this.currentClipData.title);
    this.clipAuthorsTargets.forEach(target => target.textContent = this.currentClipData.author);
    this.downloadLinksTargets.forEach(target => {
        target.href = this.currentClipData.url;
        target.download = this.currentClipData.filename;
    });
  }

  updatePlayPauseIcons() {
    // Find all play icons on the page (in the list and in the player)
    const allPlayIcons = document.querySelectorAll('[data-play-icon-url]');

    allPlayIcons.forEach(icon => {
      const isCurrentlyPlaying = this.audio.src === icon.dataset.playIconUrl;
      if (isCurrentlyPlaying && !this.audio.paused) {
        icon.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>`; // Pause Icon
      } else {
        icon.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M5 3l14 9-14 9V3z"/></svg>`; // Play Icon
      }
    });

    // Also update the main player buttons
    this.playPauseIconsTargets.forEach(icon => {
        if (!this.audio.paused && this.audio.src) {
            icon.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>`; // Pause Icon
        } else {
            icon.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M5 3l14 9-14 9V3z"/></svg>`; // Play Icon
        }
    })
  }

  updateProgressUI() {
    if (!this.audio.duration) return;
    const percentage = (this.audio.currentTime / this.audio.duration) * 100;
    this.progressBarsTargets.forEach(bar => bar.style.inlineSize = `${percentage}%`);
    this.currentTimesTargets.forEach(time => time.textContent = this.formatTime(this.audio.currentTime));
  }

  updateDurationUI() {
    this.durationsTargets.forEach(time => time.textContent = this.formatTime(this.audio.duration));
  }

  formatTime(seconds) {
    if (isNaN(seconds)) return "0:00";
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  }
}