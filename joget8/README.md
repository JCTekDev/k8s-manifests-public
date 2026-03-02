# Joget DX 8 App
Database Host: mysql.<namespace>.svc.cluster.local

# Security Certificate Installation
 To install the security certificate (CA cert) from other TLS/HTTPS services for secure communication:
 
 1. Obtain the TLS certificate file (usually named `wsagentes-tls-cert.clusterwide.sealed.yaml`) from the overlays/dev or overlays/dev827 directory.
 2. Apply the sealed certificate to your Kubernetes cluster:
    
		```sh
		kubectl apply -f overlays/dev/wsagentes-tls-cert.clusterwide.sealed.yaml
		# or for dev827 environment
		kubectl apply -f overlays/dev827/wsagentes-tls-cert.clusterwide.sealed.yaml
		```
 3. The certificate will be available as a Kubernetes secret. To use it in Joget, mount the secret in your deployment or reference it in your application configuration as needed.
 4. If you need to add the CA certificate to the Java truststore in the Joget container:
		- Extract the certificate from the secret:
			```sh
			kubectl get secret wsagentes-tls-cert -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/wsagentes-ca.crt
			```
		- Import it into the Java truststore:
			```sh
			keytool -import -trustcacerts -alias wsagentesCA -file /tmp/wsagentes-ca.crt -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit
			```
		- Restart the Joget pod to apply changes.
 
 This ensures Joget can securely communicate with services protected by the wsagentes CA certificate.

