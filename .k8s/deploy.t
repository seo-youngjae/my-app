apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${USER_NAME}-${SERVICE_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}-${SERVICE_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${USER_NAME}-${SERVICE_NAME}
  template:
    metadata:
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8080'
        prometheus.io/path: '/actuator/prometheus'
        update: ${HASHCODE}
      labels:
        app: ${USER_NAME}-${SERVICE_NAME}
    spec:
      serviceAccountName: jenkins
      securityContext:
        fsGroup: 1000
        runAsUser: 1000
      initContainers:
      - name: volume-mount-permission
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /var/jenkins_home"]
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        securityContext:
          runAsUser: 0
      containers:
      - name: jenkins
        image: amdp-registry.skala-ai.com/skala25a/${USER_NAME}-${IMAGE_NAME}-amd64:${VERSION}
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
          name: http-port
        - containerPort: 50000
          name: jnlp-port
        env:
        - name: JENKINS_OPTS
          value: "--httpPort=8080"
        - name: JAVA_OPTS
          value: "-Xmx2048m -Djenkins.install.runSetupWizard=false -Djenkins.CLI.disabled=true -Djenkins.security.ApiTokenProperty.adminCanGenerateNewTokens=true"
        - name: CASC_JENKINS_CONFIG
          value: /var/jenkins_config/jenkins.yaml
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        - name: jenkins-config-volume
          mountPath: /var/jenkins_config
        livenessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 10
        readinessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 10
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: ${USER_NAME}-${SERVICE_NAME}-pvc
      - name: jenkins-config-volume
        configMap:
          name: ${USER_NAME}-${SERVICE_NAME}-config
