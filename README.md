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

## What's New (v1.0.4)

- **Smart "Forgotten Gems" Recency Ordering**: Re-ordered the "Forgotten Gems" smart playlist to display true forgotten songs (oldest added tracks with `playCount <= 2`) at the top, while newly scanned/added songs are placed at the very bottom.
- **Strict MediaStore Duplicate Song Removal**: Implemented a strict file path and content URI deduplication layer during media scanning (`seenPaths.add(song.data)`), automatically filtering out Android MediaStore ghost entries and preventing duplicate songs from appearing in the library.
- **Automatic Instrumental Melody Detection (3-Dots Wave)**: Intelligent LRC parser that detects intro melodies, instrumental solos/bridges ($\ge 8\text{s}$), and outros, automatically inserting animated 3-dots wave indicators (`♪`) without cutting off active vocals.
- **Enhanced 3-Row Synced Lyrics Layout**: Expanded synced lyrics display capacity to 3 full lines (`maxLines: 3`) with uniform font size across active and inactive states, ensuring long lyrics wrap cleanly without line jumps or text truncation.
- **Localized "Create New Playlist" Action**: Wrapped the playlist creation tile in `AppLocalizations.of(context).createNewPlaylist`, providing seamless i18n support across English, Indonesian, and Japanese.
- **Optimized Google LRC Lyric Search**: Updated the "Search on Google" button query format to use `$artist $title lrc` instead of generic `lyrics`, prioritizing `.lrc` synced file search results on Google.
- **Prevented Duplicate 3-Dots Wave Lines**: Refined empty line detection in the LRC parser (`isWaveLine()`), skipping duplicate wave insertions if the `.lrc` file already contains explicit empty/instrumental timestamps.
- **Full Player Header i18n Localization**: Localized the "PLAYING FROM" category header and smart playlist names (`_playingFromName`), dynamically translating titles (e.g. "Semua Lagu", "Lagu Terlupakan", "Perpustakaan") across English, Indonesian, and Japanese.
- **Semantic Versioning & Update Dialog Overflow Fix**: Upgraded update checks to use strict semantic versioning (`isNewer()`), preventing false-positive update prompts when on newer local versions. Wrapped dialog title text in `Expanded` to prevent horizontal text overflows across all screen sizes and languages.
- **Localized Playlist Track Counts**: Updated playlist card and detail view subtitles to use `AppLocalizations.of(context).songsCount`, ensuring track counts (e.g. `14 lagu`, `14 曲`, `14 songs`) are localized across all languages.
- **Task Removal Notification Cleanup**: Overrode `onTaskRemoved()` in `MyAudioHandler` and updated `didChangeAppLifecycleState` to immediately stop playback and clear the Android media notification whenever the app is swiped away from recent task history.

## Previous Updates (v1.0.3)

