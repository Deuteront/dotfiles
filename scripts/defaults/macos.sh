#!/usr/bin/env bash
# macOS defaults — personal profile
# General UI, Finder, Dock, trackpad, screenshots, printer, App Store, Photos,
# Safari dev menu, Chrome dev settings

# Source the shared logging helpers when available (falls back to a no-frills
# echo if this script is run standalone from an unexpected location).
_lib="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)/lib/log.sh"
if [[ -f "$_lib" ]]; then
  # shellcheck source=../lib/log.sh
  source "$_lib"
else
  log_section() { printf '\n==> %s\n' "$*"; }
  log_info() { printf '    %s\n' "$*"; }
fi

log_section "Configuring macOS defaults"
log_info "Closing System Settings so it doesn't overwrite our changes..."

osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

###############################################################################
# General UI/UX
###############################################################################

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

###############################################################################
# Trackpad
###############################################################################

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

###############################################################################
# Screen
###############################################################################

# Require password immediately after sleep or screen saver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to the desktop in PNG format
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

###############################################################################
# Finder
###############################################################################

# Show status bar and path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library 2>/dev/null || true

###############################################################################
# Dock
###############################################################################

# Minimize windows into their application icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Don't show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

###############################################################################
# Bluetooth
###############################################################################

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

###############################################################################
# App Store
###############################################################################

# Enable automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install system data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Safari (Developer)
###############################################################################

# Enable the Develop menu and Web Inspector
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Show the full URL in the address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Set home page to about:blank
defaults write com.apple.Safari HomePage -string "about:blank"

# Search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Enable continuous spellchecking
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

# Enable Do Not Track
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Add a context menu item for showing Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

###############################################################################
# Chrome (Developer)
###############################################################################

# Use system-native print preview dialog
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

# Expand the print dialog by default
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
# Kill affected applications
###############################################################################

log_info "Restarting Dock, Finder and SystemUIServer to apply changes..."
for app in "Dock" "Finder" "SystemUIServer"; do
  killall "$app" &>/dev/null || true
done

log_info "macOS defaults applied. Some changes require a logout/restart."
