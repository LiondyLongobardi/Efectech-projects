#!/bin/bash
# ── Efectech – Deploy / Update script ────────────────────────────
# Run this script on your server to deploy or update the website.
# Usage:  bash deploy.sh
set -euo pipefail

GREEN='\033[0;32m'
TEAL='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${TEAL}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

echo ""
echo "  ███████╗███████╗███████╗ ██████╗████████╗███████╗ ██████╗██╗  ██╗"
echo "  ██╔════╝██╔════╝██╔════╝██╔════╝╚══██╔══╝██╔════╝██╔════╝██║  ██║"
echo "  █████╗  █████╗  █████╗  ██║        ██║   █████╗  ██║     ███████║"
echo "  ██╔══╝  ██╔══╝  ██╔══╝  ██║        ██║   ██╔══╝  ██║     ██╔══██║"
echo "  ███████╗██║     ███████╗╚██████╗   ██║   ███████╗╚██████╗██║  ██║"
echo "  ╚══════╝╚═╝     ╚══════╝ ╚═════╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝"
echo "                     Efectivo digital, al instante."
echo ""

# ── 1. Check Docker ────────────────────────────────────────────────
info "Checking Docker..."
command -v docker &>/dev/null  || error "Docker is not installed. Install it with: curl -fsSL https://get.docker.com | sh"
command -v docker &>/dev/null && docker compose version &>/dev/null || error "Docker Compose plugin not found. Update Docker."
ok "Docker found: $(docker --version)"

# ── 2. Pull latest code ────────────────────────────────────────────
REPO_URL="https://github.com/LiondyLongobardi/Efectech-projects.git"
BRANCH="claude/efectech-website-8DkMZ"
DEST="/opt/efectech"

if [ -d "$DEST/.git" ]; then
  info "Pulling latest changes..."
  git -C "$DEST" fetch origin "$BRANCH"
  git -C "$DEST" checkout "$BRANCH"
  git -C "$DEST" pull origin "$BRANCH"
else
  info "Cloning repository to $DEST ..."
  git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$DEST"
fi
ok "Code up to date."

# ── 3. Build & start container ─────────────────────────────────────
info "Building Docker image..."
cd "$DEST"
docker compose build --no-cache
ok "Image built."

info "Starting container..."
docker compose up -d
ok "Container running."

# ── 4. Health check ────────────────────────────────────────────────
info "Waiting for server to start..."
sleep 3
if curl -sf http://localhost:8089/ -o /dev/null; then
  ok "Site is responding at http://localhost:8089/"
else
  error "Site is NOT responding. Check logs: docker compose logs -f"
fi

echo ""
echo -e "${GREEN}✓ Efectech deployed successfully!${NC}"
echo -e "  Local:      ${TEAL}http://localhost:8089${NC}"
echo -e "  Public:     ${TEAL}https://efectech.com${NC} (via Cloudflare Tunnel)"
echo -e "  Logs:       ${TEAL}docker compose -f $DEST/docker-compose.yml logs -f${NC}"
echo -e "  Stop:       ${TEAL}docker compose -f $DEST/docker-compose.yml down${NC}"
echo ""