- **Library Layout Density Selector**: Added a "Library Density" setting (Standard vs Compact) allowing users to customize track row spacing, thumbnail sizing, and padding to fit up to 25% more songs on screen.
- **Auto-Play on Headset Connect**: Implemented an "Auto-play on Headset Connect" toggle under Audio & Playback. Flow listens to native `AudioSession` device change events and automatically resumes playback when headphones or Bluetooth audio devices connect.
- **Playback Speed & Pitch Controls**: Added dedicated Playback Speed (0.5x - 2.0x) and Pitch Lock configuration to Settings and audio engine, giving users full control over tempo and natural audio pitch.
- **Custom Lyric Font Size Configurator**: Added a "Lyric Font Size" setting with live preview slider (14sp to 30sp), dynamically scaling synced and plain text lyrics across player views.
- **Android Mono Audio Integration**: Re-architected native `MainActivity.kt` and `settings_screen.dart` Mono Audio toggle logic. Implemented multi-key fallback (`master_mono` and `mono_audio` across `Settings.System` and `Settings.Global`) and eliminated false-positive "not supported" toast errors and startup state resets.
- **Robust Scoped Storage Deletion Fallback**: Fixed an issue where deleting a track from device failed to present the "Permission Denied / Hide Track" dialog due to an unmounted `BuildContext` after closing the context menu. Captured `parentContext` to guarantee the fallback dialog is reliably displayed on Android 10+ devices.
- **Auto-Check for Updates Toggle & Startup Check**: Added an "Auto-check for updates" toggle switch in Settings. When enabled, Flow automatically performs a background release check on app launch and prompts the user with an update dialog if a new version is available on GitHub.
- **Synced Last Played & Most Played Logic**: Unified track recency and play-count tracking. All played tracks with `playCount > 0` are automatically backfilled and synced into the **Last Played** smart playlist, ensuring Last Played count is always consistent with Most Played.
- **Audio Ringtone Cutter & Editor**: Integrated a dedicated Ringtone Trimmer accessible directly from any track's context menu. Features interactive dual-handle `RangeSlider` duration selection, real-time slice audio preview playback with timestamp display, dynamic segment length badges, and 1-tap ringtone saving to `/Ringtones/`.
- **Sleep Timer Soft Fade-Out & Custom Minutes Input**: Upgraded the Sleep Timer engine with a smooth volume fade-out mechanism during the final 20 seconds of countdown, preventing abrupt audio cutoffs. Added a custom duration dialog enabling users to input any custom time in minutes (e.g. 7, 25, 90, 120 mins) available across all timer entry points.
- **Song Info Filename Truncation Fix**: Truncated long file names in the Song Info modal with ellipsis (`...`) to prevent horizontal layout overflows and right-side screen leaks.
- **Seamless Hero Morphing Artwork Animation**: Implemented shared element `Hero` animation (`heroTag: "mini_to_full_player_artwork"`) connecting the Mini Player and Full-Screen Song View. Tapping or dragging open the Mini Player causes the 48px artwork thumbnail to fluidly scale and morph into the 300px+ hero artwork with matching border radius transformations at 60 FPS.
- **Expanded Mini Player & Gesture Inset Adaptation**: Enhanced the Mini Player with a taller, roomier 68px container, larger 48px artwork thumbnail, elevated drop-shadow depth, and dynamic bottom gesture inset calculation (`MediaQuery.of(context).padding.bottom`), eliminating empty gaps under gesture navigation bars on modern smartphones.
- **Sleek Rounded Modal Sheet Corners**: Replaced sharp 90-degree rectangle corners on both Album View (Detail View) and Song View (Full-Screen Player) with modern `28px` rounded top-left and top-right corners (`ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(28)))`), delivering an elegant, premium card aesthetic.
- **Dynamic Sticky Top Navbar on Scroll**: Designed and implemented a sleek, sticky top navigation bar for Album, Artist, and Playlist detail views. As the user scrolls down through the track list, the top navbar smoothly fades in with a glassmorphic background, displaying a dedicated back button on the left, truncated album title in selected font typography in the center, and context options on the right.
- **High-Resolution Custom Artwork Engine**: Fixed an issue where custom metadata artwork in Album, Artist, and Playlist detail views appeared blurry ("burik"). Upgraded `CachedTrackArtwork` to use un-downsampled full-resolution `FileImage` with `FilterQuality.high` for large views (`size > 100`), guaranteeing razor-sharp, crystal-clear artwork on 2K and 4K smartphone displays.
- **Smooth 60 FPS Album View Transitions**: Resolved UI micro-stutters when opening Album or Playlist detail views with custom artwork. Updated `ArtworkCacheManager.preloadAllArtworks` to preload full `FileImage` instances into Flutter's `ImageCache` in the background, ensuring instant, stutter-free 60 FPS page transitions.
- **"Forgotten Gems" Smart Playlist**: Introduced a dedicated 4th Smart Playlist ("Forgotten Gems" / "Lagu Terlupakan" / "隠れた名曲") that automatically aggregates all tracks in the user's music library that are rarely played (`playCount <= 2`). Features custom diamond branding, instant playback integration, and full i18n localization support across English, Indonesian, and Japanese.
- **Complete Settings Modals Light Mode Polish**: Comprehensive audit and refinement across all Settings bottom sheets (Sleep Timer, Play Count Threshold, Accent Selector, Player Background Selector, Language Selector). Resolved dark-background leaks under Light Mode by making all modal sheets dynamically adapt their background, drag handle, divider, and text colors based on `isAppLight`.
- **Unlimited Last Played Playlist Capacity**: Completely removed the legacy hardcoded history cap on the **Last Played** smart playlist. Because track IDs are automatically deduplicated upon every playback session, the list now dynamically retains 100% of the user's listened tracks in exact recency order up to their entire music library size.
- **Startup Artwork Preload Race Condition Fix**: Solved a race condition bug where the top 3 tracks lost their thumbnails upon opening the app. During app launch, concurrent native `queryArtwork` requests flooded the Android MethodChannel, causing transient `null` responses that permanently poisoned `ArtworkCacheManager`'s memory cache. Fixed by implementing retry backoff in `fetchAndCacheNativeArtwork`, preventing `null` poison caching on transient startup failures, and configuring `CachedTrackArtwork` to seamlessly fall back to `QueryArtworkWidget` whenever memory cache bytes are pending.
- **Global Context Menu & System Popup Font Inheritance**: Resolved an issue where native context menus (text selection toolbars, popup menus, dropdowns), dialogs, and bottom sheets defaulted to standard system fallback fonts instead of the user's active font configured in Settings. Applied `fontFamily` directly to global `ThemeData`, guaranteeing that all overlays and controls inherit selected typography app-wide.
- **Unified Font Family Resolver Engine**: Built a robust `getFontFamily()` helper method in `globals.dart` to map setting labels (`Spotify Style`, `Apple Music Style`, `Plus Jakarta Sans`) to valid registered Google Fonts identifiers (`Figtree`, `Inter`, `PlusJakartaSans`), permanently eliminating invalid font string fallbacks across all modals, sheets, and views.

