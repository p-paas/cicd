while true; do
  FLINK_NAME=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.spec.jobReference.name}' 2>/dev/null || true)
  STATUS=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status}' 2>/dev/null || true)
  STATE=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.state}' 2>/dev/null || true)
  PATH_VALUE=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.path}' 2>/dev/null || true)
  FAILURES=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.failures}' 2>/dev/null || true)
  TRIGGER_ID=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.triggerId}' 2>/dev/null || true)
  TRIGGER_TS=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.triggerTimestamp}' 2>/dev/null || true)
  RESULT_TS=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.resultTimestamp}' 2>/dev/null || true)

  echo "${STATUS}"

  if [ "${STATE}" = "COMPLETED" ]; then
    curl -sS -X POST \
      -H "Content-Type: application/json" \
      -d "{
        \"msg_type\": \"interactive\",
        \"card\": {
          \"type\": \"template\",
          \"data\": {
            \"template_id\": \"${TRMPATE_ID}\",
            \"template_variable\": {
              \"FLINK_NAME\": \"${FLINK_NAME}\",
              \"STATE\": \"${STATE}\",
              \"PATH_VALUE\": \"${PATH_VALUE}\",
              \"FAILURES\": \"${FAILURES}\",
              \"TRIGGER_ID\": \"${TRIGGER_ID}\",
              \"TRIGGER_TS\": \"${TRIGGER_TS}\",
              \"RESULT_TS\": \"${RESULT_TS}\"
            }
          }
        }
      }" \
      "${WEBHOOK_URL}"
    exit 0
  fi

  if [ "${STATE}" = "FAILED" ]; then
    echo "savepoint failed"
    exit 1
  fi

  sleep 30
done
