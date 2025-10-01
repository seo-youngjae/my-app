apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${USER_NAME}-${SERVICE_NAME}-pvc
  namespace: ${NAMESPACE}
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: 100Mi
  storageClassName: efs-sc-shared
