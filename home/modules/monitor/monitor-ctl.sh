STATE_DIR="$HOME/.local/state/monitor-ctl"
CACHE_DIR="$HOME/.cache/monitor-ctl"
STATE_FILE="$STATE_DIR/state.json"
BUS_FILE="$CACHE_DIR/bus"
CAPS_FILE="$CACHE_DIR/caps"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/monitor-ctl.lock"
LAST_WRITE_FILE="${XDG_RUNTIME_DIR:-/tmp}/monitor-ctl.last-write"

mkdir -p "$STATE_DIR" "$CACHE_DIR"

declare -A CODE=([brightness]=10 [contrast]=12 [sharpness]=87)

BUS=""
available=false
profile=""
mode="auto"
manual_at=0
applied_at=0
brightness=0
contrast=0
sharpness=0
sharpness_supported=false

usage() {
  cat >&2 <<USAGE
uso: monitor-ctl state
     monitor-ctl refresh
     monitor-ctl set <brightness|contrast|sharpness> <0-100>
     monitor-ctl step <brightness|contrast|sharpness> <+N|-N>
     monitor-ctl profile <day|night>
     monitor-ctl auto
     monitor-ctl resume
USAGE
  exit 2
}

now() {
  date +%s
}

clamp() {
  local v=$1
  if [ "$v" -lt 0 ]; then v=0; fi
  if [ "$v" -gt 100 ]; then v=100; fi
  echo "$v"
}

is_int() {
  [[ $1 =~ ^[+-]?[0-9]+$ ]]
}

valid_feature() {
  [[ -n ${CODE[$1]+x} ]]
}

last_boundary() {
  local t day night
  t=$(now)
  day=$(date -d "today $DAY_START" +%s)
  night=$(date -d "today $NIGHT_START" +%s)
  if [ "$t" -ge "$night" ]; then
    echo "$night night"
  elif [ "$t" -ge "$day" ]; then
    echo "$day day"
  else
    echo "$(date -d "yesterday $NIGHT_START" +%s) night"
  fi
}

load_state() {
  local line
  [ -s "$STATE_FILE" ] || return 0
  line=$(jq -r '[(.available // false), (.profile // ""), (.mode // "auto"), (.manualAt // 0), (.appliedAt // 0), (.brightness // 0), (.contrast // 0), (.sharpness // 0), (.sharpnessSupported // false)] | map(tostring) | join("|")' "$STATE_FILE" 2>/dev/null) || return 0
  IFS='|' read -r available profile mode manual_at applied_at brightness contrast sharpness sharpness_supported <<<"$line"
}

save_state() {
  local boundary scheduled
  read -r boundary scheduled <<<"$(last_boundary)"
  jq -n \
    --argjson available "$available" \
    --arg profile "$profile" \
    --arg mode "$mode" \
    --argjson manualAt "$manual_at" \
    --argjson appliedAt "$applied_at" \
    --argjson brightness "$brightness" \
    --argjson contrast "$contrast" \
    --argjson sharpness "$sharpness" \
    --argjson sharpnessSupported "$sharpness_supported" \
    --arg scheduled "$scheduled" \
    --argjson boundary "$boundary" \
    --arg dayStart "$DAY_START" \
    --arg nightStart "$NIGHT_START" \
    --argjson limits "$LIMITS_JSON" \
    '{available: $available, profile: $profile, mode: $mode, manualAt: $manualAt, appliedAt: $appliedAt,
      brightness: $brightness, contrast: $contrast, sharpness: $sharpness, sharpnessSupported: $sharpnessSupported,
      scheduled: $scheduled, boundary: $boundary, dayStart: $dayStart, nightStart: $nightStart, limits: $limits}' > "$STATE_FILE.tmp"
  cat "$STATE_FILE.tmp" > "$STATE_FILE"
  rm -f "$STATE_FILE.tmp"
}

detect_bus() {
  ddcutil detect --terse 2>/dev/null | awk -v want="$CONNECTOR" '
    /^Display [0-9]+/ { valid = 1; bus = ""; next }
    /^Invalid display/ { valid = 0; next }
    !valid { next }
    /I2C bus:/ { bus = $NF; sub(/.*i2c-/, "", bus); if (first == "") first = bus; next }
    /connector/ { for (i = 1; i <= NF; i++) if (bus != "" && $i ~ ("-" want "$")) found = bus }
    END { if (found != "") print found; else if (first != "") print first }'
}

ensure_bus() {
  if [ -s "$BUS_FILE" ]; then
    BUS=$(cat "$BUS_FILE")
    return 0
  fi
  BUS=$(detect_bus || true)
  if [ -n "$BUS" ]; then
    echo "$BUS" > "$BUS_FILE"
    return 0
  fi
  return 1
}

ddc() {
  ddcutil --bus "$BUS" "$@"
}

