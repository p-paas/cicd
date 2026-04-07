while true; do
  STATE=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.state}' 2>/dev/null || true)
  STATUS=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status}' 2>/dev/null || true)

  echo "STATUS=${STATUS}"

  if [ "${STATE}" = "COMPLETED" ]; then
    echo "${STATUS}"
    curl -X POST -H "Content-Type: application/json" \
        -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"${STATUS}\"}}" \
        ${WEBHOOK_URL}
    exit 0
  fi

  if [ "${STATE}" = "FAILED" ]; then
    echo "savepoint failed"
    exit 1
  fi

  sleep 30
done
