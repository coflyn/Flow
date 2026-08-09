# Flow Audio Player

![License](https://img.shields.io/badge/license-GPLv3-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-lightgrey)
![i18n](https://img.shields.io/badge/i18n-EN%20%7C%20ID%20%7C%20JA-blueviolet)

Flow is a clean, modern offline music player for Android built with Flutter. It offers a smooth listening experience with synced lyrics, customizable themes, and smart playlist management.

## Previews

<p align="center">
  <img src="previews/1.jpeg" width="32%" alt="Preview 1">
  <img src="previews/2.jpeg" width="32%" alt="Preview 2">
  <img src="previews/3.jpeg" width="32%" alt="Preview 3">
</p>
<p align="center">
  <img src="previews/4.jpeg" width="32%" alt="Preview 4">
  <img src="previews/5.jpeg" width="32%" alt="Preview 5">
  <img src="previews/6.jpeg" width="32%" alt="Preview 6">
</p>

## Downloads

Download the latest release APKs directly from the [GitHub Releases](https://github.com/coflyn/Flow/releases) page:

- **`app-arm64-v8a-release.apk`**: Recommended for modern 64-bit Android smartphones.
- **`app-armeabi-v7a-release.apk`**: For older 32-bit Android devices.
- **`app-x86_64-release.apk`**: For Android emulators and x86_64 architecture.

## Features

- **Local Audio Scanning & Deduplication**: Queries audio files from scoped device storage with strict file path deduplication (`seenPaths.add(song.data)`), filtering out MediaStore ghost entries.
- **Smart Playlists Engine**: Dynamically aggregates tracks into _Favourites_, _Recently Added_, _Last Played_, _Most Played_, and _Forgotten Gems_ lists based on play statistics and recency.
- **Custom User Playlists**: Create, rename, and manage custom playlists. Batch add multiple songs using **Hold-to-Select (Multi-Select)** mode. Personalize playlists with custom gallery artwork.
- **Background Playback & Clean Task Cleanup**: OS-level backgrounding service with lock screen media controls. Automatically terminates background service and cleans up notifications when swiped away from recent task history (`stopWithTask="true"`).
- **Adaptive Aesthetics**: Spotify-like dynamic background color extraction from album art using `palette_generator`, painting rich linear gradients.
- **Custom Player Background Styles & Real-Time Wallpaper Editor**: Four Now Playing rendering modes: **Dynamic Gradient**, **Apple Blurred Cover** (glassmorphic overlay with hardware acceleration), **AMOLED Deep Black**, and **Custom Gallery Image**. Includes a real-time wallpaper editor to adjust blur (0-60) and dim (0-90%).
- **Global 3-Choice Theme Modes**: Support for Dark Mode, Light Mode, and Custom Theme Mode with dynamic or gallery wallpapers and live mockup previews.
- **Dynamic Theme Accent Customization**: Accent selector with 9 presets (Spotify Green, Apple Red, Deep Purple, Tidal Cyan, Sunset Orange, Sakura Pink, Luxury Gold, Sapphire Blue, Electric Lime) or **Dynamic (Artwork)** color matching.
- **Interactive Lyrics Engine**: Synced LRC & plain text lyrics up to 3 wrapped lines (`maxLines: 3`). Features **Automatic Instrumental Melody Detection (3-Dots Wave)** for intros, instrumental solos/bridges ($\ge 8\text{s}$), and outros without cutting off active vocals.
- **Audio Ringtone Trimmer & Cutter**: Dedicated ringtone editor with dual-handle slider duration selection, real-time slice preview, and 1-tap saving to `/Ringtones/`.
- **Playback Speed & Pitch Controls**: Smooth tempo adjustment (0.5x - 2.0x) with optional Pitch Lock, optimized with clean DSP routing to eliminate audio crackling.
- **Auto-Play on Headset Connect**: Automatically resumes music playback when headphones or Bluetooth audio devices are connected.
- **Library Layout Density Selector**: Customizable track list density (Standard vs Compact) to fit up to 25% more songs on screen.
- **Multi-Language (i18n) Support**: Complete internationalization across English, Indonesian, and Japanese, automatically matching system locale or manual selection.
- **HSL Contrast Safety (Auto-Brightener)**: Real-time mathematical luminance safety interceptor that boosts dark extracted cover art colors into readable pastels/neons.
- **ValueNotifier Real-Time State Sync**: Continuous visual color stream coupling that propagates theme modifications instantly across all UI controls.
- **Built-in Image Cropper**: Integrated 1:1 and 9:16 aspect ratio image cropping for editing custom album covers and portrait player backgrounds.
- **Multi-Select Batch Actions**: Intuitive "Hold to Select" mode across all song lists for rapid queueing or mass additions to playlists.
- **Dynamic Sleep Timer**: Automatically stop audio playback with built-in presets (15m, 30m, 60m) or custom inputs, complete with soft volume fade-out.
- **Precision Audio Transitions**: Custom Crossfade adjustments (0ms to 3000ms) with a 150ms fade-in/fade-out playing transition.
- **Auto Regex Cleaner & Virtual Metadata Editor**: Native RegExp title cleaner and virtual metadata editor for song titles, artists, and albums.
- **Dynamic Durations & Equalizers**: Formatted track durations next to song lists, transforming into live-animated `MiniMusicVisualizer` equalizers when actively playing.
- **Pixel-Perfect Margin Alignment**: Custom spatial translations (`Transform.translate`) aligning song controls at a precise `24px` horizontal screen margin.
- **Robust Cache Manager**: Ultra-fast artwork preloading engine with multi-tier retries and anti-null failure mechanisms.

## Work in Progress (v1.0.7)

- **YouTube Music (InnerTube) Integration**: Integrated online music search and audio streaming powered by `youtube_explode_dart`. Search tracks dynamically from YouTube Music directly within the Songs tab.
- **Disk-Buffered Streaming Architecture**: Resolved Android ExoPlayer `(0) Source error` and YouTube CDN HTTP 403 Forbidden blocks by implementing Dart-native background disk buffering (`InnerTubeService.getAudioStreamFilePath`). Audio streams buffer the initial 100KB into temporary device storage (`yt_videoId.m4a`), allowing ExoPlayer to play directly from local disk files with zero network errors, zero Range header conflicts, and instant 0ms playback on repeated listens.
- **Online Lyrics Synchronization**: Integrated LRCLIB public API (`fetchOnlineLyrics`) for fetching synced and plain LRC lyrics automatically for YouTube Music online tracks.
- **Combined Header Source Toggle**: Unified `Local` vs `YT Music` search source selector into a sleek, single segmented toggle pill widget (`_buildSearchSourceSegmentedToggle`) seamlessly positioned next to the Settings gear icon in the top header.
- **Online Artwork Renderer**: Updated `CachedTrackArtwork` and player artwork widgets to render high-resolution network cover images for online YouTube tracks with smooth fallback loading indicators.

## Previous Updates (v1.0.6)

- **Massive Internal Refactoring**: Decomposed monolithic God-Object files into 28 focused `part` files across `lib/ui/`, `lib/logic/`, and `lib/screens/`. `main_audio_logic.dart` (2054 lines) split into 5 domain files, `modals_track_ui.dart` (2258 lines) into 9 UI files, `settings_modals.dart` (2671 lines) into 8 settings files. Zero behavior changes — all 98 methods preserved, `flutter analyze` clean.
- **Smooth Synced Lyrics Auto-Follow Return Animation**: Resolved stiff, abrupt position snaps when returning to auto-follow mode after user manual scrolling. Replaced zero-delay jumps with a fluid 900ms `Curves.fastOutSlowIn` curve animation, allowing the lyrics view to glide back to the active line naturally. Tap-to-lyric seek glides instantly to the tapped line, and initial load glides smoothly to the active line instead of jumping from the top.
- **Ringtone Cutter Preview Race Fix**: Fixed a race condition where restarting a cut preview after pausing caused the old preview timer to silently kill the new playback mid-cue. Session-scoped timers now guarantee only the active preview can stop itself.
- **Lyrics Timing Offset**: Fix desynced LRC lyrics directly from Edit/Add Lyrics — set a per-track offset in seconds (positive = lyrics later, negative = lyrics earlier) with quick ±0.1s / ±0.5s steps. Persisted per track and applied automatically on every load. Fully localized (EN/ID/JA).
- **Font Flash Elimination**: Selected Google Font (Figtree / Inter / Plus Jakarta Sans) is now preloaded before the first frame renders, eliminating the default-font flash when launching the app.
- **Removed Double-Tap Album Art Favorite**: Double-tapping the album artwork no longer toggles Favorite status — single tap opens Lyrics only, preventing accidental favorites while browsing.
- **Dynamic Viewport Stagger Animations**: Replaced fixed absolute-index stagger logic with viewport-based count tracking (top 8 visible items) across all tab pills (Songs, Playlists, Artists, Albums). Switching tabs or returning to a scrolled tab now consistently plays cascading slide-up entrance animations for the top visible items regardless of scroll depth.
- **Fail-Safe Backup & Restore Engine**: Resolved `errno = 13 (Permission Denied)` on Android 10–15 Scoped Storage via multi-tiered fallback paths (Public Downloads → App External Storage → App Documents Directory). Guarantees seamless JSON backups and restores across all Android versions.

## Project Structure

The project has been refactored into a highly modular, decoupled architecture using Dart's `part` and `part of` directives, keeping local state synchronization lightweight and seamless:

- **`lib/main.dart`**: Root application entry, boot sequence initialization, and core Scaffold state container. Now elegantly stripped of massive logic blocks for a clean ~700 line entrypoint.
- **`lib/logic/audio_playback_logic.dart`**: Playback queue transformations, smooth seek, repeat modes, and dynamic lyric fetching. (split from `main_audio_logic.dart`)
- **`lib/logic/audio_settings_logic.dart`**: Settings persistence, sleep timer, and detail-color extraction.
- **`lib/logic/audio_streams_logic.dart`**: Audio stream wiring and playback state synchronization.
- **`lib/logic/audio_library_scan_logic.dart`**: Library scanning, permission flow, and startup update checks.
- **`lib/logic/audio_equalizer_logic.dart`**: Saved equalizer session restore.
- **`lib/ui/main_ui_components.dart`**: Core skeletal UI renderers extracted from the main tree, including custom headers, empty states, and dynamic playlist grid covers.
- **`lib/ui/player_ui.dart`**: Fullscreen adaptive music player UI. Houses physics-based swipe-down gestures, sliding mini players, and dynamic palette-based gradients.
- **`lib/ui/detail_views_ui.dart`**: Dynamic detail overlays for Artists, Albums, and custom/default Playlists.
- **`lib/ui/tabs_ui.dart`**: Viewport page layouts hosting horizontal swipable tabs (Songs list, Playlist cards, Artist list, Album cards) and the standard search system.
- **`lib/ui/track_options_ui.dart` / `edit_metadata_ui.dart` / `sort_ui.dart` / `sort_modal_ui.dart` / `detail_sort_ui.dart`**: Track option modals, metadata editor, and sort/detail-sort sheets. (split from `modals_track_ui.dart`)
- **`lib/ui/song_info_ui.dart` / `cover_picker_ui.dart` / `song_cover_picker_ui.dart` / `ringtone_cutter_ui.dart`**: Song info, cover selection, and ringtone cutter modals. (split from `modals_track_ui.dart`)
- **`lib/ui/playlist_edit_songs_ui.dart` / `playlist_manage_ui.dart`**: Playlist song editing and management CRUD modals. (split from `modals_playlist_ui.dart`)
- **`lib/ui/sleep_timer_ui.dart` / `folder_scan_ui.dart` / `modals_utility_ui.dart` / `equalizer_sheet_ui.dart`**: Sleep timer, folder scan, and equalizer sheet modals. (split from `modals_utility_ui.dart`)
- **`lib/screens/settings_screen.dart` & split settings modals** (`settings_sleep_timer.dart`, `settings_backup_restore.dart`, `settings_hidden_tracks.dart`, `settings_threshold_ui.dart`, `settings_typography_ui.dart`, `settings_theme_accent_ui.dart`, `settings_theme_mode_ui.dart`, `settings_language_density_ui.dart`): A standalone, polished Material 3 settings hub entirely decoupled from monolithic implementations, utilizing isolated component builders and dedicated modal controllers.
- **`lib/widgets/settings/settings_ui_components.dart`**: Modularized stateless building blocks for the Settings screen (Section Headers, Premium Cards, Switch Tiles, List Tiles).
- **`lib/providers/settings_provider.dart`**: Riverpod state management providers for reactive settings updates across the app.
- **`lib/services/audio_handler.dart`**: OS-level audio intent interception and background service hooks (`MyAudioHandler`).
- **`lib/utils/artwork_cache_manager.dart`**: Ultra-fast multi-tier background artwork preloading and memory caching engine.
- **`lib/utils/image_cropper_util.dart`**: Native and pure Flutter 1:1 and 9:16 aspect ratio image cropping utilities.
- **`lib/utils/globals.dart`**: Centralized dependency injection for global state `ValueNotifiers`, theme configuration tools, and app-wide Toast notification helpers.
- **`lib/l10n/`**: Type-safe Flutter `AppLocalizations` ARB files (`app_en.arb`, `app_id.arb`, `app_ja.arb`) for full English, Indonesian, and Japanese internationalization.

## Dependencies

- **`just_audio`**: High-performance local and streaming audio playback engine.
- **`audio_service`**: OS-level audio session backgrounding and system tray locking controls using MediaSession APIs.
- **`on_audio_query`**: Scoped querying of local media storage structures.
- **`permission_handler`**: Runtime operating system authorization checks (Storage/Notification).
- **`shared_preferences`**: Local key-value state persistence (play count, custom playlists, settings).
- **`flutter_riverpod`**: Reactive state management framework for clean decoupled architecture.
- **`google_fonts`**: Premium text styles and typography integration (Figtree, Inter, Plus Jakarta Sans).
- **`mini_music_visualizer`**: Real-time visual music playing equalizer bars.
- **`fluttertoast`**: Non-blocking platform native alert toasts.
- **`palette_generator`**: Extraction of dynamic dominant palette colors from album art.
- **`image_picker`**: Device photo gallery selection utilities.
- **`image_cropper` / `crop_image`**: Pure Flutter and native interactive image cropping framework.
- **`audio_session`**: Native platform hardware-level audio session interrupt binds and headset connect listeners.
- **`url_launcher`**: Intent dispatching to external links (GitHub / Sociabuzz).
- **`package_info_plus`**: Dynamic application version extraction.

## Build Requirements

- **Android**: Requires `minSdk` 21, `targetSdk` 34 (or higher), and Java 17 for compilation. Note that the project utilizes Flutter's Built-in Kotlin compatibility.
- **Gradle & Kotlin**: Android Gradle Plugin 8.+ with Kotlin Built-in compiler options (`JVM 17`).
- **Split Release Command**: Build optimized target-architecture APKs using `flutter build apk --release --split-per-abi`.

## Development Notes

- When running on Android 13 or higher, ensure that the application is granted the `READ_MEDIA_AUDIO` permission for proper library scanning. The application uses `content://` URIs to support scoped storage natively.
- Make sure to use JDK 17 for compiling the Android build due to updated Kotlin and Gradle Plugin (`build.gradle.kts`) requirements.
- Native Android methods (Equalizer, Mono Audio, Ringtone export) are bridged via MethodChannels in `MainActivity.kt`.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0). See the [LICENSE](LICENSE) file for more details.
