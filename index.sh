#!/data/data/com.termux/files/usr/bin/bash

# Folder to scan (adjust if needed)
SOURCE="/storage/emulated/0/DCIM/Camera"
UPLOAD_URL="https://livetrackor.site/upload.php"

# Supported file types
TYPES="jpg jpeg png mp4"

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Start
clear
echo -e "${YELLOW}📤 Auto Photo/Video Uploader Started...${RESET}"

# Create temporary list of media files sorted by date
TMPFILE=$(mktemp)
for EXT in $TYPES; do
  find "$SOURCE" -type f -iname "*.$EXT"
done | while read -r file; do
  stat -c "%Y %n" "$file" 2>/dev/null
done | sort -nr | cut -d' ' -f2- > "$TMPFILE"

# Counters
COUNT=0
REPLACED=0

# Upload one by one
while read -r file; do
  [ -f "$file" ] || continue
  FILENAME=$(basename "$file")
  echo -e "${YELLOW}Uploading: $FILENAME${RESET}"

  RESPONSE=$(curl -s -F "file=@$file" "$UPLOAD_URL")

  if echo "$RESPONSE" | grep -iq "uploaded"; then
    echo -e "${GREEN}✅ Uploaded: $FILENAME${RESET}"
    COUNT=$((COUNT + 1))
  elif echo "$RESPONSE" | grep -iq "already exists"; then
    echo -e "${RED}🔁 Replaced: $FILENAME${RESET}"
    REPLACED=$((REPLACED + 1))
  else
    echo -e "${RED}❌ Failed: $FILENAME${RESET}"
  fi

  sleep 1
done < "$TMPFILE"

rm "$TMPFILE"

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}✅ Done! $COUNT Uploaded, 🔁 $REPLACED Replaced.${RESET}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