read_values() {
  local out code type cur max pct got=0
  out=$(ddc getvcp 10 12 87 --brief 2>/dev/null || true)
  [ -n "$out" ] || return 1
  sharpness_supported=false
  while read -r _ code type cur max; do
    if [ "$type" != "C" ] || ! is_int "${max:-x}" || [ "$max" -le 0 ]; then
      continue
    fi
    echo "$max" > "$CACHE_DIR/max_$code"
    pct=$(( (cur * 100 + max / 2) / max ))
    case "$code" in
      10) brightness=$pct; got=$((got + 1)) ;;
      12) contrast=$pct ;;
      87) sharpness=$pct; sharpness_supported=true ;;
    esac
  done <<<"$out"
  [ "$got" -gt 0 ]
}

max_of() {
  local code=$1 max
  if [ -s "$CACHE_DIR/max_$code" ]; then
    cat "$CACHE_DIR/max_$code"
    return 0
  fi
  max=$(ddc getvcp "$code" --brief 2>/dev/null | awk '$3 == "C" { print $5 }' || true)
  is_int "${max:-x}" || return 1
  echo "$max" > "$CACHE_DIR/max_$code"
  echo "$max"
}

caps_vcp() {
  if [ ! -s "$CAPS_FILE" ]; then
    ddc capabilities --terse 2>/dev/null | sed -n 's/^Unparsed capabilities string: //p' > "$CAPS_FILE.tmp" || true
    if [ -s "$CAPS_FILE.tmp" ]; then
      mv "$CAPS_FILE.tmp" "$CAPS_FILE"
    else
      rm -f "$CAPS_FILE.tmp"
      return 1
    fi
  fi
  awk '{
    i = index($0, "vcp("); if (!i) exit
    s = substr($0, i + 4); d = 1; o = ""
    for (k = 1; k <= length(s); k++) {
      c = substr(s, k, 1)
      if (c == "(") d++
      else if (c == ")") { d--; if (d == 0) break }
      o = o c
    }
    gsub(/\(/, " ( ", o); gsub(/\)/, " ) ", o); print toupper(o)
  }' "$CAPS_FILE"
}

cap_has_value() {
  local code want
  code=$(printf '%02X' "$((16#$1))")
  want=$(printf '%02X' "$((16#$2))")
  caps_vcp | awk -v c="$code" -v w="$want" '{
    for (i = 1; i <= NF; i++)
      if ($i == c && $(i + 1) == "(")
        for (j = i + 2; j <= NF && $j != ")"; j++)
          if ($j == w) f = 1
  } END { exit !f }'
}

read_current() {
  ddc getvcp "$1" --brief 2>/dev/null | awk '{
    if ($3 == "C") { print $4; exit }
    v = $NF; sub(/^x/, "", v); print strtonum("0x" v); exit
  }' || true
}

set_code() {
  local code=$1 value=$2 cur
  cur=$(read_current "$code")
  if [ "$cur" = "$value" ]; then
    return 0
  fi
  if ! ddc_write "$code" "$value"; then
    echo "monitor-ctl: el monitor rechazo VCP $code=$value" >&2
    return 1
  fi
}

set_gain() {
  local code=$1 pct=$2 max
  if [ "$pct" -lt 60 ]; then pct=60; fi
  if [ "$pct" -gt 100 ]; then pct=100; fi
  max=$(max_of "$code") || return 1
  set_code "$code" "$(( pct * max / 100 ))"
}

ddc_write() {
  local code=$1 raw=$2
  case "$code" in
    10|12|87|14|72|16|18|1A) ;;
    *)
      echo "monitor-ctl: escritura bloqueada al codigo VCP $code" >&2
      return 1
      ;;
  esac
  throttle
  ddc setvcp "$code" "$raw" >/dev/null 2>&1
}

throttle() {
  local last now_ms wait_ms
  now_ms=$(date +%s%3N)
  last=$(cat "$LAST_WRITE_FILE" 2>/dev/null || echo 0)
  is_int "$last" || last=0
  wait_ms=$(( MIN_WRITE_GAP_MS - (now_ms - last) ))
  if [ "$wait_ms" -gt 0 ]; then
    sleep "$(printf '0.%03d' "$wait_ms")"
  fi
  date +%s%3N > "$LAST_WRITE_FILE"
}

quantize() {
  local name=$1 pct=$2 lo hi step
  lo=$(limit_get "$name" min)
  hi=$(limit_get "$name" max)
  step=$(limit_get "$name" step)
  if [ "$pct" -lt "$lo" ]; then pct=$lo; fi
  if [ "$pct" -gt "$hi" ]; then pct=$hi; fi
  pct=$(( (pct + step / 2) / step * step ))
  if [ "$pct" -gt "$hi" ]; then pct=$(( hi / step * step )); fi
  if [ "$pct" -lt "$lo" ]; then pct=$(( (lo + step - 1) / step * step )); fi
  echo "$pct"
}

