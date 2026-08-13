#!/bin/bash
FUNC_URL="https://kmwwkgkrniutyynofopw.functions.supabase.co/generate-trending-reason"
WORKER_SECRET="1b8d6ca45db28d00e3eef6a515b7bebb751c86d96f94fd28b2e8beb5dbc0472b"
ANON_KEY="sb_publishable_0fBtxVTSip3oge3XchxTUA_mihNGq3C"
BATCH_SIZE=5
DAILY_MAX=40

PROCESSED_TODAY=0
echo "Mulai, target hari ini maksimal $DAILY_MAX saham..."
echo ""

while [ $PROCESSED_TODAY -lt $DAILY_MAX ]; do
  echo "-> Proses batch (limit=$BATCH_SIZE)..."
  RESPONSE=$(curl -s -X POST "${FUNC_URL}?limit=${BATCH_SIZE}" \
    -H "x-worker-secret: ${WORKER_SECRET}" \
    -H "Authorization: Bearer ${ANON_KEY}" \
    -H "Content-Type: application/json" \
    -d '{}')

  echo "$RESPONSE"
  echo ""

  PROCESSED=$(echo "$RESPONSE" | grep -o '"processed":[0-9]*' | grep -o '[0-9]*')

  if [ -z "$PROCESSED" ]; then
    echo "Batch gagal total (kemungkinan limit resource), retry batch yang sama setelah jeda 5 detik..."
    sleep 5
    continue
  fi

  if [ "$PROCESSED" -eq 0 ]; then
    echo "Semua saham udah kelar diproses."
    break
  fi

  PROCESSED_TODAY=$((PROCESSED_TODAY + PROCESSED))
  sleep 3
done

echo "======================================="
echo "Selesai untuk sekarang. Total diproses: $PROCESSED_TODAY saham."
echo "Jalanin lagi kapan aja buat lanjut -- otomatis resume dari yang belum digarap."
echo "======================================="
