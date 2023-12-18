# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you don't use the Dock to launch apps.
defaults write com.apple.dock persistent-apps -array

# Move the Dock to the left
defaults write com.apple.dock orientation -string left

# Make Dock Smaller
defaults write com.apple.dock tilesize -int 40

# Faster key repeat
defaults write -g InitialKeyRepeat -int 12  # Set initial key repeat (lower number is faster)
defaults write -g KeyRepeat -int 1          # Set key repeat rate (lower number is faster)

# Disable dumb "Smart Corners"
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-br-corner -int 0

# To apply changes
killall Dock
