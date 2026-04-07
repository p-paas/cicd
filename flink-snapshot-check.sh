while true; do
  FLINK_NAME=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.spec.jobReference.name}' 2>/dev/null || true)
  STATUS=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status}' 2>/dev/null || true)
  STATE="$(echo "${STATUS}" | jq -r '.state // empty')"
  PATH_VALUE="$(echo "${STATUS}" | jq -r '.path // empty')"
  FAILURES="$(echo "${STATUS}" | jq -r '.failures // empty')"
  TRIGGER_ID="$(echo "${STATUS}" | jq -r '.triggerId // empty')"
  TRIGGER_TS="$(echo "${STATUS}" | jq -r '.triggerTimestamp // empty')"
  RESULT_TS="$(echo "${STATUS}" | jq -r '.resultTimestamp // empty')"

  MSG="${FLINK_NAME} savepoint completed
  State: ${STATE}
  Path: ${PATH_VALUE}
  Failures: ${FAILURES}
  Trigger ID: ${TRIGGER_ID}
  Trigger Time: ${TRIGGER_TS}
  Result Time: ${RESULT_TS}"

  echo "${MSG}"

  if [ "${STATE}" = "COMPLETED" ]; then
    echo "${STATUS}"
    curl -X POST -H "Content-Type: application/json" \
        -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"${MSG}\"}}" \
        ${WEBHOOK_URL}
    exit 0
  fi

  if [ "${STATE}" = "FAILED" ]; then
    echo "savepoint failed"
    exit 1
  fi

  sleep 30
done
