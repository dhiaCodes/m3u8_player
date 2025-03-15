class HlsPlayer {
  constructor(videoElement, url) {
    console.log('[HlsPlayer] Inicializando com URL:', url);
    this.video = videoElement;
    this.url = url;
    this.hls = null;
    this.initialize();
  }

  initialize() {
    if (Hls.isSupported()) {
      this.hls = new Hls({
        debug: false,
        enableWorker: true,
        lowLatencyMode: true,
      });

      this.hls.loadSource(this.url);

      this.hls.attachMedia(this.video);

      this.hls.on(Hls.Events.MANIFEST_PARSED, () => {

        this.video.play();
      });

      this.hls.on(Hls.Events.ERROR, (event, data) => {
        if (data.fatal) {
          switch (data.type) {
            case Hls.ErrorTypes.NETWORK_ERROR:
      
              this.hls.startLoad();
              break;
            case Hls.ErrorTypes.MEDIA_ERROR:
        
              this.hls.recoverMediaError();
              break;
            default:
      
              this.destroy();
              break;
          }
        }
      });
    } else if (this.video.canPlayType('application/vnd.apple.mpegurl')) {
  
      this.video.src = this.url;
    }
  }

  getQualities() {
    if (!this.hls) return [];
 
    const levels = this.hls.levels;
    return levels.map((level, index) => ({
      width: level.width,
      height: level.height,
      bitrate: level.bitrate,
      label: `${level.height}p`,
      index: index,
    }));
  }

  setQuality(index) {
    if (!this.hls) return;
 
    this.hls.currentLevel = index;
  }

  getCurrentQuality() {
    if (!this.hls) return null;
    return this.hls.currentLevel;
  }

  destroy() {
   
    if (this.hls) {
      this.hls.destroy();
      this.hls = null;
    }
  }
} 