read_raw() {
  ddc getvcp "$1" --brief 2>/dev/null | awk '$3 == "C" { print $4 }' || true
}

set_feature() {
  local name=$1 pct code max raw cur step
  pct=$(quantize "$name" "$2")
  code=${CODE[$name]}
  step=$(limit_get "$name" step)
  max=$(max_of "$code") || return 1
  if [ $(( max * step % 100 )) -ne 0 ]; then
    echo "monitor-ctl: $name usa una escala ($max) que no encaja con pasos de $step%; no se escribe" >&2
    return 1
  fi
  raw=$(( pct * max / 100 ))
  if [ "$raw" -lt 0 ] || [ "$raw" -gt "$max" ]; then
    return 1
  fi
  cur=$(read_raw "$code")
  if [ "$cur" = "$raw" ]; then
    printf -v "$name" '%s' "$pct"
    return 0
  fi
  if ! ddc_write "$code" "$raw"; then
    cur=$(read_raw "$code")
    if is_int "${cur:-x}"; then
      printf -v "$name" '%s' "$(( (cur * 100 + max / 2) / max ))"
    fi
    echo "monitor-ctl: el monitor no acepto $name=$pct% (quiza esta bloqueado por el modo de color actual)" >&2
    return 1
  fi
  printf -v "$name" '%s' "$pct"
}

apply_profile() {
  local p=$1 preset gamma gain entry
  preset=$(profile_get "$p" colorPreset)
  if [ -n "$preset" ] && cap_has_value 14 "$preset"; then
    if set_code 14 "$((16#$preset))"; then
      sleep 0.5
    fi
  fi
  if [ "$preset" = 0b ]; then
    for entry in 16:gainRed 18:gainGreen 1A:gainBlue; do
      gain=$(profile_get "$p" "${entry#*:}")
      if [ -n "$gain" ]; then
        set_gain "${entry%%:*}" "$gain" || true
      fi
    done
  fi
  gamma=$(profile_get "$p" gamma)
  if [ -n "$gamma" ] && cap_has_value 72 "$gamma"; then
    set_code 72 "$((16#$gamma))" || true
  fi
  set_feature brightness "$(profile_get "$p" brightness)" || return 1
  set_feature contrast "$(profile_get "$p" contrast)" || true
  if [ "$sharpness_supported" = true ]; then
    set_feature sharpness "$(profile_get "$p" sharpness)" || true
  fi
  profile=$p
  applied_at=$(now)
}

prepare() {
  if ! ensure_bus; then
    available=false
    save_state
    echo "monitor-ctl: no se encontro un monitor con DDC/CI" >&2
    exit 1
  fi
  if [ "$available" != true ]; then
    if read_values; then
      available=true
    else
      rm -f "$BUS_FILE"
      available=false
      save_state
      echo "monitor-ctl: el monitor no responde por DDC/CI" >&2
      exit 1
    fi
  fi
}

refresh() {
  if ensure_bus && read_values; then
    available=true
  else
    rm -f "$BUS_FILE"
    if ensure_bus && read_values; then
      available=true
    else
      available=false
    fi
  fi
  save_state
}

exec 9>"$LOCK_FILE"
flock 9

load_state

cmd=${1:-state}
case "$cmd" in
  state)
    [ -s "$STATE_FILE" ] || refresh
    cat "$STATE_FILE"
    ;;
  refresh)
    refresh
    cat "$STATE_FILE"
    ;;
  set|step)
    [ $# -eq 3 ] || usage
    valid_feature "$2" || usage
    is_int "$3" || usage
    prepare
    if [ "$2" = sharpness ] && [ "$sharpness_supported" != true ]; then
      echo "monitor-ctl: este monitor no expone nitidez por DDC/CI" >&2
      exit 1
    fi
    if [ "$cmd" = step ]; then
      target=$(( ${!2} + $3 ))
    else
      target=$3
    fi
    if ! set_feature "$2" "$target"; then
      save_state
      exit 1
    fi
    mode=manual
    manual_at=$(now)
    save_state
    ;;
  profile)
    [ $# -eq 2 ] || usage
    case "$2" in day|night) ;; *) usage ;; esac
    prepare
    apply_profile "$2"
    mode=manual
    manual_at=$(now)
    save_state
    ;;
  auto|resume)
    if [ "$cmd" = resume ]; then
      mode=auto
      manual_at=0
      applied_at=0
    fi
    read -r boundary scheduled <<<"$(last_boundary)"
    if [ "$mode" = manual ] && [ "$manual_at" -ge "$boundary" ]; then
      save_state
      exit 0
    fi
    mode=auto
    if [ "$available" = true ] && [ "$profile" = "$scheduled" ] && [ "$applied_at" -ge "$boundary" ]; then
      save_state
      exit 0
    fi
    prepare
    apply_profile "$scheduled"
    save_state
    ;;
  *)
    usage
    ;;
esac