## Project Structure

The project has been refactored into a highly modular, decoupled architecture using Dart's `part` and `part of` directives, keeping local state synchronization lightweight and seamless:

- **`lib/main.dart`**: Root application entry, boot sequence initialization, and core Scaffold state container. Now elegantly stripped of massive logic blocks for a clean ~700 line entrypoint.
- **`lib/logic/main_audio_logic.dart`**: The brain of the application. Houses all complex state mutations, audio streaming integrations, dynamic lyric fetching, crossfade lifecycle management, and playback queue transformations.
- **`lib/ui/main_ui_components.dart`**: Core skeletal UI renderers extracted from the main tree, including custom headers, empty states, and dynamic playlist grid covers.
- **`lib/ui/player_ui.dart`**: Fullscreen adaptive music player UI. Houses physics-based swipe-down gestures, sliding mini players, and dynamic palette-based gradients.
- **`lib/ui/detail_views_ui.dart`**: Dynamic detail overlays for Artists, Albums, and custom/default Playlists.
- **`lib/ui/tabs_ui.dart`**: Viewport page layouts hosting horizontal swipable tabs (Songs list, Playlist cards, Artist list, Album cards) and the standard search system.
- **`lib/ui/modals_track_ui.dart` / `modals_playlist_ui.dart` / `modals_utility_ui.dart`**: Highly specialized, domain-driven modal architectures for handling track operations, robust playlist CRUD, Ringtone Cutter, and utility tools (Sleep Timer, Equalizer, Folder Scans).
- **`lib/screens/settings_screen.dart` & `settings_modals.dart`**: A standalone, polished Material 3 settings hub entirely decoupled from monolithic implementations, utilizing isolated component builders and dedicated modal controllers.
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
