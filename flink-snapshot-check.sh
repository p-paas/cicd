while true; do
  STATE=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.state}' 2>/dev/null || true)
  PATH_VALUE=$(kubectl get flinkstatesnapshot "${SNAPSHOT_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.path}' 2>/dev/null || true)

  echo "state=${STATE}, path=${PATH_VALUE}"

  if [ "${STATE}" = "COMPLETED" ]; then
    MSG="Flink savepoint completed successfully
    Flink State Snapshot Name: ${SNAPSHOT_NAME}
    Savepoint path: ${PATH_VALUE}"
    echo "${MSG}"
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
